import 'dart:async';

/// Chat Service - Handle live chat between admin and students
class ChatService {
  // Singleton pattern
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  // Stream controller for real-time updates
  final _messagesController = StreamController<List<ChatMessage>>.broadcast();
  final _conversationsController = StreamController<List<Conversation>>.broadcast();

  // In-memory storage (replace with database/Firebase in production)
  final Map<String, List<ChatMessage>> _conversations = {};
  final Map<String, ConversationInfo> _conversationInfos = {};

  /// Get messages stream for a conversation
  Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    return _messagesController.stream;
  }

  /// Get all conversations (for admin)
  Stream<List<Conversation>> getConversationsStream() {
    return _conversationsController.stream;
  }

  /// Get or create conversation between user and admin
  String getOrCreateConversation({
    required String userId,
    required String userName,
  }) {
    final conversationId = 'conv_$userId';
    
    if (!_conversations.containsKey(conversationId)) {
      _conversations[conversationId] = [];
      _conversationInfos[conversationId] = ConversationInfo(
        conversationId: conversationId,
        userId: userId,
        userName: userName,
        userRole: 'student',
        lastMessage: 'Mulai percakapan',
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        isOnline: true,
        mode: 'bot', // Default to bot mode
      );
    }
    
    return conversationId;
  }

  /// Get conversation mode
  String getConversationMode(String conversationId) {
    return _conversationInfos[conversationId]?.mode ?? 'bot';
  }

  /// Set conversation mode
  Future<bool> setConversationMode(String conversationId, String mode) async {
    try {
      if (_conversationInfos.containsKey(conversationId)) {
        final info = _conversationInfos[conversationId]!;
        _conversationInfos[conversationId] = ConversationInfo(
          conversationId: info.conversationId,
          userId: info.userId,
          userName: info.userName,
          userRole: info.userRole,
          lastMessage: info.lastMessage,
          lastMessageTime: info.lastMessageTime,
          unreadCount: info.unreadCount,
          isOnline: info.isOnline,
          mode: mode,
        );
        _notifyConversationsUpdate();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Send message
  Future<bool> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderRole, // 'student', 'admin', or 'bot'
    required String message,
    String? eventId,
  }) async {
    try {
      final chatMessage = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        message: message,
        timestamp: DateTime.now(),
        isRead: false,
      );

      if (!_conversations.containsKey(conversationId)) {
        _conversations[conversationId] = [];
      }

      _conversations[conversationId]!.add(chatMessage);

      // Update conversation info
      if (_conversationInfos.containsKey(conversationId)) {
        final info = _conversationInfos[conversationId]!;
        _conversationInfos[conversationId] = ConversationInfo(
          conversationId: info.conversationId,
          userId: info.userId,
          userName: info.userName,
          userRole: info.userRole,
          lastMessage: message,
          lastMessageTime: DateTime.now(),
          unreadCount: senderRole == 'student' ? info.unreadCount + 1 : info.unreadCount,
          isOnline: info.isOnline,
          mode: info.mode, // Preserve mode
        );
      }

      // Notify listeners
      _messagesController.add(_conversations[conversationId]!);
      _notifyConversationsUpdate();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get messages for a conversation
  List<ChatMessage> getMessages(String conversationId) {
    return _conversations[conversationId] ?? [];
  }

  /// Get all conversations (for admin)
  List<Conversation> getAllConversations() {
    return _conversationInfos.entries.map((entry) {
      final messages = _conversations[entry.key] ?? [];
      return Conversation(
        info: entry.value,
        messages: messages,
      );
    }).toList()
      ..sort((a, b) => b.info.lastMessageTime.compareTo(a.info.lastMessageTime));
  }

  /// Mark messages as read
  Future<void> markAsRead(String conversationId, String userId) async {
    if (_conversations.containsKey(conversationId)) {
      for (var message in _conversations[conversationId]!) {
        if (message.senderId != userId) {
          message.isRead = true;
        }
      }

      // Reset unread count
      if (_conversationInfos.containsKey(conversationId)) {
        final info = _conversationInfos[conversationId]!;
        _conversationInfos[conversationId] = ConversationInfo(
          conversationId: info.conversationId,
          userId: info.userId,
          userName: info.userName,
          userRole: info.userRole,
          lastMessage: info.lastMessage,
          lastMessageTime: info.lastMessageTime,
          unreadCount: 0,
          isOnline: info.isOnline,
          mode: info.mode, // Preserve mode
        );
      }

      _messagesController.add(_conversations[conversationId]!);
      _notifyConversationsUpdate();
    }
  }

  /// Get total unread count (for admin)
  int getTotalUnreadCount() {
    return _conversationInfos.values
        .fold(0, (sum, info) => sum + info.unreadCount);
  }

  /// Delete conversation
  Future<bool> deleteConversation(String conversationId) async {
    try {
      _conversations.remove(conversationId);
      _conversationInfos.remove(conversationId);
      _notifyConversationsUpdate();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Notify conversations update
  void _notifyConversationsUpdate() {
    _conversationsController.add(getAllConversations());
  }

  /// Dispose
  void dispose() {
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
  final String senderRole; // 'admin' or 'student'
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
}

/// Conversation Info Model
class ConversationInfo {
  final String conversationId;
  final String userId;
  final String userName;
  final String userRole;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final String mode; // 'bot' or 'admin'

  ConversationInfo({
    required this.conversationId,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
    this.mode = 'bot', // Default to bot mode
  });
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
