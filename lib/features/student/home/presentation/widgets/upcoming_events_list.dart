import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../shared/widgets/event_card.dart';

class UpcomingEventsList extends StatelessWidget {
  const UpcomingEventsList({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final isLastItem = index == 2; // childCount - 1
            final eventId = _getEventId(index);
            return Padding(
              padding: EdgeInsets.only(bottom: isLastItem ? 4 : 12),
              child: EventCard(
                eventId: eventId,
                title: _getEventTitle(index),
                date: _getEventDate(index),
                location: 'SMKN 20 Jakarta',
                category: _getEventCategory(index),
                status: _getEventStatus(index),
                currentParticipants: _getCurrentParticipants(index),
                maxParticipants: 50,
                imageUrl: _getThumbnailUrl(index),
                onTap: () {
                  context.push('/events/$eventId');
                },
              ),
            );
          },
          childCount: 3,
        ),
      ),
    );
  }

  String _getEventId(int index) {
    // UUID dari DATABASE_COMPLETE.sql
    final ids = [
      '550e8400-e29b-41d4-a716-446655440001', // Basketball Championship
      '550e8400-e29b-41d4-a716-446655440002', // Career Day 2024
      '550e8400-e29b-41d4-a716-446655440003', // AI Seminar
    ];
    return ids[index % ids.length];
  }

  String _getEventTitle(int index) {
    final titles = [
      'SMKN 20 Basketball Championship 2024',
      'Career Day 2024 - Future Tech Leaders',
      'AI Seminar: Artificial Intelligence in Modern Era',
    ];
    return titles[index % titles.length];
  }

  String _getEventDate(int index) {
    final dates = [
      '19 Agustus 2026',
      '30 Agustus 2026',
      '20 September 2026',
    ];
    return dates[index % dates.length];
  }

  String _getEventCategory(int index) {
    final categories = [
      'Sport - Basketball',
      'Education - Career',
      'Technology - Seminar',
    ];
    return categories[index % categories.length];
  }

  String _getEventStatus(int index) {
    final statuses = [
      'open',
      'open',
      'open',
    ];
    return statuses[index % statuses.length];
  }

  int _getCurrentParticipants(int index) {
    final participants = [0, 0, 0]; // Akan update dari Supabase
    return participants[index % participants.length];
  }

  String? _getThumbnailUrl(int index) {
    final thumbnails = [
      'assets/images/thumbnail/basket-th.jpeg',      // Basketball
      'assets/images/thumbnail/career-th.jpeg',      // Career Day
      'assets/images/thumbnail/ai-th.jpeg',          // AI Seminar
    ];
    return thumbnails[index % thumbnails.length];
  }
}
