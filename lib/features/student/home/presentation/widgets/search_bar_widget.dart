import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/routes/route_names.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const SearchBarWidget({super.key, this.onTap});

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Search Events'),
        content: TextField(
          controller: searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter event name...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.pop(dialogContext);
              // Navigate to events screen with search query
              context.push('${RouteNames.events}?query=${Uri.encodeComponent(value.trim())}');
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final query = searchController.text.trim();
              if (query.isNotEmpty) {
                Navigator.pop(dialogContext);
                // Navigate to events screen with search query
                context.push('${RouteNames.events}?query=${Uri.encodeComponent(query)}');
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _showSearchDialog(context),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: AppColors.textTertiary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search events...',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
