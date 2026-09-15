import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/routes/route_names.dart';
import '../../../../../core/services/event_service.dart';
import '../../../../../core/models/event_model.dart';

// PHASE 5: Hardcoded List.generate(10, ...) dengan 'Classmeet 2026' REMOVED.
// Events sekarang di-fetch dari Supabase via EventService.getAllEvents().
// Toggle publish/registration dan delete via EventService (real DB operations).
// UI layout, filter chips, bottom sheet, empty/error states DIPERTAHANKAN.
// REQUIRES RUNTIME DATABASE VERIFICATION — Supabase not yet tested at runtime.

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  final EventService _eventService = EventService();

  List<EventModel> _events = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    try {
      final events = await _eventService.getAllEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<EventModel> get _filteredEvents {
    return _events.where((event) {
      switch (_filterStatus) {
        case 'Published':
          return event.isPublished;
        case 'Draft':
          return !event.isPublished;
        case 'Open':
          return event.isRegistrationOpen;
        case 'Closed':
          return !event.isRegistrationOpen;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manage Events', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadEvents,
              tooltip: 'Refresh',
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _filterStatus = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Events')),
              const PopupMenuItem(value: 'Published', child: Text('Published')),
              const PopupMenuItem(value: 'Draft', child: Text('Draft')),
              const PopupMenuItem(
                  value: 'Open', child: Text('Registration Open')),
              const PopupMenuItem(
                  value: 'Closed', child: Text('Registration Closed')),
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

          // Body
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                    ? _buildErrorState()
                    : _filteredEvents.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadEvents,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(
                                  AppSpacing.horizontalPadding),
                              itemCount: _filteredEvents.length,
                              itemBuilder: (context, index) {
                                final event = _filteredEvents[index];
                                return _buildEventCard(context, event);
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.adminCreateEvent),
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filterStatus = label),
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.body2.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat events',
              style: AppTextStyles.heading3.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style:
                  AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadEvents,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
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
            _filterStatus == 'All'
                ? 'Belum ada event'
                : 'Tidak ada event dengan filter "$_filterStatus"',
            style:
                AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (_filterStatus != 'All')
            TextButton(
              onPressed: () => setState(() => _filterStatus = 'All'),
              child: const Text('Hapus filter'),
            ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event) {
    final isPublished = event.isPublished;
    final isRegOpen = event.isRegistrationOpen;
    final participants = event.registered;
    final capacity = event.capacity;

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
                            event.title,
                            style: AppTextStyles.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!isPublished)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.textTertiary
                                  .withValues(alpha: 0.1),
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
                      event.formattedDate,
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
                        Text(isRegOpen
                            ? 'Close Registration'
                            : 'Open Registration'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'quota',
                    child: const Row(
                      children: [
                        Icon(Icons.people_outline,
                            size: 18, color: AppColors.textPrimary),
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
                        Text('Delete',
                            style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'publish') {
                    _togglePublish(event);
                  } else if (value == 'registration') {
                    _toggleRegistration(event);
                  } else if (value == 'quota') {
                    _showEditQuotaDialog(event);
                  } else if (value == 'delete') {
                    _showDeleteDialog(event);
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
              _buildStatusBadge(event.category, AppColors.info),
              _buildStatusBadge(
                event.status.toUpperCase(),
                event.isOpen
                    ? AppColors.success
                    : event.isOngoing
                        ? AppColors.warning
                        : AppColors.textSecondary,
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
                  value: capacity > 0 ? participants / capacity : 0.0,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    capacity > 0 && participants / capacity > 0.8
                        ? AppColors.error
                        : AppColors.success,
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
                    context.push(
                        RouteNames.adminEditEvent.replaceAll(':id', event.id));
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
                  onPressed: () => _showEventDetailSheet(context, event),
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

  // ============================================================
  // ACTIONS — real database operations via EventService
  // EventService.updateEvent() menerima EventModel (full object).
  // Gunakan event.copyWith() untuk membuat updated copy.
  // ============================================================

  Future<void> _togglePublish(EventModel event) async {
    final updated = event.copyWith(isPublished: !event.isPublished);

    // Optimistic UI update
    setState(() {
      final idx = _events.indexWhere((e) => e.id == event.id);
      if (idx != -1) _events[idx] = updated;
    });

    try {
      await _eventService.updateEvent(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(updated.isPublished
              ? 'Event published successfully'
              : 'Event unpublished'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      // Rollback on error
      setState(() {
        final idx = _events.indexWhere((ev) => ev.id == event.id);
        if (idx != -1) _events[idx] = event;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui publish: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _toggleRegistration(EventModel event) async {
    final updated =
        event.copyWith(isRegistrationOpen: !event.isRegistrationOpen);

    // Optimistic UI update
    setState(() {
      final idx = _events.indexWhere((e) => e.id == event.id);
      if (idx != -1) _events[idx] = updated;
    });

    try {
      await _eventService.updateEvent(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(updated.isRegistrationOpen
              ? 'Registration opened'
              : 'Registration closed'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      // Rollback
      setState(() {
        final idx = _events.indexWhere((ev) => ev.id == event.id);
        if (idx != -1) _events[idx] = event;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui registrasi: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showEditQuotaDialog(EventModel event) {
    final controller = TextEditingController(text: event.capacity.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Quota', style: AppTextStyles.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event: ${event.title}', style: AppTextStyles.body1),
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
              'Current participants: ${event.registered}',
              style:
                  AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newCapacity = int.tryParse(controller.text);
              if (newCapacity == null || newCapacity < event.registered) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Invalid capacity. Must be >= current participants'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              Navigator.pop(ctx);

              try {
                await _eventService.updateEvent(
                    event.copyWith(capacity: newCapacity));
                await _loadEvents();

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Quota updated successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal update quota: $e'),
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
  }

  void _showDeleteDialog(EventModel event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Event', style: AppTextStyles.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hapus "${event.title}"?', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Tindakan ini tidak dapat dibatalkan. Data peserta terkait event ini mungkin juga terdampak.',
              style: AppTextStyles.body1,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);

              // Optimistic remove
              setState(() => _events.removeWhere((e) => e.id == event.id));

              try {
                await _eventService.deleteEvent(event.id);

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Event deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                // Restore on failure — reload from DB
                await _loadEvents();

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menghapus event: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showEventDetailSheet(BuildContext context, EventModel event) {
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
                    Text(event.title, style: AppTextStyles.heading2),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                        Icons.calendar_today, 'Date', event.formattedDate),
                    _buildDetailRow(
                        Icons.place, 'Location', event.location),
                    _buildDetailRow(Icons.people, 'Participants',
                        '${event.registered}/${event.capacity}'),
                    _buildDetailRow(
                        Icons.category, 'Category', event.category),
                    _buildDetailRow(
                        Icons.business, 'Organizer', event.organizer),
                    _buildDetailRow(
                      Icons.public,
                      'Status',
                      event.isPublished ? 'Published' : 'Draft',
                    ),
                    _buildDetailRow(
                      Icons.app_registration,
                      'Registration',
                      event.isRegistrationOpen ? 'Open' : 'Closed',
                    ),
                    if (event.certificateEnabled)
                      _buildDetailRow(
                        Icons.workspace_premium,
                        'Certificate',
                        event.certificateType.name,
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
          Text('$label: ',
              style: AppTextStyles.body1
                  .copyWith(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, style: AppTextStyles.body1)),
        ],
      ),
    );
  }
}
