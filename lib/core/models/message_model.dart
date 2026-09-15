import 'package:intl/intl.dart';

/// Message Model for Chat System - Maps to messages table in Database V3.2
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'student', 'admin', or 'bot'
  final String message;
  final DateTime createdAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    DateTime? createdAt,
    this.isRead = false,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isFromStudent => senderRole == 'student';
  bool get isFromAdmin => senderRole == 'admin';
  bool get isFromBot => senderRole == 'bot';

  String get formattedTime => DateFormat('HH:mm').format(createdAt);
  String get formattedDate => DateFormat('d MMM yyyy').format(createdAt);
  String get formattedDateTime => DateFormat('d MMM, HH:mm').format(createdAt);

  /// Convert to JSON for Supabase (snake_case)
  Map<String, dynamic> toJson() => {
        'id': id,
        'conversation_id': conversationId,
        'sender_id': senderId,
        'sender_name': senderName,
        'sender_role': senderRole,
        'message': message,
        'created_at': createdAt.toIso8601String(),
        'is_read': isRead,
      };

  /// Create from JSON from Supabase (snake_case)
  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String,
        conversationId: json['conversation_id'] as String,
        senderId: json['sender_id'] as String,
        senderName: json['sender_name'] as String,
        senderRole: json['sender_role'] as String,
        message: json['message'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        isRead: json['is_read'] as bool? ?? false,
      );

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderRole,
    String? message,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Conversation Model - Maps to conversations table in Database V3.2
class ConversationModel {
  final String id;
  final String studentId;
  final String studentName;
  final String? eventId;
  final String? eventTitle;
  final String mode; // 'admin' or 'bot'
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConversationModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.eventId,
    this.eventTitle,
    this.mode = 'admin',
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get formattedLastTime {
    if (lastMessageAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastMessageAt!);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('d MMM').format(lastMessageAt!);
  }

  bool get isAdminMode => mode == 'admin';
  bool get isBotMode => mode == 'bot';

  /// Convert to JSON for Supabase (snake_case)
  Map<String, dynamic> toJson() => {
        'id': id,
        'student_id': studentId,
        'student_name': studentName,
        'event_id': eventId,
        'event_title': eventTitle,
        'mode': mode,
        'last_message': lastMessage,
        'last_message_at': lastMessageAt?.toIso8601String(),
        'unread_count': unreadCount,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  /// Create from JSON from Supabase (snake_case)
  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        id: json['id'] as String,
        studentId: json['student_id'] as String,
        studentName: json['student_name'] as String,
        eventId: json['event_id'] as String?,
        eventTitle: json['event_title'] as String?,
        mode: json['mode'] as String? ?? 'admin',
        lastMessage: json['last_message'] as String?,
        lastMessageAt: json['last_message_at'] != null
            ? DateTime.parse(json['last_message_at'] as String)
            : null,
        unreadCount: json['unread_count'] as int? ?? 0,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
      );

  ConversationModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? eventId,
    String? eventTitle,
    String? mode,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      mode: mode ?? this.mode,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
