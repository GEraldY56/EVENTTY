import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/routes/route_names.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime(2026, 8, 28); // August 2026 sesuai gambar
  DateTime? _selectedDay;

  // Mock data - events berdasarkan tanggal (August 2026)
  final Map<DateTime, List<Map<String, dynamic>>> _events = {
    DateTime(2026, 8, 5): [
      {
        'id': 'event_5',
        'title': 'Workshop Design',
        'category': 'Workshop',
        'time': '09:00 - 12:00 WIB',
        'location': 'Lab Komputer',
        'image': 'assets/images/thumbnail/workshop.jpg',
        'status': 'available',
      },
    ],
    DateTime(2026, 8, 11): [
      {
        'id': 'event_11',
        'title': 'Music Festival',
        'category': 'Entertainment',
        'time': '14:00 - 18:00 WIB',
        'location': 'Aula Sekolah',
        'image': 'assets/images/thumbnail/music.jpg',
        'status': 'available',
      },
    ],
    DateTime(2026, 8, 17): [
      {
        'id': 'event_17',
        'title': 'Career Fair',
        'category': 'Career',
        'time': '08:00 - 15:00 WIB',
        'location': 'Lapangan Sekolah',
        'image': 'assets/images/thumbnail/career.jpg',
        'status': 'almost_full',
      },
    ],
    DateTime(2026, 8, 19): [
      {
        'id': 'event_19',
        'title': 'Basket Competition',
        'category': 'Sports Competition',
        'time': '08:00 - 16:00 WIB',
        'location': 'Lapangan Basket',
        'image': 'assets/images/thumbnail/basketball.jpg',
        'status': 'available',
      },
    ],
    DateTime(2026, 8, 21): [
      {
        'id': 'event_21',
        'title': 'Seminar AI',
        'category': 'Seminar',
        'time': '09:00 - 12:00 WIB',
        'location': 'Aula Sekolah',
        'image': 'assets/images/thumbnail/seminar.jpg',
        'status': 'available',
      },
    ],
    DateTime(2026, 8, 22): [
      {
        'id': 'event_22',
        'title': 'Art Exhibition',
        'category': 'Exhibition',
        'time': '10:00 - 16:00 WIB',
        'location': 'Galeri Seni',
        'image': 'assets/images/thumbnail/art.jpg',
        'status': 'almost_full',
      },
    ],
    DateTime(2026, 8, 23): [
      {
        'id': 'event_23',
        'title': 'Workshop Coding',
        'category': 'Workshop',
        'time': '13:00 - 17:00 WIB',
        'location': 'Lab Komputer',
        'image': 'assets/images/thumbnail/coding.jpg',
        'status': 'available',
      },
    ],
    DateTime(2026, 8, 29): [
      {
        'id': 'event_29',
        'title': 'English Debate',
        'category': 'Competition',
        'time': '08:00 - 14:00 WIB',
        'location': 'Ruang Sidang',
        'image': 'assets/images/thumbnail/debate.jpg',
        'status': 'full',
      },
    ],
  };

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  Color _getEventDotColor(DateTime day) {
    final events = _getEventsForDay(day);
    if (events.isEmpty) return Colors.transparent;
    
    final status = events.first['status'];
    switch (status) {
      case 'available':
        return const Color(0xFF10B981); // Hijau - Tersedia
      case 'almost_full':
        return const Color(0xFFF59E0B); // Kuning - Hampir penuh
      case 'full':
        return const Color(0xFFEF4444); // Merah - Penuh
      default:
        return const Color(0xFF10B981);
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Calendar',
              style: AppTextStyles.heading3.copyWith(fontSize: 20),
            ),
            Text(
              'Lihat jadwal event dan jangan sampai terlewat!',
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
            tooltip: 'Today',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Calendar Widget
          _buildCalendar(),
          
          const SizedBox(height: 16),
          
          // Legend
          _buildLegend(),
          
          const SizedBox(height: 16),
          
          // Upcoming Events Section
          Expanded(
            child: _buildUpcomingEventsSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        
        // Event Loader
        eventLoader: _getEventsForDay,
        
        // Calendar Style
        calendarStyle: CalendarStyle(
          // Today
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          todayTextStyle: AppTextStyles.body1.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          
          // Selected
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: AppTextStyles.body1.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          
          // Default
          defaultTextStyle: AppTextStyles.body1.copyWith(
            color: AppColors.textPrimary,
          ),
          
          // Weekend
          weekendTextStyle: AppTextStyles.body1.copyWith(
            color: AppColors.error,
          ),
          
          // Outside days
          outsideTextStyle: AppTextStyles.body1.copyWith(
            color: AppColors.textTertiary,
          ),
          
          // Markers
          markerDecoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          markersMaxCount: 1,
          
          // Cell
          cellMargin: const EdgeInsets.all(4),
          cellPadding: const EdgeInsets.all(0),
        ),
        
        // Header Style
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextFormatter: (date, locale) {
            return '${_getMonthName(date.month)} ${date.year}';
          },
          titleTextStyle: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          leftChevronIcon: const Icon(
            Icons.chevron_left,
            color: AppColors.primary,
            size: 24,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right,
            color: AppColors.primary,
            size: 24,
          ),
          headerPadding: const EdgeInsets.only(bottom: 16),
        ),
        
        // Days of Week Style
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontSize: 12,
          ),
          weekendStyle: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.error,
            fontSize: 12,
          ),
        ),
        
        // Calendar Builders untuk custom dot indicators
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return const SizedBox.shrink();
            
            return Positioned(
              bottom: 4,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _getEventDotColor(date),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem('Tersedia', const Color(0xFF10B981)),
          const SizedBox(width: 16),
          _buildLegendItem('Hampir penuh', const Color(0xFFF59E0B)),
          const SizedBox(width: 16),
          _buildLegendItem('Penuh', const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingEventsSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.horizontalPadding,
              20,
              AppSpacing.horizontalPadding,
              16,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.upcoming,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Upcoming Events',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    context.push(RouteNames.events);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat semua',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.primary,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Events List
          Expanded(
            child: _buildUpcomingEventsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsList() {
    // Get all upcoming events sorted by date
    final sortedEvents = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    _events.forEach((date, events) {
      if (date.isAfter(now) || isSameDay(date, now)) {
        for (var event in events) {
          sortedEvents.add({
            ...event,
            'date': date,
          });
        }
      }
    });
    
    sortedEvents.sort((a, b) => 
      (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    
    if (sortedEvents.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.separated(
      padding: const EdgeInsets.only(
        left: AppSpacing.horizontalPadding,
        right: AppSpacing.horizontalPadding,
        bottom: AppSpacing.horizontalPadding,
      ),
      itemCount: sortedEvents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final event = sortedEvents[index];
        final date = event['date'] as DateTime;
        return _buildUpcomingEventCard(event, date);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy,
              size: 48,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada event mendatang',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Event baru akan muncul di sini',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventCard(Map<String, dynamic> event, DateTime date) {
    // Get category color
    Color categoryColor = AppColors.primary;
    switch (event['category']) {
      case 'Sports Competition':
        categoryColor = const Color(0xFFFF6B35);
        break;
      case 'Seminar':
        categoryColor = const Color(0xFF6366F1);
        break;
      case 'Workshop':
        categoryColor = const Color(0xFF10B981);
        break;
      case 'Competition':
        categoryColor = const Color(0xFFF59E0B);
        break;
      default:
        categoryColor = AppColors.primary;
    }

    return InkWell(
      onTap: () {
        context.push('${RouteNames.eventDetail.replaceAll(':id', '')}${event['id']}');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Image with date overlay
            Stack(
              children: [
                // Event Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Container(
                    width: 100,
                    height: 120,
                    color: categoryColor.withValues(alpha: 0.2),
                    child: event['image'] != null
                        ? Image.asset(
                            event['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.image,
                                  color: categoryColor.withValues(alpha: 0.5),
                                  size: 40,
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.event,
                              color: categoryColor.withValues(alpha: 0.5),
                              size: 40,
                            ),
                          ),
                  ),
                ),
                
                // Date Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${date.day}',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          _getMonthShort(date.month),
                          style: AppTextStyles.captionSmall.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Event Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      event['title'],
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    
                    // Category
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: categoryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            event['category'],
                            style: AppTextStyles.captionSmall.copyWith(
                              color: categoryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Time
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            event['time'],
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            event['location'],
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Arrow
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthShort(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN',
                    'JUL', 'AGU', 'SEP', 'OKT', 'NOV', 'DES'];
    return months[month - 1];
  }
}
