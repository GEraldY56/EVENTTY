/// Notification Model - Maps to notifications table in Database V3.2
/// Notification adalah alert otomatis dari sistem berdasarkan event/action
class NotificationModel {
  final String id;
  final String userId; // Student yang menerima
  final String type; // Type as string from database
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? relatedId; // Maps to related_id in database

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    DateTime? createdAt,
    this.isRead = false,
    this.relatedId,
  }) : createdAt = createdAt ?? DateTime.now();

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${difference.inDays ~/ 365 > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays ~/ 30 > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Convert to JSON for Supabase (snake_case)
  /// For INSERT operations, id and created_at should be removed to let database handle them
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
    
    // Only include related_id if not null
    if (relatedId != null) {
      json['related_id'] = relatedId!;
    }
    
    return json;
  }

  /// Create from JSON from Supabase (snake_case)
  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        isRead: json['is_read'] as bool? ?? false,
        relatedId: json['related_id'] as String?,
      );

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    String? relatedId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
    );
  }
}

/// Helper to determine notification type display
class NotificationTypeHelper {
  static String getDisplayName(String type) {
    switch (type.toLowerCase()) {
      case 'event_reminder':
        return 'Event Reminder';
      case 'event_update':
        return 'Event Update';
      case 'announcement':
        return 'Announcement';
      case 'certificate':
        return 'Certificate';
      default:
        return 'Notification';
    }
  }
}
