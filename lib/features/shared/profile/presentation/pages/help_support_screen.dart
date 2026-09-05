import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Help & Support', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
        children: [
          const SizedBox(height: AppSpacing.paddingLG),

          // Contact Section
          Text(
            'Contact Us',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.paddingMD),

          _buildContactCard(
            context,
            'Email Support',
            'support@eventy.school.com',
            Icons.email_outlined,
            AppColors.primary,
          ),

          _buildContactCard(
            context,
            'Phone Support',
            '+62 812-3456-7890',
            Icons.phone_outlined,
            AppColors.success,
          ),

          _buildContactCard(
            context,
            'WhatsApp',
            '+62 812-3456-7890',
            Icons.chat_outlined,
            AppColors.categoryWorkshop,
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          // FAQ Section
          Text(
            'Frequently Asked Questions',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.paddingMD),

          _buildFaqItem(
            'How do I register for an event?',
            'Go to the Events page, select an event, and tap the "Register Now" button. You will receive a confirmation notification once registered.',
          ),

          _buildFaqItem(
            'How can I view my certificates?',
            'Navigate to the Certificate tab in the bottom navigation. All your earned certificates will be displayed there.',
          ),

          _buildFaqItem(
            'What if I forget my password?',
            'On the login screen, tap "Forgot Password?" and follow the instructions to reset your password via email.',
          ),

          _buildFaqItem(
            'How do I get my certificate?',
            'After completing an event, your certificate will be generated automatically. You can view and download it from the Certificate section.',
          ),

          _buildFaqItem(
            'Can I cancel my event registration?',
            'Yes, go to My Events, select the event, and tap "Cancel Registration". Note that some events may have cancellation deadlines.',
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          // About Section
          Text(
            'About EVENTY',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.paddingMD),

          Container(
            padding: const EdgeInsets.all(AppSpacing.paddingLG),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'E',
                          style: AppTextStyles.heading2.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EVENTY', style: AppTextStyles.heading3),
                        Text(
                          'Version 1.0.0',
                          style: AppTextStyles.body2,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'EVENTY is a comprehensive school event management system designed to help students and administrators organize, manage, and participate in school activities, competitions, seminars, and workshops.',
                  style: AppTextStyles.body1,
                ),
                const SizedBox(height: 12),
                Text(
                  '© 2024 EVENTY. All rights reserved.',
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

  Widget _buildContactCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: AppTextStyles.titleMedium),
        subtitle: Text(value, style: AppTextStyles.body2),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textTertiary,
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening $title...')),
          );
        },
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingLG,
            vertical: AppSpacing.paddingSM,
          ),
          title: Text(
            question,
            style: AppTextStyles.titleMedium,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.paddingLG,
                0,
                AppSpacing.paddingLG,
                AppSpacing.paddingLG,
              ),
              child: Text(
                answer,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
