import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class EventCard extends StatelessWidget {
  final String eventId;
  final String title;
  final String date;
  final String location;
  final String category;
  final String? imageUrl;
  final VoidCallback? onTap;
  final String? status; // 'open', 'ongoing', 'closed'
  final int? currentParticipants;
  final int? maxParticipants;

  const EventCard({
    super.key,
    required this.eventId,
    required this.title,
    required this.date,
    required this.location,
    required this.category,
    this.imageUrl,
    this.onTap,
    this.status = 'open',
    this.currentParticipants,
    this.maxParticipants,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image/Icon Section
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildCategoryEmoji(),
              ),
            ),

            const SizedBox(width: 12),

            // Content Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          date,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Participants Progress (if available)
                  if (currentParticipants != null && maxParticipants != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: currentParticipants! / maxParticipants!,
                              backgroundColor: AppColors.neutral100,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getCategoryColor(),
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$currentParticipants/$maxParticipants',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryEmoji() {
    // First priority: Use imageUrl if provided
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imageUrl!,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to category-based image
            return _buildCategoryBasedImage();
          },
        ),
      );
    }
    
    // Second priority: Use category-based images
    return _buildCategoryBasedImage();
  }

  Widget _buildCategoryBasedImage() {
    // Use local assets for event images with separate thumbnail files
    String? assetImage;
    
    final categoryLower = category.toLowerCase();
    
    // Match dengan category dari database
    if (categoryLower.contains('basketball') || categoryLower.contains('sport')) {
      assetImage = 'assets/images/thumbnail/basket-th.jpeg';
    } else if (categoryLower.contains('career') || categoryLower.contains('education')) {
      assetImage = 'assets/images/thumbnail/career-th.jpeg';
    } else if (categoryLower.contains('seminar') || categoryLower.contains('technology') || categoryLower.contains('ai')) {
      assetImage = 'assets/images/thumbnail/ai-th.jpeg';
    } else if (categoryLower.contains('workshop') || categoryLower.contains('coding')) {
      assetImage = 'assets/images/thumbnail/workshop-coding-th.jpeg';
    } else if (categoryLower.contains('classmeet') || categoryLower.contains('school')) {
      assetImage = 'assets/images/thumbnail/classmeet-th.jpeg';
    } else {
      assetImage = null; // Will show emoji fallback
    }

    if (assetImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          assetImage,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to emoji if image fails
            return _buildEmojiIcon();
          },
        ),
      );
    } else {
      return _buildEmojiIcon();
    }
  }

  Widget _buildEmojiIcon() {
    String emoji;
    switch (category.toLowerCase()) {
      case 'school event':
      case 'classmeet':
        emoji = '🏫';
        break;
      case 'sports competition':
        emoji = '🏀';
        break;
      case 'career development':
      case 'career day':
      case 'seminar':
        emoji = '�';
        break;
      case 'workshop':
        emoji = '�';
        break;
      case 'science fair':
        emoji = '🔬';
        break;
      default:
        emoji = '📅';
    }
    return Center(
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 32),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String label;

    switch (status?.toLowerCase()) {
      case 'open':
        bgColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        label = 'Open';
        break;
      case 'ongoing':
        bgColor = AppColors.info.withValues(alpha: 0.1);
        textColor = AppColors.info;
        label = 'Ongoing';
        break;
      case 'closed':
        bgColor = AppColors.neutral200;
        textColor = AppColors.textSecondary;
        label = 'Closed';
        break;
      default:
        bgColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        label = 'Open';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.captionSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (category.toLowerCase()) {
      case 'classmeet':
        return AppColors.categoryClassmeet;
      case 'sports competition':
        return AppColors.categorySports;
      case 'seminar':
        return AppColors.categorySeminar;
      case 'workshop':
        return AppColors.categoryWorkshop;
      case 'career day':
        return AppColors.categoryCareer;
      case 'science fair':
        return AppColors.categoryScience;
      default:
        return AppColors.primary;
    }
  }
}
