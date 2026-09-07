import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/services/event_service.dart';
import '../../../../../core/models/event_model.dart';
import '../../../../shared/widgets/event_card.dart';

class EventsScreen extends StatefulWidget {
  final String? initialCategory;
  
  const EventsScreen({super.key, this.initialCategory});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventService _eventService = EventService();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  
  List<EventModel> _allEvents = [];
  String? _errorMessage;
  
  final List<Map<String, String>> _categories = [
    {'name': 'All', 'slug': 'all'},
    {'name': 'Classmeet', 'slug': 'classmeet'},
    {'name': 'Sports', 'slug': 'sports'},
    {'name': 'Seminar', 'slug': 'seminar'},
    {'name': 'Workshop', 'slug': 'workshop'},
    {'name': 'Career', 'slug': 'career'},
    {'name': 'Science', 'slug': 'science'},
  ];

  @override
  void initState() {
    super.initState();
    // Set initial category dari navigation parameter
    if (widget.initialCategory != null) {
      final matchedCategory = _categories.firstWhere(
        (cat) => cat['slug'] == widget.initialCategory,
        orElse: () => _categories[0],
      );
      _selectedCategory = matchedCategory['name']!;
    }
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final events = await _eventService.getAllEvents();
      setState(() {
        _allEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter events based on search query and category
  List<EventModel> _getFilteredEvents() {
    List<EventModel> filtered = _allEvents;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((event) {
        return event.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((event) {
        final title = event.title.toLowerCase();
        final category = event.category.toLowerCase();
        final query = _searchQuery.toLowerCase();
        
        return title.contains(query) || category.contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events', style: AppTextStyles.heading3),
        ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.horizontalPadding,
                AppSpacing.paddingMD,
                AppSpacing.horizontalPadding,
                AppSpacing.paddingMD,
              ),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    hintStyle: AppTextStyles.body1.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.paddingLG,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            // Category Filter
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontalPadding,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final categoryName = category['name']!;
                  final isSelected = _selectedCategory == categoryName;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = categoryName;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.card,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            categoryName,
                            style: AppTextStyles.body2.copyWith(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.paddingLG),

            // Events List
            Expanded(
              child: Builder(
                builder: (context) {
                  // Show loading shimmer
                  if (_isLoading) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.horizontalPadding,
                      ),
                      itemCount: 3,
                      itemBuilder: (context, index) => _buildEventSkeleton(),
                    );
                  }

                  // Show error state
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
                            'Failed to load events',
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
                            onPressed: _loadEvents,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredEvents = _getFilteredEvents();
                  
                  if (filteredEvents.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No events found',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Try searching with different keywords'
                                : 'Try selecting a different category',
                            style: AppTextStyles.body2,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontalPadding,
                    ),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: EventCard(
                          eventId: event.id,
                          title: event.title,
                          date: event.formattedDate,
                          location: event.location,
                          category: event.category,
                          status: event.status,
                          currentParticipants: event.registered,
                          maxParticipants: event.capacity,
                          imageUrl: _getThumbnailFromDetailImage(event.imageUrl),
                          onTap: () {
                            context.push('/events/${event.id}');
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Convert detail image path to thumbnail path
  String? _getThumbnailFromDetailImage(String? detailImagePath) {
    if (detailImagePath == null || detailImagePath.isEmpty) return null;
    
    // Map detail images to thumbnails
    final thumbnailMap = {
      'assets/images/detail/basket.jpeg': 'assets/images/thumbnail/basket-th.jpeg',
      'assets/images/detail/career.jpeg': 'assets/images/thumbnail/career-th.jpeg',
      'assets/images/detail/seminar.jpeg': 'assets/images/thumbnail/ai-th.jpeg',
      'assets/images/detail/workcod.jpeg': 'assets/images/thumbnail/workshop-coding-th.jpeg',
    };
    
    return thumbnailMap[detailImagePath] ?? detailImagePath;
  }

  Widget _buildEventSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Shimmer.fromColors(
        baseColor: AppColors.neutral200,
        highlightColor: AppColors.neutral100,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          ),
        ),
      ),
    );
  }
}
