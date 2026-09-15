import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/routes/route_names.dart';
import '../../../../../core/providers/auth_provider.dart';
import '../../../../../core/providers/theme_provider.dart';
import '../../../../../core/services/avatar_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
              context.push(RouteNames.notification);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image Header
          _buildBackgroundHeader(),
          
          // Scrollable Content
          _buildScrollableContent(authService, context, ref),
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
  Widget _buildScrollableContent(dynamic authService, BuildContext context, WidgetRef ref) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 120),
        
        // Profile Card
        _buildProfileCard(authService, context),
        const SizedBox(height: 24),
        
        // Statistics Section
        _buildStatisticsSection(context),
        const SizedBox(height: 24),
        
        // Settings Section
        _buildSettingsSection(authService, context, ref),
        const SizedBox(height: 32),
      ],
    );
  }

  // Profile Card Widget
  Widget _buildProfileCard(dynamic authService, BuildContext context) {
    final colors = context.colors;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.paddingXL),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: colors.border, width: 2),
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
            // AI Avatar
            CircleAvatar(
              radius: 38,
              backgroundColor: colors.surface,
              child: ClipOval(
                child: SvgPicture.network(
                  AvatarService().generateConsistentAvatarUrl(
                    userId: authService.userId ?? 'default',
                    userName: authService.userName ?? 'User',
                    size: 200,
                  ),
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  placeholderBuilder: (context) => Container(
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
                        authService.userName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: AppTextStyles.heading1.copyWith(
                          color: Colors.white, // Keep white on gradient background
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
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
                    authService.userName ?? 'User',
                    style: AppTextStyles.heading3.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Class Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.school,
                          size: 14,
                          color: Color(0xFF8B5CF6),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          authService.userClass ?? 'Kelas belum diatur',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: const Color(0xFF8B5CF6),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // User Email
                  Text(
                    authService.userEmail ?? 'Email belum tersedia',
                    style: AppTextStyles.body2.copyWith(
                      color: colors.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
  Widget _buildStatisticsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
      child: Column(
        children: [
          // First Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Events',
                  '12',
                  Icons.event_available_outlined,
                  const Color(0xFF8B5CF6),
                  context,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Certificates',
                  '8',
                  Icons.workspace_premium_outlined,
                  const Color(0xFFF59E0B),
                  context,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Second Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Attendance',
                  '95%',
                  Icons.verified_outlined,
                  const Color(0xFF10B981),
                  context,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Points',
                  '1,450',
                  Icons.stars_outlined,
                  const Color(0xFF8B5CF6),
                  context,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Settings Section Widget
  Widget _buildSettingsSection(dynamic authService, BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Account Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
          child: Text(
            'Account',
            style: AppTextStyles.body2.copyWith(
              color: colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
          child: Container(
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: [
                _buildMenuItemInCard(Icons.person_outline, 'Edit Profile', () {
                  context.push(RouteNames.editProfile);
                }, context, isFirst: true),
                Divider(height: 1, color: colors.border),
                _buildThemeToggle(ref),
                Divider(height: 1, color: colors.border),
                _buildMenuItemInCard(Icons.lock_outline, 'Change Password', () {
                  context.push(RouteNames.changePassword);
                }, context),
                Divider(height: 1, color: colors.border),
                _buildMenuItemInCard(Icons.settings_outlined, 'Settings', () {
                  context.push(RouteNames.settings);
                }, context, isLast: true),
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
              color: colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
          child: Container(
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: [
                _buildMenuItemInCard(Icons.help_outline, 'Help & Support', () {
                  context.push(RouteNames.helpSupport);
                }, context, isFirst: true),
                Divider(height: 1, color: colors.border),
                _buildMenuItemInCard(Icons.info_outline, 'About Eventty', () {
                  context.push(RouteNames.about);
                }, context, isLast: true),
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
              color: colors.card,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
              border: Border.all(color: colors.border),
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
              context,
              isDestructive: true,
              isFirst: true,
              isLast: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, BuildContext context) {
    final colors = context.colors;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          // Value
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          // Title
          Text(
            title,
            style: AppTextStyles.captionSmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Theme Toggle Widget
  Widget _buildThemeToggle(WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final currentBrightness = Theme.of(ref.context).brightness;
    
    return InkWell(
      onTap: () {
        ref.read(themeModeProvider.notifier).toggleTheme();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: currentBrightness == Brightness.dark
                    ? const Color(0xFF60A5FA).withValues(alpha: 0.2)
                    : const Color(0xFF2563EB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: currentBrightness == Brightness.dark
                    ? const Color(0xFF60A5FA)
                    : const Color(0xFF2563EB),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Dark Mode',
                style: AppTextStyles.body1.copyWith(
                  color: ref.context.colors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            Switch.adaptive(
              value: isDarkMode,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).toggleTheme();
              },
              activeColor: currentBrightness == Brightness.dark
                  ? const Color(0xFF60A5FA)
                  : const Color(0xFF2563EB),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemInCard(IconData icon, String title, VoidCallback onTap, BuildContext context,
      {bool isDestructive = false, bool isFirst = false, bool isLast = false}) {
    final colors = context.colors;
    
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
                  color: isDestructive ? AppColors.error : colors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
