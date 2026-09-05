import 'package:flutter/material.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../widgets/certificate_preview_widget.dart';

class TemplatePreviewScreen extends StatelessWidget {
  final String templateId;

  const TemplatePreviewScreen({super.key, required this.templateId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Template Preview', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit template
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit template feature')),
              );
            },
            tooltip: 'Edit Template',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Template downloaded')),
              );
            },
            tooltip: 'Download Sample',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template Info
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
                  Text('Modern Template', style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  Text(
                    'Clean and modern certificate design with elegant typography',
                    style: AppTextStyles.body2,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(Icons.auto_awesome, 'Modern Layout', AppColors.info),
                      _buildInfoChip(Icons.palette, 'Custom Colors', AppColors.success),
                      _buildInfoChip(Icons.border_all, 'With Border', AppColors.primary),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Preview Label
            Text('Preview', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            Text(
              'This is how the certificate will look with sample data',
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            ),
            
            const SizedBox(height: 16),
            
            // Certificate Preview
            CertificatePreviewWidget(
              templateId: templateId,
              participantName: 'MUHAMMAD FAQIH',
              eventTitle: 'CLASSMEET 2026',
              eventDate: '15 Agustus 2026',
              certificateNumber: 'CERT-2026-001',
            ),
            
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Close'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showUseTemplateDialog(context);
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Use Template'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showUseTemplateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Use This Template', style: AppTextStyles.heading3),
        content: Text(
          'Would you like to use this template to generate certificates?',
          style: AppTextStyles.body1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Back to certificate screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Template selected. Select an event to generate certificates.'),
                ),
              );
            },
            child: const Text('Use Template'),
          ),
        ],
      ),
    );
  }
}
