import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/routes/route_names.dart';
import '../../../../../core/services/event_service.dart';
import '../../../../../core/models/event_model.dart';
import '../../../../../core/utils/category_mapper.dart';
import '../../../../shared/widgets/event_card.dart';

class EventsScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialQuery;
  
  const EventsScreen({super.key, this.initialCategory, this.initialQuery});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventService _eventService = EventService();
  String _selectedCategory = CategoryMapper.all;
  String _selectedStatus = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  
  List<EventModel> _allEvents = [];
  String? _errorMessage;
  
  // Final categories
  final List<Map<String, String>> _categories = [
    {'name': 'Semua', 'value': CategoryMapper.all},
    {'name': 'Sekolah', 'value': CategoryMapper.sekolah},
    {'name': 'Harian', 'value': CategoryMapper.harian},
    {'name': 'Seminar', 'value': CategoryMapper.seminar},
    {'name': 'Workshop', 'value': CategoryMapper.workshop},
    {'name': 'Kompetisi', 'value': CategoryMapper.kompetisi},
    {'name': 'Lainnya', 'value': CategoryMapper.lainnya},
  ];

  // Status filters
  final List<Map<String, String>> _statuses = [
    {'name': 'Semua', 'value': 'all'},
    {'name': 'Open', 'value': 'open'},
    {'name': 'Ongoing', 'value': 'ongoing'},
    {'name': 'Closed', 'value': 'closed'},
  ];

  @override
  void initState() {
    super.initState();
    // Set initial category dari navigation parameter
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!.toLowerCase();
    }
    // Set initial search query
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchQuery = widget.initialQuery!;
      _searchController.text = widget.initialQuery!;
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

  // Filter events based on search query, category, and status
  List<EventModel> _getFilteredEvents() {
    List<EventModel> filtered = _allEvents;

    // Filter by category
    if (_selectedCategory != CategoryMapper.all) {
      filtered = filtered.where((event) {
        return CategoryMapper.matchesCategory(event.category, _selectedCategory);
      }).toList();
    }

    // Filter by status
    if (_selectedStatus != 'all') {
      filtered = filtered.where((event) {
        return event.status.toLowerCase() == _selectedStatus.toLowerCase();
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((event) {
        final title = event.title.toLowerCase();
        final description = event.description.toLowerCase();
        final category = event.category.toLowerCase();
        final query = _searchQuery.toLowerCase();
        
        return title.contains(query) || 
               description.contains(query) ||
               category.contains(query);
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
                  final categoryValue = category['value']!;
                  final isSelected = _selectedCategory == categoryValue;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = categoryValue;
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

            const SizedBox(height: AppSpacing.paddingMD),

            // Status Filter
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontalPadding,
                ),
                itemCount: _statuses.length,
                itemBuilder: (context, index) {
                  final status = _statuses[index];
                  final statusName = status['name']!;
                  final statusValue = status['value']!;
                  final isSelected = _selectedStatus == statusValue;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStatus = statusValue;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.card,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                          border: Border.all(
                            color: isSelected 
                                ? AppColors.primary 
                                : AppColors.border.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            statusName,
                            style: AppTextStyles.caption.copyWith(
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 12,
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
                            'Tidak ada event yang sesuai',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tidak ada event yang sesuai dengan filter.',
                            style: AppTextStyles.body2,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = CategoryMapper.all;
                                _selectedStatus = 'all';
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset Filter'),
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
                            context.push(RouteNames.eventDetail.replaceAll(':id', event.id));
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
