import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';

/// Message Service untuk mengelola chat/messages dengan Supabase
class MessageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // CONVERSATIONS
  // ============================================================

  /// Get all conversations for a student
  Future<List<ConversationModel>> getStudentConversations(String studentId) async {
    try {
      final response = await _supabase
          .from('conversations')
          .select('*')
          .eq('student_id', studentId)
          .order('last_message_at', ascending: false);

      return (response as List)
          .map((json) => ConversationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch conversations: $e');
    }
  }

  /// Get all conversations (Admin view)
  Future<List<ConversationModel>> getAllConversations() async {
    try {
      final response = await _supabase
          .from('conversations')
          .select('*')
          .order('last_message_at', ascending: false);

      return (response as List)
          .map((json) => ConversationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all conversations: $e');
    }
  }

  /// Get or create conversation
  Future<ConversationModel> getOrCreateConversation({
    required String studentId,
    required String studentName,
    String? eventId,
    String? eventTitle,
  }) async {
    try {
      // Check if conversation exists
      final existingQuery = _supabase
          .from('conversations')
          .select('*')
          .eq('student_id', studentId);

      if (eventId != null) {
        existingQuery.eq('event_id', eventId);
      } else {
        existingQuery.is_('event_id', null);
      }

      final existing = await existingQuery;

      if (existing.isNotEmpty) {
        return ConversationModel.fromJson(existing.first);
      }

      // Create new conversation
      final data = {
        'student_id': studentId,
        'student_name': studentName,
        'event_id': eventId,
        'event_title': eventTitle,
        'mode': 'bot',
        'is_active': true,
        'unread_count': 0,
      };

      final response = await _supabase
          .from('conversations')
          .insert(data)
          .select()
          .single();

      return ConversationModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }

  /// Update conversation last message
  Future<void> updateConversationLastMessage(
    String conversationId,
    String lastMessage,
  ) async {
    try {
      await _supabase.from('conversations').update({
        'last_message': lastMessage,
        'last_message_at': DateTime.now().toIso8601String(),
      }).eq('id', conversationId);
    } catch (e) {
      throw Exception('Failed to update conversation: $e');
    }
  }

  /// Switch conversation mode (bot <-> admin)
  Future<void> switchConversationMode(String conversationId, String mode) async {
    try {
      await _supabase.from('conversations').update({
        'mode': mode,
      }).eq('id', conversationId);
    } catch (e) {
      throw Exception('Failed to switch mode: $e');
    }
  }

  /// Mark conversation as read
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      await _supabase.from('conversations').update({
        'unread_count': 0,
      }).eq('id', conversationId);
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }

  // ============================================================
  // MESSAGES
  // ============================================================

  /// Get messages for a conversation
  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('*')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  /// Send message
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
  }) async {
    try {
      final data = {
        'conversation_id': conversationId,
        'sender_id': senderId,
        'sender_name': senderName,
        'sender_role': senderRole,
        'message': message,
        'is_read': false,
      };

      final response = await _supabase
          .from('messages')
          .insert(data)
          .select()
          .single();

      // Update conversation last message
      await updateConversationLastMessage(conversationId, message);

      return MessageModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  /// Get unread messages count for student
  Future<int> getUnreadCount(String studentId) async {
    try {
      final conversations = await _supabase
          .from('conversations')
          .select('unread_count')
          .eq('student_id', studentId);

      int total = 0;
      for (var conv in conversations) {
        total += (conv['unread_count'] as int?) ?? 0;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  // ============================================================
  // REALTIME SUBSCRIPTIONS
  // ============================================================

  /// Subscribe to new messages in a conversation
  Stream<MessageModel> subscribeToMessages(String conversationId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .map((data) => data.map((json) => MessageModel.fromJson(json)).toList())
        .expand((messages) => messages);
  }

  /// Subscribe to conversation updates
  Stream<List<ConversationModel>> subscribeToConversations(String studentId) {
    return _supabase
        .from('conversations')
        .stream(primaryKey: ['id'])
        .eq('student_id', studentId)
        .order('last_message_at', ascending: false)
        .map((data) => data.map((json) => ConversationModel.fromJson(json)).toList());
  }
}
