import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
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
          .eq('user_id', userId)
          .order('created_at', ascending: false);

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
          .eq('user_id', userId)
          .eq('is_read', false);

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
          .update({'is_read': true})
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
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
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
  /// Uses RPC function to bypass RLS context issues
  Future<NotificationModel> _createNotification(NotificationModel notification) async {
    
    // Validate and refresh session if needed
    await _ensureValidSession();
    
    try {
      
      // Use RPC function instead of direct INSERT
      // This bypasses the RLS context issue (RPC works, REST INSERT doesn't)
      final response = await _supabase.rpc('create_notification', params: {
        'p_user_id': notification.userId,
        'p_type': notification.type,
        'p_title': notification.title,
        'p_message': notification.message,
        'p_related_id': notification.relatedId,
      });
      
      
      final createdNotification = NotificationModel.fromJson(response as Map<String, dynamic>);
      _notifyUpdate(notification.userId);
      return createdNotification;
    } on PostgrestException catch (e) {
      
      // Handle PGRST303 (JWT issued at future) - refresh and retry once
      if (e.code == 'PGRST303' || e.message.contains('JWT')) {
        await _refreshSession();
        
        final response = await _supabase.rpc('create_notification', params: {
          'p_user_id': notification.userId,
          'p_type': notification.type,
          'p_title': notification.title,
          'p_message': notification.message,
          'p_related_id': notification.relatedId,
        });
        
        
        final createdNotification = NotificationModel.fromJson(response as Map<String, dynamic>);
        _notifyUpdate(notification.userId);
        return createdNotification;
      }
      
      AppLogger.error('Error creating notification', e);
      rethrow;
    } catch (e) {
      AppLogger.error('Error creating notification', e);
      rethrow;
    }
  }
  
  /// Ensure session is valid before making authenticated requests
  Future<void> _ensureValidSession() async {
    final session = _supabase.auth.currentSession;
    
    if (session == null) {
      throw Exception('No active session');
    }
    
    // DEBUG: Check is_admin() result
    try {
      final isAdmin = await _supabase.rpc('is_admin');
      
      if (isAdmin != true) {
      }
    } catch (e) {
      // Log error but allow processing to continue
      AppLogger.error('Error checking admin status', e);
    }
    
    // Check if session is expired or near expiry (< 5 minutes)
    final expiresAt = session.expiresAt;
    if (expiresAt != null) {
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
      final now = DateTime.now();
      
      if (expiryTime.isBefore(now) || expiryTime.difference(now).inMinutes < 5) {
        await _refreshSession();
      }
    }
  }
  
  /// Refresh session
  Future<void> _refreshSession() async {
    try {
      final response = await _supabase.auth.refreshSession();
      if (response.session == null) {
        throw Exception('Session refresh failed');
      }
    } catch (e) {
      AppLogger.error('Error refreshing session', e);
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
            id: '', // Will be generated by database
            userId: userId,
            type: 'event_published',
            title: 'New Event Available',
            message: '$eventTitle is now open for registration!',
            relatedId: eventId,
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
            id: '', // Will be generated by database
            userId: userId,
            type: 'registration_opened',
            title: 'Registration Open',
            message: 'Registration for $eventTitle is now open. Don\'t miss out!',
            relatedId: eventId,
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
        id: '', // Will be generated by database
        userId: userId,
        type: 'registration_approved',
        title: 'Registration Approved ✓',
        message: 'Your registration for $eventTitle has been approved!',
        relatedId: eventId,
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
        id: '', // Will be generated by database
        userId: userId,
        type: 'registration_rejected',
        title: 'Registration Not Approved',
        message: 'Your registration for $eventTitle was not approved. ${reason ?? ''}',
        relatedId: eventId,
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
            id: '', // Will be generated by database
            userId: userId,
            type: 'registration_closed',
            title: 'Registration Closed',
            message: 'Registration for $eventTitle is now closed.',
            relatedId: eventId,
          ),
        );
        notifications.add(notification);
      } catch (e) {
        AppLogger.error('Error notifying registration closed', e);
      }
    }
    
    return notifications;
  }

  /// Create notification: Announcement baru (was News)
  Future<List<NotificationModel>> notifyAnnouncementPublished({
    required String announcementId,
    required String announcementTitle,
    required List<String> targetUserIds,
    required bool isPinned,
  }) async {
    
    final notifications = <NotificationModel>[];
    
    // Use different title based on pinned status for better user experience
    final notificationTitle = isPinned 
        ? 'Important Announcement' 
        : 'New Announcement';
    
    
    for (final userId in targetUserIds) {
      try {
        final notification = await _createNotification(
          NotificationModel(
            id: '', // Will be generated by database
            userId: userId,
            type: 'announcement',
            title: notificationTitle,
            message: announcementTitle,
            relatedId: announcementId,
          ),
        );
        notifications.add(notification);
      } catch (e) {
        AppLogger.error('Error notifying announcement published for user $userId', e);
        // Continue with other users even if one fails
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
        id: '', // Will be generated by database
        userId: userId,
        type: 'certificate',
        title: 'Certificate Ready 🎓',
        message: 'Your certificate for $eventTitle is now available!',
        relatedId: certificateId,
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
        id: '', // Will be generated by database
        userId: userId,
        type: 'event_reminder',
        title: 'Event Reminder',
        message: '$eventTitle starts tomorrow! Don\'t forget to attend.',
        relatedId: eventId,
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
            id: '', // Will be generated by database
            userId: userId,
            type: 'event_cancelled',
            title: 'Event Cancelled',
            message: '$eventTitle has been cancelled. ${reason ?? ''}',
            relatedId: eventId,
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
            id: '', // Will be generated by database
            userId: userId,
            type: 'event_update',
            title: 'Event Updated',
            message: '$eventTitle: $updateMessage',
            relatedId: eventId,
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
