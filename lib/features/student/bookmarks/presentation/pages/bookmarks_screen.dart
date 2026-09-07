import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/services/bookmark_service.dart';
import '../../../../../core/services/event_service.dart';
import '../../../../../core/models/event_model.dart';
import '../../../../shared/widgets/event_card.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final BookmarkService _bookmarkService = BookmarkService();
  final EventService _eventService = EventService();
  
  List<EventModel> _bookmarkedEvents = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadBookmarkedEvents();
  }

  Future<void> _loadBookmarkedEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get user ID
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId') ?? '';

      // Get bookmarked event IDs
      final bookmarkedEventIds = await _bookmarkService.getBookmarkedEvents(_userId);

      // Get full event details for each bookmarked event
      final events = await _eventService.getAllEvents();
      final bookmarkedEvents = events
          .where((event) => bookmarkedEventIds.contains(event.id))
          .toList();

      if (mounted) {
        setState(() {
          _bookmarkedEvents = bookmarkedEvents;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeBookmark(String eventId) async {
    final success = await _bookmarkService.removeBookmark(_userId, eventId);
    
    if (success) {
      await _loadBookmarkedEvents();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from bookmarks'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarked Events', style: AppTextStyles.heading3),
        actions: [
          if (_bookmarkedEvents.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: () => _showClearAllDialog(),
              tooltip: 'Clear all',
            ),
        ],
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            // Loading state
            if (_isLoading) {
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
                itemCount: 3,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSkeleton(),
                ),
              );
            }

            // Error state
            if (_errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load bookmarks',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage ?? 'Unknown error',
                      style: AppTextStyles.body2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadBookmarkedEvents,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Empty state
            if (_bookmarkedEvents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border_rounded,
                      size: 80,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Bookmarked Events',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bookmark events to see them here',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/events'),
                      icon: const Icon(Icons.explore_rounded),
                      label: const Text('Explore Events'),
                    ),
                  ],
                ),
              );
            }

            // Bookmarked events list
            return RefreshIndicator(
              onRefresh: _loadBookmarkedEvents,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
                itemCount: _bookmarkedEvents.length,
                itemBuilder: (context, index) {
                  final event = _bookmarkedEvents[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: Key(event.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                        ),
                        child: const Icon(
                          Icons.delete_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      onDismissed: (direction) {
                        _removeBookmark(event.id);
                      },
                      child: EventCard(
                        eventId: event.id,
                        title: event.title,
                        date: event.formattedDate,
                        location: event.location,
                        category: event.category,
                        status: event.status,
                        currentParticipants: event.registered,
                        maxParticipants: event.capacity,
                        onTap: () {
                          context.push('/events/${event.id}');
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppColors.neutral200,
      highlightColor: AppColors.neutral100,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        ),
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Clear All Bookmarks?'),
        content: const Text(
          'This will remove all bookmarked events. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              
              navigator.pop();
              
              final success = await _bookmarkService.clearAllBookmarks(_userId);
              
              if (success) {
                await _loadBookmarkedEvents();
                
                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('All bookmarks cleared'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Clear All',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
