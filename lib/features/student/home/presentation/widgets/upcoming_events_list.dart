import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/routes/route_names.dart';
import '../../../../../core/services/event_service.dart';
import '../../../../../core/models/event_model.dart';
import '../../../../shared/widgets/event_card.dart';

// PHASE 4: Hardcoded event IDs and data REMOVED.
// Events now fetched from EventService.getAllEvents() via Supabase.
// Displays up to 3 upcoming events ordered by date.
// Handles loading, empty, and error states honestly.
// REQUIRES RUNTIME DATABASE VERIFICATION — Supabase not yet tested at runtime.

class UpcomingEventsList extends StatefulWidget {
  const UpcomingEventsList({super.key});

  @override
  State<UpcomingEventsList> createState() => _UpcomingEventsListState();
}

class _UpcomingEventsListState extends State<UpcomingEventsList> {
  final EventService _eventService = EventService();
  List<EventModel> _events = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final events = await _eventService.getAllEvents();

      // Show max 3 upcoming events (status: open), sorted by date ascending
      final upcoming = events
          .where((e) => e.isOpen)
          .take(3)
          .toList();

      setState(() {
        _events = upcoming;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: 32, horizontal: AppSpacing.horizontalPadding),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_hasError) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontalPadding),
          padding: const EdgeInsets.all(AppSpacing.paddingLG),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
            border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Gagal memuat event. Periksa koneksi internet.',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: _loadEvents,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_events.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontalPadding),
          padding: const EdgeInsets.all(AppSpacing.paddingLG),
          child: const Center(
            child: Column(
              children: [
                Icon(Icons.event_busy, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'Belum ada event tersedia',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontalPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final event = _events[index];
            final isLastItem = index == _events.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLastItem ? 4 : 12),
              child: EventCard(
                eventId: event.id,
                title: event.title,
                date: event.formattedDate,
                location: event.location,
                category: event.category,
                status: event.status,
                currentParticipants: event.registered,
                maxParticipants: event.capacity,
                imageUrl: _resolveThumbnailUrl(event.imageUrl),
                onTap: () {
                  context.push(
                      RouteNames.eventDetail.replaceAll(':id', event.id));
                },
              ),
            );
          },
          childCount: _events.length,
        ),
      ),
    );
  }

  /// Maps known detail image paths to thumbnail variants.
  /// Falls back to the original imageUrl (or null) if not mapped.
  String? _resolveThumbnailUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;

    const thumbnailMap = {
      'assets/images/detail/basket.jpeg':
          'assets/images/thumbnail/basket-th.jpeg',
      'assets/images/detail/career.jpeg':
          'assets/images/thumbnail/career-th.jpeg',
      'assets/images/detail/seminar.jpeg':
          'assets/images/thumbnail/ai-th.jpeg',
      'assets/images/detail/workcod.jpeg':
          'assets/images/thumbnail/workshop-coding-th.jpeg',
    };

    return thumbnailMap[imageUrl] ?? imageUrl;
  }
}
