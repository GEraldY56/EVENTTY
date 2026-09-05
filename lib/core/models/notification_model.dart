/// Notification Model
/// Notification adalah alert otomatis dari sistem berdasarkan event/action
class NotificationModel {
  final String id;
  final String userId; // Student yang menerima
  final NotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? targetRoute; // Route untuk navigation
  final Map<String, String>? routeParams; // Parameters untuk route
  final String? referenceId; // ID dari entity terkait (eventId, newsId, etc)
  
  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    DateTime? createdAt,
    this.isRead = false,
    this.targetRoute,
    this.routeParams,
    this.referenceId,
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type.name,
        'title': title,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
        'targetRoute': targetRoute,
        'routeParams': routeParams,
        'referenceId': referenceId,
      };

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        type: NotificationType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => NotificationType.general,
        ),
        title: json['title'] as String,
        message: json['message'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isRead: json['isRead'] as bool? ?? false,
        targetRoute: json['targetRoute'] as String?,
        routeParams: json['routeParams'] != null
            ? Map<String, String>.from(json['routeParams'] as Map)
            : null,
        referenceId: json['referenceId'] as String?,
      );

  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    String? targetRoute,
    Map<String, String>? routeParams,
    String? referenceId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      targetRoute: targetRoute ?? this.targetRoute,
      routeParams: routeParams ?? this.routeParams,
      referenceId: referenceId ?? this.referenceId,
    );
  }
}

enum NotificationType {
  eventPublished,          // Event baru dipublish
  registrationOpened,      // Pendaftaran dibuka
  registrationApproved,    // Pendaftaran disetujui
  registrationRejected,    // Pendaftaran ditolak
  registrationClosed,      // Pendaftaran ditutup
  newsPublished,           // Pengumuman/news baru
  certificateAvailable,    // Sertifikat tersedia
  eventReminder,           // Reminder event
  eventCancelled,          // Event dibatalkan
  eventUpdated,            // Event diupdate
  general,                 // General notification
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.eventPublished:
        return 'New Event';
      case NotificationType.registrationOpened:
        return 'Registration Open';
      case NotificationType.registrationApproved:
        return 'Registration Approved';
      case NotificationType.registrationRejected:
        return 'Registration Rejected';
      case NotificationType.registrationClosed:
        return 'Registration Closed';
      case NotificationType.newsPublished:
        return 'New Announcement';
      case NotificationType.certificateAvailable:
        return 'Certificate Ready';
      case NotificationType.eventReminder:
        return 'Event Reminder';
      case NotificationType.eventCancelled:
        return 'Event Cancelled';
      case NotificationType.eventUpdated:
        return 'Event Updated';
      case NotificationType.general:
        return 'Notification';
    }
  }
}
