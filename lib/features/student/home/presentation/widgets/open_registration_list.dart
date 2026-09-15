import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/routes/route_names.dart';
import '../../../../../core/services/event_service.dart';
import '../../../../../core/models/event_model.dart';
import '../../../../shared/widgets/event_card.dart';

/// Open Registration Section - displays events that are currently accepting registrations
/// Criteria: status='open' AND is_published=true AND is_registration_open=true
/// Shows max 3 events horizontally scrollable
class OpenRegistrationList extends StatefulWidget {
  const OpenRegistrationList({super.key});

  @override
  State<OpenRegistrationList> createState() => _OpenRegistrationListState();
}

class _OpenRegistrationListState extends State<OpenRegistrationList> {
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

      // Filter: status='open' AND is_published=true AND is_registration_open=true
      // Show max 3 events
      final openForRegistration = events
          .where((e) => 
            e.status == 'open' && 
            e.isPublished && 
            e.isRegistrationOpen
          )
          .take(3)
          .toList();

      setState(() {
        _events = openForRegistration;
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
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_events.isEmpty) {
      // Return empty widget - don't show section if no open registrations
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Horizontal scrollable list of event cards
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontalPadding,
            ),
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final event = _events[index];
              final isLastItem = index == _events.length - 1;
              return Container(
                width: 300,
                margin: EdgeInsets.only(right: isLastItem ? 0 : 16),
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
                      RouteNames.eventDetail.replaceAll(':id', event.id),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontalPadding,
        ),
        itemCount: 2,
        itemBuilder: (context, index) {
          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPadding,
      ),
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
              'Gagal memuat event yang sedang dibuka pendaftaran.',
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: _loadEvents,
            child: const Text('Retry'),
          ),
        ],
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
