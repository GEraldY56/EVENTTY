import 'package:intl/intl.dart';

/// Message Model for Chat System
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'student' or 'admin'
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? eventId;
  final String? eventTitle;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.receiverId,
    required this.message,
    DateTime? timestamp,
    this.isRead = false,
    this.eventId,
    this.eventTitle,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isFromStudent => senderRole == 'student';
  bool get isFromAdmin => senderRole == 'admin';

  String get formattedTime => DateFormat('HH:mm').format(timestamp);
  String get formattedDate => DateFormat('d MMM yyyy').format(timestamp);
  String get formattedDateTime => DateFormat('d MMM, HH:mm').format(timestamp);

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'receiverId': receiverId,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
        'eventId': eventId,
        'eventTitle': eventTitle,
      };

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String,
        conversationId: json['conversationId'] as String,
        senderId: json['senderId'] as String,
        senderName: json['senderName'] as String,
        senderRole: json['senderRole'] as String,
        receiverId: json['receiverId'] as String,
        message: json['message'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isRead: json['isRead'] as bool? ?? false,
        eventId: json['eventId'] as String?,
        eventTitle: json['eventTitle'] as String?,
      );

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderRole,
    String? receiverId,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? eventId,
    String? eventTitle,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
    );
  }
}

/// Conversation Model (untuk list conversations)
class ConversationModel {
  final String id;
  final String studentId;
  final String studentName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final String? eventId;
  final String? eventTitle;

  ConversationModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.eventId,
    this.eventTitle,
  });

  String get formattedLastTime {
    if (lastMessageTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastMessageTime!);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('d MMM').format(lastMessageTime!);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'studentName': studentName,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime?.toIso8601String(),
        'unreadCount': unreadCount,
        'eventId': eventId,
        'eventTitle': eventTitle,
      };

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        id: json['id'] as String,
        studentId: json['studentId'] as String,
        studentName: json['studentName'] as String,
        lastMessage: json['lastMessage'] as String?,
        lastMessageTime: json['lastMessageTime'] != null
            ? DateTime.parse(json['lastMessageTime'] as String)
            : null,
        unreadCount: json['unreadCount'] as int? ?? 0,
        eventId: json['eventId'] as String?,
        eventTitle: json['eventTitle'] as String?,
      );
}
