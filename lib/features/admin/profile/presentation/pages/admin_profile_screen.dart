import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/routes/route_names.dart';
import '../../../../../main.dart';

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.heading3),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // Admin notification navigation
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image Header
          _buildBackgroundHeader(),
          
          // Scrollable Content
          _buildScrollableContent(authService, context),
        ],
      ),
    );
  }

  // Background Header Widget
  Widget _buildBackgroundHeader() {
    return SizedBox(
      height: 280,
      child: Image.asset(
        'assets/images/profile.png',
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          );
        },
      ),
    );
  }

  // Scrollable Content Widget
  Widget _buildScrollableContent(dynamic authService, BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 120),
        
        // Profile Card
        _buildProfileCard(authService),
        const SizedBox(height: 24),
        
        // Statistics Section
        _buildStatisticsSection(),
        const SizedBox(height: 24),
        
        // Settings Section
        _buildSettingsSection(authService, context),
        const SizedBox(height: 32),
      ],
    );
  }

  // Profile Card Widget
  Widget _buildProfileCard(dynamic authService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.paddingXL),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 38,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/profile.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          authService.userName?.substring(0, 1).toUpperCase() ?? 'A',
                          style: AppTextStyles.heading1.copyWith(
                            color: Colors.white,
                            fontSize: 32,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Info Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Name
                  Text(
                    authService.userName ?? 'Admin',
                    style: AppTextStyles.heading3.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  
                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.admin_panel_settings,
                          size: 12,
                          color: Color(0xFF8B5CF6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ADMIN - OSIS',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: const Color(0xFF8B5CF6),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // User Email
                  Text(
                    'admin@school.com',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Statistics Section Widget
  Widget _buildStatisticsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Events Created',
              '24',
              Icons.event_outlined,
              const Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Active Events',
              '12',
              Icons.event_available_outlined,
              const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Announcements',
              '18',
              Icons.campaign_outlined,
              const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Reports',
              '32',
              Icons.assessment_outlined,
              const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }

  // Settings Section Widget
  Widget _buildSettingsSection(dynamic authService, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Account Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
          child: Text(
            'Account',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildMenuItemInCard(Icons.person_outline, 'Edit Profile', () {
                  context.push(RouteNames.editProfile);
                }, isFirst: true),
                Divider(height: 1, color: AppColors.border),
                _buildMenuItemInCard(Icons.lock_outline, 'Change Password', () {
                  context.push(RouteNames.changePassword);
                }),
                Divider(height: 1, color: AppColors.border),
                _buildMenuItemInCard(Icons.settings_outlined, 'Settings', () {
                  context.push(RouteNames.settings);
                }, isLast: true),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Support Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
          child: Text(
            'Support',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildMenuItemInCard(Icons.help_outline, 'Help & Support', () {
                  context.push(RouteNames.helpSupport);
                }, isFirst: true),
                Divider(height: 1, color: AppColors.border),
                _buildMenuItemInCard(Icons.info_outline, 'About Eventty', () {
                  context.push(RouteNames.about);
                }, isLast: true),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Logout Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
              border: Border.all(color: AppColors.border),
            ),
            child: _buildMenuItemInCard(
              Icons.logout,
              'Logout',
              () async {
                await authService.logout();
                if (context.mounted) {
                  context.go(RouteNames.login);
                }
              },
              isDestructive: true,
              isFirst: true,
              isLast: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          // Value
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          // Title
          Text(
            title,
            style: AppTextStyles.captionSmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemInCard(IconData icon, String title, VoidCallback onTap,
      {bool isDestructive = false, bool isFirst = false, bool isLast = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(AppSpacing.radiusLG) : Radius.zero,
        bottom: isLast ? const Radius.circular(AppSpacing.radiusLG) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDestructive 
                    ? AppColors.error.withValues(alpha: 0.1)
                    : const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isDestructive ? AppColors.error : const Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body1.copyWith(
                  color: isDestructive ? AppColors.error : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
