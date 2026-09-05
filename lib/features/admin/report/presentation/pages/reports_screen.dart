import 'package:flutter/material.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../shared/widgets/app_button.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Reports', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
        children: [
          _buildReportCard(
            'Event Report',
            'Generate comprehensive report of all events',
            Icons.event_note,
            AppColors.categoryClassmeet,
            () {},
          ),
          const SizedBox(height: AppSpacing.paddingMD),
          _buildReportCard(
            'Participant Report',
            'Export list of all participants',
            Icons.people,
            AppColors.info,
            () {},
          ),
          const SizedBox(height: AppSpacing.paddingMD),
          _buildReportCard(
            'Attendance Report',
            'Track attendance for all events',
            Icons.check_circle,
            AppColors.success,
            () {},
          ),
          const SizedBox(height: AppSpacing.paddingMD),
          _buildReportCard(
            'Registration Report',
            'View registration statistics',
            Icons.app_registration,
            AppColors.secondary,
            () {},
          ),
          const SizedBox(height: AppSpacing.paddingMD),
          _buildReportCard(
            'Certificate Report',
            'Track issued certificates',
            Icons.workspace_premium,
            AppColors.warning,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingLG),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: AppSpacing.paddingLG),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.titleMedium),
                      const SizedBox(height: 4),
                      Text(description, style: AppTextStyles.body2),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingMD),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Export PDF',
                    isSmall: true,
                    icon: Icons.picture_as_pdf,
                    onPressed: onTap,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    text: 'Export Excel',
                    isSmall: true,
                    isOutlined: true,
                    icon: Icons.table_chart,
                    onPressed: onTap,
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
