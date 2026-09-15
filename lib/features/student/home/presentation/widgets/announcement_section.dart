import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/services/announcement_service.dart';
import '../../../../../core/models/announcement_model.dart';

class AnnouncementSection extends StatelessWidget {
  const AnnouncementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
      sliver: FutureBuilder<List<AnnouncementModel>>(
        future: _fetchAnnouncements(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildLoadingCard(),
                childCount: 2,
              ),
            );
          }

          // Error state - show nothing, don't crash Home
          if (snapshot.hasError) {
            return SliverToBoxAdapter(child: SizedBox.shrink());
          }

          final announcements = snapshot.data ?? [];

          // Empty state - show nothing
          if (announcements.isEmpty) {
            return SliverToBoxAdapter(child: SizedBox.shrink());
          }

          // Success - show announcements
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final announcement = announcements[index];
                return _buildAnnouncementCard(context, announcement);
              },
              childCount: announcements.length,
            ),
          );
        },
      ),
    );
  }

  /// Fetch published announcements from Supabase
  Future<List<AnnouncementModel>> _fetchAnnouncements() async {
    try {
      final service = AnnouncementService();
      // Limit to 3 latest announcements for Home
      return await service.getPublishedAnnouncements(limit: 3);
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.paddingLG),
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            ),
          ),
          const SizedBox(width: AppSpacing.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, AnnouncementModel announcement) {
    return GestureDetector(
      onTap: () {
        // Navigate to news detail
        context.push('/news/${announcement.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.paddingLG),
        padding: const EdgeInsets.all(AppSpacing.paddingLG),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getPriorityColor(announcement.priority).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
              ),
              child: Icon(
                announcement.isPinned ? Icons.push_pin : Icons.campaign,
                color: _getPriorityColor(announcement.priority),
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.paddingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    style: AppTextStyles.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    announcement.getTimeAgo(),
                    style: AppTextStyles.caption,
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
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.info;
      default:
        return AppColors.info;
    }
  }
}
