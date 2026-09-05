import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/routes/route_names.dart';
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
            // Last item has minimal bottom padding
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
                imageUrl: null,
                onTap: () {
                  context.push(RouteNames.eventDetail.replaceAll(':id', eventId));
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
    final ids = ['3', '1', '2']; // Basketball, Classmeet, Career Day
    return ids[index % ids.length];
  }

  String _getEventTitle(int index) {
    final titles = [
      'Basketball Tournament',
      'Classmeet 2024',
      'Career Day 2024',
    ];
    return titles[index % titles.length];
  }

  String _getEventDate(int index) {
    final dates = [
      '19 Agustus 2027',
      '30 Agustus 2027',
      '20 September 2027',
    ];
    return dates[index % dates.length];
  }

  String _getEventCategory(int index) {
    final categories = [
      'Sports Competition',
      'School Event',
      'Career Development',
    ];
    return categories[index % categories.length];
  }

  String _getEventStatus(int index) {
    final statuses = [
      'open',
      'ongoing',
      'open',
    ];
    return statuses[index % statuses.length];
  }

  int _getCurrentParticipants(int index) {
    final participants = [35, 45, 28];
    return participants[index % participants.length];
  }
}
