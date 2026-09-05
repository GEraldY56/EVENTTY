import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/models/event_model.dart';

class EventTimelineScreen extends StatelessWidget {
  final EventModel event;

  const EventTimelineScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final timelineItems = _generateTimeline();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Timeline Event',
          style: AppTextStyles.heading3,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Title
            Text(
              event.title,
              style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Jadwal lengkap rangkaian event',
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            ),
            
            const SizedBox(height: 32),
            
            // Timeline
            ...timelineItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == timelineItems.length - 1;
              
              return _buildTimelineItem(
                title: item['title']!,
                date: item['date']!,
                description: item['description']!,
                icon: item['icon'] as IconData,
                color: item['color'] as Color,
                isLast: isLast,
                isActive: item['isActive'] as bool,
              );
            }),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateTimeline() {
    final now = DateTime.now();
    final eventDate = DateFormat('d MMMM yyyy').format(event.date);
    final eventDay = DateFormat('EEEE', 'id_ID').format(event.date);
    final deadlineDate = event.date.subtract(const Duration(days: 3));
    final deadline = DateFormat('d MMMM yyyy').format(deadlineDate);
    
    return [
      {
        'title': 'Pendaftaran Dibuka',
        'date': DateFormat('d MMMM yyyy').format(now.subtract(const Duration(days: 7))),
        'description': 'Pendaftaran peserta dibuka untuk umum',
        'icon': Icons.how_to_reg,
        'color': Colors.green,
        'isActive': event.status == 'open',
      },
      {
        'title': 'Pendaftaran Ditutup',
        'date': deadline,
        'description': 'Batas akhir pendaftaran peserta',
        'icon': Icons.event_busy,
        'color': Colors.orange,
        'isActive': false,
      },
      {
        'title': 'Technical Meeting',
        'date': DateFormat('d MMMM yyyy').format(event.date.subtract(const Duration(days: 1))),
        'description': 'Briefing teknis untuk semua peserta',
        'icon': Icons.groups,
        'color': Colors.blue,
        'isActive': false,
      },
      {
        'title': 'Hari Pelaksanaan',
        'date': '$eventDay, $eventDate',
        'description': 'Event berlangsung - ${event.time}',
        'icon': Icons.celebration,
        'color': Colors.purple,
        'isActive': false,
      },
      {
        'title': 'Pengumuman Pemenang',
        'date': DateFormat('d MMMM yyyy').format(event.date.add(const Duration(days: 2))),
        'description': 'Pengumuman hasil dan pemenang',
        'icon': Icons.emoji_events,
        'color': Colors.amber,
        'isActive': false,
      },
    ];
  }

  Widget _buildTimelineItem({
    required String title,
    required String date,
    required String description,
    required IconData icon,
    required Color color,
    required bool isLast,
    required bool isActive,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line with icon
        Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isActive ? color : color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? color : color.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : color.withValues(alpha: 0.7),
                size: 24,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80,
                color: color.withValues(alpha: 0.3),
              ),
          ],
        ),
        
        const SizedBox(width: 16),
        
        // Timeline content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive 
                  ? color.withValues(alpha: 0.1)
                  : AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? color.withValues(alpha: 0.3)
                    : AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isActive ? color : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Aktif',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
