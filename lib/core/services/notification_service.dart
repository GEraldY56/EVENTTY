import 'dart:async';
import '../models/notification_model.dart';
import '../routes/route_names.dart';

/// Notification Service
/// Membuat notification otomatis berdasarkan event/action
class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // In-memory storage
  final List<NotificationModel> _notifications = [];
  
  // Stream controller untuk real-time updates
  final _notificationsController = StreamController<List<NotificationModel>>.broadcast();
  Stream<List<NotificationModel>> get notificationsStream => _notificationsController.stream;

  /// Get notifications untuk user tertentu
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _notifications.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get unread notifications count
  Future<int> getUnreadCount(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _notifications.where((n) => n.userId == userId && !n.isRead).length;
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notifyUpdate(_notifications[index].userId);
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    for (var i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId && !_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    _notifyUpdate(userId);
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    final notification = _notifications.firstWhere((n) => n.id == notificationId);
    _notifications.removeWhere((n) => n.id == notificationId);
    _notifyUpdate(notification.userId);
  }

  /// Create notification (internal method)
  Future<NotificationModel> _createNotification(NotificationModel notification) async {
    _notifications.add(notification);
    _notifyUpdate(notification.userId);
    return notification;
  }

  /// Notify stream listeners
  void _notifyUpdate(String userId) {
    final userNotifications = _notifications.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _notificationsController.add(userNotifications);
  }

  // ==================== NOTIFICATION CREATORS ====================
  // Methods untuk create notification otomatis berdasarkan action

  /// Create notification: Event baru dipublish
  Future<List<NotificationModel>> notifyEventPublished({
    required String eventId,
    required String eventTitle,
    required List<String> targetUserIds, // Semua student
  }) async {
    final notifications = <NotificationModel>[];
    
    for (final userId in targetUserIds) {
      final notification = await _createNotification(
        NotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}_$userId',
          userId: userId,
          type: NotificationType.eventPublished,
          title: 'New Event Available',
          message: '$eventTitle is now open for registration!',
          targetRoute: RouteNames.eventDetail,
          routeParams: {'id': eventId},
          referenceId: eventId,
        ),
      );
      notifications.add(notification);
    }
    
    return notifications;
  }

  /// Create notification: Pendaftaran dibuka
  Future<List<NotificationModel>> notifyRegistrationOpened({
    required String eventId,
    required String eventTitle,
    required List<String> targetUserIds,
  }) async {
    final notifications = <NotificationModel>[];
    
    for (final userId in targetUserIds) {
      final notification = await _createNotification(
        NotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}_$userId',
          userId: userId,
          type: NotificationType.registrationOpened,
          title: 'Registration Open',
          message: 'Registration for $eventTitle is now open. Don\'t miss out!',
          targetRoute: RouteNames.eventDetail,
          routeParams: {'id': eventId},
          referenceId: eventId,
        ),
      );
      notifications.add(notification);
    }
    
    return notifications;
  }

  /// Create notification: Pendaftaran disetujui
  Future<NotificationModel> notifyRegistrationApproved({
    required String userId,
    required String eventId,
    required String eventTitle,
  }) async {
    return await _createNotification(
      NotificationModel(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}_$userId',
        userId: userId,
        type: NotificationType.registrationApproved,
        title: 'Registration Approved ✓',
        message: 'Your registration for $eventTitle has been approved!',
        targetRoute: RouteNames.myEvents,
        routeParams: {},
        referenceId: eventId,
      ),
    );
  }

  /// Create notification: Pendaftaran ditolak
  Future<NotificationModel> notifyRegistrationRejected({
    required String userId,
    required String eventId,
    required String eventTitle,
    String? reason,
  }) async {
    return await _createNotification(
      NotificationModel(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}_$userId',
        userId: userId,
        type: NotificationType.registrationRejected,
        title: 'Registration Not Approved',
        message: 'Your registration for $eventTitle was not approved. ${reason ?? ''}',
        targetRoute: RouteNames.events,
        routeParams: {},
        referenceId: eventId,
      ),
    );
  }

  /// Create notification: Pendaftaran ditutup
  Future<List<NotificationModel>> notifyRegistrationClosed({
    required String eventId,
    required String eventTitle,
    required List<String> targetUserIds, // Peserta yang sudah daftar
  }) async {
    final notifications = <NotificationModel>[];
    
    for (final userId in targetUserIds) {
      final notification = await _createNotification(
        NotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}_$userId',
          userId: userId,
          type: NotificationType.registrationClosed,
          title: 'Registration Closed',
          message: 'Registration for $eventTitle is now closed.',
          targetRoute: RouteNames.eventDetail,
          routeParams: {'id': eventId},
          referenceId: eventId,
        ),
      );
      notifications.add(notification);
    }
    
    return notifications;
  }

  /// Create notification: News/Pengumuman baru
  Future<List<NotificationModel>> notifyNewsPublished({
    required String newsId,
    required String newsTitle,
    required List<String> targetUserIds,
    required bool isImportant,
  }) async {
    // Hanya create notification jika news important
    if (!isImportant) return [];
    
    final notifications = <NotificationModel>[];
    
    for (final userId in targetUserIds) {
      final notification = await _createNotification(
        NotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}_$userId',
          userId: userId,
          type: NotificationType.newsPublished,
          title: 'Important Announcement',
          message: newsTitle,
          targetRoute: RouteNames.newsDetail,
          routeParams: {'id': newsId},
          referenceId: newsId,
        ),
      );
      notifications.add(notification);
    }
    
    return notifications;
  }

  /// Create notification: Sertifikat tersedia
  Future<NotificationModel> notifyCertificateAvailable({
    required String userId,
    required String certificateId,
    required String eventTitle,
  }) async {
    return await _createNotification(
      NotificationModel(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}_$userId',
        userId: userId,
        type: NotificationType.certificateAvailable,
        title: 'Certificate Ready 🎓',
        message: 'Your certificate for $eventTitle is now available!',
        targetRoute: RouteNames.certificate,
        routeParams: {},
        referenceId: certificateId,
      ),
    );
  }

  /// Create notification: Event reminder (1 hari sebelum event)
  Future<NotificationModel> notifyEventReminder({
    required String userId,
    required String eventId,
    required String eventTitle,
    required DateTime eventDate,
  }) async {
    return await _createNotification(
      NotificationModel(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}_$userId',
        userId: userId,
        type: NotificationType.eventReminder,
        title: 'Event Reminder',
        message: '$eventTitle starts tomorrow! Don\'t forget to attend.',
        targetRoute: RouteNames.eventDetail,
        routeParams: {'id': eventId},
        referenceId: eventId,
      ),
    );
  }

  /// Create notification: Event cancelled
  Future<List<NotificationModel>> notifyEventCancelled({
    required String eventId,
    required String eventTitle,
    required List<String> targetUserIds,
    String? reason,
  }) async {
    final notifications = <NotificationModel>[];
    
    for (final userId in targetUserIds) {
      final notification = await _createNotification(
        NotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}_$userId',
          userId: userId,
          type: NotificationType.eventCancelled,
          title: 'Event Cancelled',
          message: '$eventTitle has been cancelled. ${reason ?? ''}',
          targetRoute: RouteNames.events,
          routeParams: {},
          referenceId: eventId,
        ),
      );
      notifications.add(notification);
    }
    
    return notifications;
  }

  /// Create notification: Event updated
  Future<List<NotificationModel>> notifyEventUpdated({
    required String eventId,
    required String eventTitle,
    required List<String> targetUserIds,
    required String updateMessage,
  }) async {
    final notifications = <NotificationModel>[];
    
    for (final userId in targetUserIds) {
      final notification = await _createNotification(
        NotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}_$userId',
          userId: userId,
          type: NotificationType.eventUpdated,
          title: 'Event Updated',
          message: '$eventTitle: $updateMessage',
          targetRoute: RouteNames.eventDetail,
          routeParams: {'id': eventId},
          referenceId: eventId,
        ),
      );
      notifications.add(notification);
    }
    
    return notifications;
  }

  /// Seed mock notifications
  void seedMockNotifications(String userId) {
    final now = DateTime.now();
    
    _notifications.addAll([
      NotificationModel(
        id: 'notif_1',
        userId: userId,
        type: NotificationType.registrationApproved,
        title: 'Registration Approved ✓',
        message: 'Your registration for Career Day 2027 has been approved!',
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
        targetRoute: RouteNames.myEvents,
        routeParams: {},
        referenceId: '2',
      ),
      NotificationModel(
        id: 'notif_2',
        userId: userId,
        type: NotificationType.newsPublished,
        title: 'Important Announcement',
        message: 'Final Exam Schedule Released - Check the details now',
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: false,
        targetRoute: RouteNames.newsDetail,
        routeParams: {'id': 'news_2'},
        referenceId: 'news_2',
      ),
      NotificationModel(
        id: 'notif_3',
        userId: userId,
        type: NotificationType.certificateAvailable,
        title: 'Certificate Ready 🎓',
        message: 'Your certificate for Basketball Tournament is now available!',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: false,
        targetRoute: RouteNames.certificate,
        routeParams: {},
        referenceId: 'cert_1',
      ),
      NotificationModel(
        id: 'notif_4',
        userId: userId,
        type: NotificationType.eventReminder,
        title: 'Event Reminder',
        message: 'AI Seminar starts in 2 days! Don\'t forget to attend.',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        isRead: true,
        targetRoute: RouteNames.eventDetail,
        routeParams: {'id': '4'},
        referenceId: '4',
      ),
      NotificationModel(
        id: 'notif_5',
        userId: userId,
        type: NotificationType.eventPublished,
        title: 'New Event Available',
        message: 'Coding Workshop is now open for registration!',
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
        targetRoute: RouteNames.eventDetail,
        routeParams: {'id': '5'},
        referenceId: '5',
      ),
    ]);
    
    _notifyUpdate(userId);
  }

  /// Dispose
  void dispose() {
    _notificationsController.close();
  }
}
