import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Chat Service - Handle live chat between admin and students using Supabase
class ChatService {
  final _supabase = Supabase.instance.client;

  // Stream controllers for real-time updates
  final _messagesController = StreamController<List<ChatMessage>>.broadcast();
  final _conversationsController = StreamController<List<Conversation>>.broadcast();

  RealtimeChannel? _messagesSubscription;
  RealtimeChannel? _conversationsSubscription;

  /// Initialize realtime subscriptions
  void initializeRealtimeSubscriptions() {
    // Subscribe to messages changes
    _messagesSubscription = _supabase
        .channel('messages_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (_) => _notifyMessagesUpdate(),
        )
        .subscribe();

    // Subscribe to conversations changes
    _conversationsSubscription = _supabase
        .channel('conversations_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'conversations',
          callback: (_) => _notifyConversationsUpdate(),
        )
        .subscribe();
  }

  /// Get messages stream for a conversation
  Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    return _messagesController.stream;
  }

  /// Get all conversations stream (for admin)
  Stream<List<Conversation>> getConversationsStream() {
    return _conversationsController.stream;
  }

  /// Get or create conversation between user and admin
  Future<String> getOrCreateConversation({
    required String userId,
    required String userName,
    String? eventId,
    String? eventTitle,
  }) async {
    try {
      // Check if conversation exists
      final existing = await _supabase
          .from('conversations')
          .select()
          .eq('student_id', userId)
          .maybeSingle();

      if (existing != null) {
        return existing['id'];
      }

      // Create new conversation
      final response = await _supabase
          .from('conversations')
          .insert({
            'student_id': userId,
            'student_name': userName,
            'event_id': eventId,
            'event_title': eventTitle,
            'mode': 'bot',
            'last_message': 'Conversation started',
            'last_message_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response['id'];
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }

  /// Get conversation mode
  Future<String> getConversationMode(String conversationId) async {
    try {
      final response = await _supabase
          .from('conversations')
          .select('mode')
          .eq('id', conversationId)
          .single();

      return response['mode'] ?? 'bot';
    } catch (e) {
      return 'bot';
    }
  }

  /// Set conversation mode
  Future<bool> setConversationMode(String conversationId, String mode) async {
    try {
      await _supabase
          .from('conversations')
          .update({'mode': mode, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', conversationId);

      _notifyConversationsUpdate();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Send message
  Future<bool> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
  }) async {
    try {
      // Insert message
      await _supabase.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': senderId,
        'sender_name': senderName,
        'sender_role': senderRole,
        'message': message,
      });

      // Update conversation last message
      await _supabase
          .from('conversations')
          .update({
            'last_message': message,
            'last_message_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', conversationId);

      _notifyMessagesUpdate();
      _notifyConversationsUpdate();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get messages for a conversation
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => ChatMessage.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get all conversations (for admin)
  Future<List<Conversation>> getAllConversations() async {
    try {
      final response = await _supabase
          .from('conversations')
          .select()
          .eq('is_active', true)
          .order('last_message_at', ascending: false);

      List<Conversation> conversations = [];

      for (var convJson in response as List) {
        final messages = await getMessages(convJson['id']);
        conversations.add(Conversation(
          info: ConversationInfo.fromJson(convJson),
          messages: messages,
        ));
      }

      return conversations;
    } catch (e) {
      return [];
    }
  }

  /// Mark messages as read
  Future<void> markAsRead(String conversationId, String userId) async {
    try {
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .neq('sender_id', userId);

      await _supabase
          .from('conversations')
          .update({'unread_count': 0})
          .eq('id', conversationId);

      _notifyMessagesUpdate();
      _notifyConversationsUpdate();
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get total unread count (for admin)
  Future<int> getTotalUnreadCount() async {
    try {
      final response = await _supabase
          .from('conversations')
          .select('unread_count')
          .eq('is_active', true);

      int total = 0;
      for (var conv in response as List) {
        total += (conv['unread_count'] as int?) ?? 0;
      }

      return total;
    } catch (e) {
      return 0;
    }
  }

  /// Delete conversation
  Future<bool> deleteConversation(String conversationId) async {
    try {
      await _supabase
          .from('conversations')
          .update({'is_active': false})
          .eq('id', conversationId);

      _notifyConversationsUpdate();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Notify messages update
  void _notifyMessagesUpdate() async {
    // Implement if needed for specific conversation
  }

  /// Notify conversations update
  void _notifyConversationsUpdate() async {
    final conversations = await getAllConversations();
    _conversationsController.add(conversations);
  }

  /// Dispose
  void dispose() {
    _messagesSubscription?.unsubscribe();
    _conversationsSubscription?.unsubscribe();
    _messagesController.close();
    _conversationsController.close();
  }
}

/// Chat Message Model
class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String message;
  final DateTime timestamp;
  bool isRead;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'] ?? '',
      senderName: json['sender_name'],
      senderRole: json['sender_role'],
      message: json['message'],
      timestamp: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
    );
  }
}

/// Conversation Info Model
class ConversationInfo {
  final String conversationId;
  final String userId;
  final String userName;
  final String? eventId;
  final String? eventTitle;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String mode;

  ConversationInfo({
    required this.conversationId,
    required this.userId,
    required this.userName,
    this.eventId,
    this.eventTitle,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    this.mode = 'bot',
  });

  factory ConversationInfo.fromJson(Map<String, dynamic> json) {
    return ConversationInfo(
      conversationId: json['id'],
      userId: json['student_id'],
      userName: json['student_name'],
      eventId: json['event_id'],
      eventTitle: json['event_title'],
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: DateTime.parse(json['last_message_at']),
      unreadCount: json['unread_count'] ?? 0,
      mode: json['mode'] ?? 'bot',
    );
  }
}

/// Conversation Model (Info + Messages)
class Conversation {
  final ConversationInfo info;
  final List<ChatMessage> messages;

  Conversation({
    required this.info,
    required this.messages,
  });
}
