import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/routes/route_names.dart';

class SelectEventScreen extends StatefulWidget {
  final String templateId;

  const SelectEventScreen({super.key, required this.templateId});

  @override
  State<SelectEventScreen> createState() => _SelectEventScreenState();
}

class _SelectEventScreenState extends State<SelectEventScreen> {
  String? _selectedEventId;

  // Sample events data
  final List<Map<String, dynamic>> _events = [
    {
      'id': 'event_1',
      'title': 'Classmeet 2026',
      'date': '15 Agustus 2026',
      'participants': 45,
      'hasGeneratedCerts': false,
      'category': 'Classmeet',
    },
    {
      'id': 'event_2',
      'title': 'Basketball Competition',
      'date': '10 Agustus 2026',
      'participants': 32,
      'hasGeneratedCerts': true,
      'category': 'Sports',
    },
    {
      'id': 'event_3',
      'title': 'Coding Workshop',
      'date': '5 Agustus 2026',
      'participants': 28,
      'hasGeneratedCerts': false,
      'category': 'Workshop',
    },
    {
      'id': 'event_4',
      'title': 'English Competition',
      'date': '1 Agustus 2026',
      'participants': 50,
      'hasGeneratedCerts': false,
      'category': 'Competition',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Select Event', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          // Info Card
          Container(
            margin: const EdgeInsets.all(AppSpacing.horizontalPadding),
            padding: const EdgeInsets.all(AppSpacing.paddingLG),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.info.withValues(alpha: 0.1),
                  AppColors.info.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select an event to generate certificates for all participants',
                    style: AppTextStyles.body2.copyWith(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),

          // Events List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return _buildEventCard(event);
              },
            ),
          ),

          // Bottom Action Button
          if (_selectedEventId != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
              decoration: BoxDecoration(
                color: AppColors.card,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton.icon(
                  onPressed: _handleGenerateCertificates,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate Certificates'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final isSelected = _selectedEventId == event['id'];
    final hasGeneratedCerts = event['hasGeneratedCerts'] as bool;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEventId = event['id'] as String;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.paddingMD),
        padding: const EdgeInsets.all(AppSpacing.paddingLG),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary10 : AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Selection Radio
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 2,
                    ),
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),

                // Event Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'] as String,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            event['date'] as String,
                            style: AppTextStyles.body2,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Already Generated Badge
                if (hasGeneratedCerts)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 12,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Generated',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Participants Count
            Row(
              children: [
                Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  '${event['participants']} participants',
                  style: AppTextStyles.body2,
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    event['category'] as String,
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // Warning if already generated
            if (hasGeneratedCerts) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Certificates already generated for this event',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleGenerateCertificates() {
    if (_selectedEventId == null) return;

    final selectedEvent = _events.firstWhere((e) => e['id'] == _selectedEventId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Generate Certificates', style: AppTextStyles.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to generate certificates for:',
              style: AppTextStyles.body1,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedEvent['title'] as String,
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${selectedEvent['participants']} certificates will be generated',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This process may take a few moments.',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showGeneratingDialog();
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _showGeneratingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Generating certificates...',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Simulate generation process
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pop(context); // Close generating dialog
      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    final selectedEvent = _events.firstWhere((e) => e['id'] == _selectedEventId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success),
            ),
            const SizedBox(width: 12),
            Text('Success!', style: AppTextStyles.heading3),
          ],
        ),
        content: Text(
          '${selectedEvent['participants']} certificates have been generated successfully for ${selectedEvent['title']}.',
          style: AppTextStyles.body1,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close success dialog
              context.go(RouteNames.adminCertificate); // Back to certificate screen
            },
            child: const Text('View Certificates'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(RouteNames.adminCertificate);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
