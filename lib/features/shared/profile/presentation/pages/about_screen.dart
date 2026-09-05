import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('About', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sectionGap),

            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary30,
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'E',
                  style: AppTextStyles.logo.copyWith(
                    color: Colors.white,
                    fontSize: 56,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // App Name
            Text(
              'EVENTY',
              style: AppTextStyles.heading1,
            ),

            const SizedBox(height: 8),

            // Tagline
            Text(
              'School Event Management System',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Version
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary10,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Version 1.0.0',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // Description Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.paddingXL),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About EVENTY',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'EVENTY is a modern and comprehensive school event management system designed to streamline the organization and participation of school activities.',
                    style: AppTextStyles.body1,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Features',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureItem('Event Discovery & Registration'),
                  _buildFeatureItem('Event Calendar & Reminders'),
                  _buildFeatureItem('Digital Certificate Generation'),
                  _buildFeatureItem('Event Gallery & Documentation'),
                  _buildFeatureItem('Real-time Notifications'),
                  _buildFeatureItem('Admin Dashboard & Analytics'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.paddingXL),

            // Development Team
            Container(
              padding: const EdgeInsets.all(AppSpacing.paddingXL),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Development Team',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 16),
                  _buildTeamMember('OSIS Team', 'Project Manager'),
                  _buildTeamMember('Development Team', 'Software Engineers'),
                  _buildTeamMember('Design Team', 'UI/UX Designers'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.paddingXL),

            // Tech Stack
            Container(
              padding: const EdgeInsets.all(AppSpacing.paddingXL),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Technology Stack',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 16),
                  _buildTechItem('Flutter', 'Cross-platform Framework'),
                  _buildTechItem('Riverpod', 'State Management'),
                  _buildTechItem('GoRouter', 'Navigation'),
                  _buildTechItem('Material Design 3', 'UI Components'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // Copyright
            Text(
              '© 2024 EVENTY\nAll rights reserved',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.sectionGap),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(String name, String role) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary10,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.titleMedium),
                Text(
                  role,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.categoryWorkshop10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.code,
              color: AppColors.categoryWorkshop,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.titleMedium),
                Text(
                  description,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
