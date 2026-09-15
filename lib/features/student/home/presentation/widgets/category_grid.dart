import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/routes/route_names.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/utils/category_mapper.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  static const List<Map<String, dynamic>> _categories = [
    {
      'name': 'Sekolah',
      'icon': Icons.school,
      'color': AppColors.categoryCareer,
      'value': CategoryMapper.sekolah,
    },
    {
      'name': 'Harian',
      'icon': Icons.today,
      'color': AppColors.categoryWorkshop,
      'value': CategoryMapper.harian,
    },
    {
      'name': 'Seminar',
      'icon': Icons.mic,
      'color': AppColors.categorySeminar,
      'value': CategoryMapper.seminar,
    },
    {
      'name': 'Workshop',
      'icon': Icons.construction,
      'color': AppColors.categoryWorkshop,
      'value': CategoryMapper.workshop,
    },
    {
      'name': 'Kompetisi',
      'icon': Icons.sports_basketball,
      'color': AppColors.categorySports,
      'value': CategoryMapper.kompetisi,
    },
    {
      'name': 'Lainnya',
      'icon': Icons.more_horiz,
      'color': AppColors.categoryScience,
      'value': CategoryMapper.lainnya,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryItem(context, _categories[index]);
        },
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, Map<String, dynamic> category) {
    return InkWell(
      onTap: () {
        // Navigate ke events screen dengan category filter
        context.push('${RouteNames.events}?category=${category['value']}');
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          border: Border.all(color: context.colors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (category['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
              ),
              child: Icon(
                category['icon'],
                color: category['color'],
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category['name'],
                style: AppTextStyles.captionSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                  fontSize: 11,
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
}
