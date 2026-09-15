import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/routes/route_names.dart';
import '../../../../../core/services/notification_service.dart';

class HomeHeader extends StatelessWidget {
  final String userName;

  const HomeHeader({super.key, required this.userName});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning 👋';
    } else if (hour < 17) {
      return 'Good Afternoon ☀️';
    } else if (hour < 20) {
      return 'Good Evening 🌆';
    } else {
      return 'Good Night 🌙';
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPadding,
        vertical: AppSpacing.paddingLG,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Avatar - Logo
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary20,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/logo.jpeg',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to gradient with initial
                    return Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                          style: AppTextStyles.heading3.copyWith(
                            color: Colors.white, // Keep white on gradient
                            fontSize: 20,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Greeting & Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getGreeting(),
                        style: AppTextStyles.greeting,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userName,
                    style: AppTextStyles.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getCurrentDate(),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Row(
              children: [
                _buildNotificationButton(context),
                const SizedBox(width: 8),
                _buildIconButton(
                  icon: Icons.bookmark_border_rounded,
                  onTap: () {
                    context.push(RouteNames.myEvents);
                  },
                  context: context,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build notification button with dynamic badge
  Widget _buildNotificationButton(BuildContext context) {
    return FutureBuilder<int>(
      future: _getUnreadNotificationCount(),
      builder: (context, snapshot) {
        // Default to 0 if loading or error
        final unreadCount = snapshot.data ?? 0;
        
        return _buildIconButton(
          icon: Icons.notifications_outlined,
          onTap: () {
            context.push(RouteNames.notification);
          },
          badge: unreadCount > 0 ? unreadCount : null,
          context: context,
        );
      },
    );
  }

  /// Get unread notification count from service
  Future<int> _getUnreadNotificationCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null || userId.isEmpty) {
        return 0;
      }
      
      final notificationService = NotificationService();
      return await notificationService.getUnreadCount(userId);
    } catch (e) {
      // Silent fail - don't crash Home if notification count fails
      return 0;
    }
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    int? badge,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
            if (badge != null && badge > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colors.background, width: 1.5),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      badge > 9 ? '9+' : '$badge',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: Colors.white, // Keep white on red badge
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
