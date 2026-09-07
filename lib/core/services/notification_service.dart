import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../routes/route_names.dart';
import '../utils/logger.dart';

/// Notification Service
/// Membuat notification otomatis berdasarkan event/action
class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Stream controller untuk real-time updates
  final _notificationsController = StreamController<List<NotificationModel>>.broadcast();
  Stream<List<NotificationModel>> get notificationsStream => _notificationsController.stream;

  /// Get notifications untuk user tertentu dari Supabase
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('userId', userId)
          .order('createdAt', ascending: false);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching notifications', e);
      return [];
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('userId', userId)
          .eq('isRead', false);

      return (response as List).length;
    } catch (e) {
      AppLogger.error('Error fetching unread count', e);
      return 0;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'isRead': true})
          .eq('id', notificationId);
    } catch (e) {
      AppLogger.error('Error marking notification as read', e);
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'isRead': true})
          .eq('userId', userId)
          .eq('isRead', false);
    } catch (e) {
      AppLogger.error('Error marking all as read', e);
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      AppLogger.error('Error deleting notification', e);
    }
  }

  /// Create notification (internal method)
  Future<NotificationModel> _createNotification(NotificationModel notification) async {
    try {
      await _supabase
          .from('notifications')
          .insert(notification.toJson());
      
      _notifyUpdate(notification.userId);
      return notification;
    } catch (e) {
      AppLogger.error('Error creating notification', e);
      rethrow;
    }
  }

  /// Notify stream listeners
  void _notifyUpdate(String userId) async {
    try {
      final userNotifications = await getUserNotifications(userId);
      _notificationsController.add(userNotifications);
    } catch (e) {
      AppLogger.error('Error notifying update', e);
    }
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
      try {
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
      } catch (e) {
        AppLogger.error('Error notifying event published', e);
      }
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
      try {
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
      } catch (e) {
        AppLogger.error('Error notifying registration opened', e);
      }
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
      try {
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
      } catch (e) {
        AppLogger.error('Error notifying registration closed', e);
      }
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
      try {
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
      } catch (e) {
        AppLogger.error('Error notifying news published', e);
      }
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
      try {
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
      } catch (e) {
        AppLogger.error('Error notifying event cancelled', e);
      }
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
      try {
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
      } catch (e) {
        AppLogger.error('Error notifying event updated', e);
      }
    }
    
    return notifications;
  }

  /// Seed mock notifications (for testing only - remove in production)
  @Deprecated('Use real notifications from backend')
  void seedMockNotifications(String userId) {
    // This method is deprecated and should not be used
    // Notifications will be created automatically by backend actions
    AppLogger.warning('seedMockNotifications is deprecated');
  }

  /// Dispose
  void dispose() {
    _notificationsController.close();
  }
}
