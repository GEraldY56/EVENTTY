import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/routes/route_names.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  // Sample data - replace with actual state management
  final List<Map<String, dynamic>> _events = List.generate(
    10,
    (index) => {
      'id': 'event_$index',
      'title': index == 0 ? 'Classmeet 2026' : 'Event ${index + 1}',
      'date': '10 September 2027',
      'participants': 45 + index * 5,
      'capacity': 100,
      'isPublished': index % 2 == 0,
      'isRegistrationOpen': index % 3 != 0,
      'category': index % 2 == 0 ? 'Workshop' : 'Competition',
    },
  );

  String _filterStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _events.where((event) {
      if (_filterStatus == 'All') return true;
      if (_filterStatus == 'Published') return event['isPublished'] == true;
      if (_filterStatus == 'Draft') return event['isPublished'] == false;
      if (_filterStatus == 'Open') return event['isRegistrationOpen'] == true;
      if (_filterStatus == 'Closed') return event['isRegistrationOpen'] == false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manage Events', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _filterStatus = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Events')),
              const PopupMenuItem(value: 'Published', child: Text('Published')),
              const PopupMenuItem(value: 'Draft', child: Text('Draft')),
              const PopupMenuItem(value: 'Open', child: Text('Registration Open')),
              const PopupMenuItem(value: 'Closed', child: Text('Registration Closed')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontalPadding,
              vertical: 12,
            ),
            child: Row(
              children: [
                _buildFilterChip('All', _filterStatus == 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('Published', _filterStatus == 'Published'),
                const SizedBox(width: 8),
                _buildFilterChip('Draft', _filterStatus == 'Draft'),
                const SizedBox(width: 8),
                _buildFilterChip('Open', _filterStatus == 'Open'),
                const SizedBox(width: 8),
                _buildFilterChip('Closed', _filterStatus == 'Closed'),
              ],
            ),
          ),

          // Events List
          Expanded(
            child: filteredEvents.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return _buildEventCard(context, event, index);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(RouteNames.adminCreateEvent);
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterStatus = label);
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.body2.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> event, int index) {
    final isPublished = event['isPublished'] as bool;
    final isRegOpen = event['isRegistrationOpen'] as bool;
    final participants = event['participants'] as int;
    final capacity = event['capacity'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.paddingMD),
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            event['title'] as String,
                            style: AppTextStyles.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!isPublished)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.textTertiary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'DRAFT',
                              style: AppTextStyles.captionSmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event['date'] as String,
                      style: AppTextStyles.body2,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'publish',
                    child: Row(
                      children: [
                        Icon(
                          isPublished ? Icons.unpublished : Icons.publish,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 12),
                        Text(isPublished ? 'Unpublish' : 'Publish'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'registration',
                    child: Row(
                      children: [
                        Icon(
                          isRegOpen ? Icons.lock : Icons.lock_open,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 12),
                        Text(isRegOpen ? 'Close Registration' : 'Open Registration'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'quota',
                    child: const Row(
                      children: [
                        Icon(Icons.people_outline, size: 18, color: AppColors.textPrimary),
                        SizedBox(width: 12),
                        Text('Edit Quota'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: const Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: AppColors.error),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'publish') {
                    _togglePublish(event['id'] as String);
                  } else if (value == 'registration') {
                    _toggleRegistration(event['id'] as String);
                  } else if (value == 'quota') {
                    _showEditQuotaDialog(event);
                  } else if (value == 'delete') {
                    _showDeleteDialog(event['id'] as String);
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Status Badges
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusBadge(
                isRegOpen ? 'Registration Open' : 'Registration Closed',
                isRegOpen ? AppColors.success : AppColors.error,
              ),
              _buildStatusBadge(
                event['category'] as String,
                AppColors.info,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Participants Info
          Row(
            children: [
              Icon(Icons.people, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                '$participants/$capacity participants',
                style: AppTextStyles.body2,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LinearProgressIndicator(
                  value: participants / capacity,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    participants / capacity > 0.8 ? AppColors.error : AppColors.success,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(RouteNames.adminEditEvent.replaceAll(':id', event['id'] as String));
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to event detail
                    _showEventDetailSheet(context, event);
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.captionSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'No events found',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing the filter',
            style: AppTextStyles.body2,
          ),
        ],
      ),
    );
  }

  void _togglePublish(String eventId) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() {
        final event = _events.firstWhere((e) => e['id'] == eventId);
        event['isPublished'] = !(event['isPublished'] as bool);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _events.firstWhere((e) => e['id'] == eventId)['isPublished'] as bool
                ? 'Event published successfully'
                : 'Event unpublished',
          ),
        ),
      );
    });
  }

  void _toggleRegistration(String eventId) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() {
        final event = _events.firstWhere((e) => e['id'] == eventId);
        event['isRegistrationOpen'] = !(event['isRegistrationOpen'] as bool);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _events.firstWhere((e) => e['id'] == eventId)['isRegistrationOpen'] as bool
                ? 'Registration opened'
                : 'Registration closed',
          ),
        ),
      );
    });
  }

  void _showEditQuotaDialog(Map<String, dynamic> event) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      final controller = TextEditingController(text: event['capacity'].toString());
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Edit Quota', style: AppTextStyles.heading3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event: ${event['title']}', style: AppTextStyles.body1),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  hintText: 'Enter new capacity',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Current participants: ${event['participants']}',
                style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
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
                final newCapacity = int.tryParse(controller.text);
                final currentParticipants = event['participants'] as int;
                if (newCapacity != null && newCapacity >= currentParticipants) {
                  setState(() {
                    event['capacity'] = newCapacity;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quota updated successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid capacity. Must be >= current participants'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    });
  }

  void _showDeleteDialog(String eventId) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Event', style: AppTextStyles.heading3),
          content: Text(
            'Are you sure you want to delete this event? This action cannot be undone.',
            style: AppTextStyles.body1,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _events.removeWhere((e) => e['id'] == eventId);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event deleted successfully')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );
    });
  }

  void _showEventDetailSheet(BuildContext context, Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event['title'] as String, style: AppTextStyles.heading2),
                    const SizedBox(height: 16),
                    _buildDetailRow(Icons.calendar_today, 'Date', event['date'] as String),
                    _buildDetailRow(Icons.people, 'Participants', '${event['participants']}/${event['capacity']}'),
                    _buildDetailRow(Icons.category, 'Category', event['category'] as String),
                    _buildDetailRow(
                      Icons.public,
                      'Status',
                      (event['isPublished'] as bool) ? 'Published' : 'Draft',
                    ),
                    _buildDetailRow(
                      Icons.app_registration,
                      'Registration',
                      (event['isRegistrationOpen'] as bool) ? 'Open' : 'Closed',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text('$label: ', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
          Text(value, style: AppTextStyles.body1),
        ],
      ),
    );
  }
}
