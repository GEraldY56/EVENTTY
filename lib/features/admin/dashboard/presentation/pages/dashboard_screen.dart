import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/routes/route_names.dart';
import '../../../../../core/providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Decorative Background Elements
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.categoryClassmeet.withValues(alpha: 0.1),
                    AppColors.categoryClassmeet.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 150,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.success.withValues(alpha: 0.08),
                    AppColors.success.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.paddingLG),
                        Text(
                          'Dashboard',
                          style: AppTextStyles.heading1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Welcome back, ${authService.userName}',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.sectionGap),
                ),

                // Statistics Cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontalPadding,
                    ),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildStatCard(
                          'Total Events',
                          '24',
                          Icons.event,
                          AppColors.categoryClassmeet,
                        ),
                        _buildStatCard(
                          'Active Events',
                          '8',
                          Icons.event_available,
                          AppColors.success,
                        ),
                        _buildStatCard(
                          'Participants',
                          '456',
                          Icons.people,
                          AppColors.info,
                        ),
                        _buildStatCard(
                          'Pending',
                          '12',
                          Icons.pending,
                          AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.sectionGap),
                ),

                // Quick Menu
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Menu',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: AppSpacing.paddingLG),
                        
                        // Main Quick Menu (2x2 Grid)
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: [
                            _buildQuickMenuItem(
                              context,
                              'Buat Event',
                              Icons.add_circle,
                              AppColors.primary,
                              () => context.push(RouteNames.adminCreateEvent),
                            ),
                            _buildQuickMenuItem(
                              context,
                              'Pengumuman',
                              Icons.campaign,
                              AppColors.info,
                              () => context.go(RouteNames.adminAnnouncement),
                            ),
                            _buildQuickMenuItem(
                              context,
                              'Peserta',
                              Icons.people,
                              AppColors.success,
                              () => context.go(RouteNames.adminParticipants),
                            ),
                            _buildQuickMenuItem(
                              context,
                              'Sertifikat',
                              Icons.workspace_premium,
                              AppColors.secondary,
                              () => context.push(RouteNames.adminCertificate),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Secondary Access
                        Text(
                          'Akses Lainnya',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildSecondaryMenuItem(
                                context,
                                'Dokumentasi',
                                Icons.folder_open,
                                AppColors.categoryWorkshop,
                                () => context.push(RouteNames.adminDocumentation),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSecondaryMenuItem(
                                context,
                                'Messages',
                                Icons.message,
                                AppColors.categorySports,
                                () => context.push(RouteNames.adminMessages),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.sectionGap),
                ),

                // Today's Events
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontalPadding,
                    ),
                    child: Text(
                      "Today's Events",
                      style: AppTextStyles.heading3,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.paddingLG),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.horizontalPadding,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.paddingMD),
                          padding: const EdgeInsets.all(AppSpacing.paddingLG),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.primary10,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${6 + index}',
                                        style: AppTextStyles.heading3.copyWith(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Text(
                                        'AUG',
                                        style: AppTextStyles.captionSmall.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.paddingLG),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Event Today ${index + 1}',
                                      style: AppTextStyles.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '08:00 - 12:00 WIB',
                                      style: AppTextStyles.body2,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.success10,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Ongoing',
                                        style: AppTextStyles.captionSmall.copyWith(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.textTertiary,
                                size: 20,
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: 3,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.card,
            color.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(  
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: AppTextStyles.body2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenuItem(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: AppTextStyles.captionSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryMenuItem(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
