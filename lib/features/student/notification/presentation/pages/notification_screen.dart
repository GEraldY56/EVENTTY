import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../core/models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    // Get user ID from shared preferences
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId') ?? '12345';
    
    // Load notifications from Supabase
    _notifications = await _notificationService.getUserNotifications(_userId);
    
    setState(() => _isLoading = false);
  }

  Future<void> _handleNotificationTap(NotificationModel notification) async {
    // Mark as read
    if (!notification.isRead) {
      await _notificationService.markAsRead(notification.id);
      await _loadNotifications(); // Reload to update UI
    }
    
    // Navigate based on notification type and relatedId (frontend logic)
    if (mounted) {
      _navigateToTarget(notification);
    }
  }

  void _navigateToTarget(NotificationModel notification) {
    // Determine route based on notification type
    switch (notification.type) {
      case 'event_published':
      case 'registration_opened':
      case 'event_reminder':
      case 'event_update':
      case 'event_cancelled':
        // Navigate to event detail
        if (notification.relatedId != null) {
          context.push('/events/${notification.relatedId}');
        }
        break;

      case 'registration_approved':
      case 'registration_rejected':
        // Navigate to my events
        context.push('/my-events');
        break;

      case 'certificate':
        // Navigate to certificates
        context.push('/certificate');
        break;

      case 'announcement':
        // Navigate to news detail if has relatedId, otherwise news list
        if (notification.relatedId != null) {
          context.push('/news/${notification.relatedId}');
        } else {
          context.push('/news');
        }
        break;

      default:
        // No navigation for other types
        break;
    }
  }

  Future<void> _handleMarkAllAsRead() async {
    await _notificationService.markAllAsRead(_userId);
    await _loadNotifications();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_notifications.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Notifications', style: AppTextStyles.heading3),
          ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_off_outlined,
                size: 80,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'No Notifications',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'re all caught up!',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications', style: AppTextStyles.heading3),
            if (unreadCount > 0)
              Text(
                '$unreadCount unread',
                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              ),
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _handleMarkAllAsRead,
              child: Text(
                'Mark all read',
                style: AppTextStyles.body2.copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final notification = _notifications[index];
            return _buildNotificationCard(notification);
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return GestureDetector(
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.paddingMD),
        padding: const EdgeInsets.all(AppSpacing.paddingLG),
        decoration: BoxDecoration(
          color: !notification.isRead 
              ? const Color(0x0D2563EB) 
              : AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          border: Border.all(
            color: !notification.isRead 
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.border,
          ),
          boxShadow: [
            if (!notification.isRead)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: _getNotificationColor(notification.type),
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.paddingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: !notification.isRead 
                                ? FontWeight.w600 
                                : FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        notification.timeAgo,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      // All notifications can be tapped, no need for indicator
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap to view',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'event_published':
        return Icons.event_rounded;
      case 'registration_opened':
        return Icons.how_to_reg_rounded;
      case 'registration_approved':
        return Icons.check_circle_rounded;
      case 'registration_rejected':
        return Icons.cancel_rounded;
      case 'registration_closed':
        return Icons.event_busy_rounded;
      case 'announcement':
        return Icons.campaign_rounded;
      case 'certificate':
        return Icons.workspace_premium_rounded;
      case 'event_reminder':
        return Icons.alarm_rounded;
      case 'event_cancelled':
        return Icons.event_busy_rounded;
      case 'event_update':
        return Icons.update_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'event_published':
      case 'registration_opened':
        return AppColors.info;
      case 'registration_approved':
      case 'certificate':
        return AppColors.success;
      case 'registration_rejected':
      case 'event_cancelled':
        return AppColors.error;
      case 'registration_closed':
        return AppColors.warning;
      case 'announcement':
        return AppColors.secondary;
      case 'event_reminder':
      case 'event_update':
        return AppColors.primary;
      default:
        return AppColors.neutral400;
    }
  }
}
