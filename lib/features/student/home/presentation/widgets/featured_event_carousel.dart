import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/routes/route_names.dart';
import '../../../../../core/services/event_service.dart';
import '../../../../../core/models/event_model.dart';

// PHASE 4: Hardcoded UUIDs and banner data REMOVED.
// Carousel now fetches featured events from EventService.getFeaturedEvents().
// Banner click uses real event.id from EventModel.
// Falls back to gradient placeholder if no image_url is set on the event.
// If no featured events exist, carousel is hidden (empty/loading states shown).
// REQUIRES RUNTIME DATABASE VERIFICATION — Supabase not yet tested at runtime.

class FeaturedEventCarousel extends StatefulWidget {
  const FeaturedEventCarousel({super.key});

  @override
  State<FeaturedEventCarousel> createState() => _FeaturedEventCarouselState();
}

class _FeaturedEventCarouselState extends State<FeaturedEventCarousel> {
  final EventService _eventService = EventService();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  List<EventModel> _featuredEvents = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadFeaturedEvents();
  }

  Future<void> _loadFeaturedEvents() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final events = await _eventService.getFeaturedEvents();
      setState(() {
        _featuredEvents = events;
        _isLoading = false;
      });
      if (events.isNotEmpty) {
        _startAutoSlide();
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_featuredEvents.isEmpty) return;
      if (_currentPage < _featuredEvents.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingPlaceholder();
    }

    if (_hasError || _featuredEvents.isEmpty) {
      // Return empty widget — do not show placeholder mock data
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _featuredEvents.length,
            itemBuilder: (context, index) {
              return _buildBannerItem(_featuredEvents[index]);
            },
          ),
        ),
        const SizedBox(height: 16),
        if (_featuredEvents.length > 1)
          SmoothPageIndicator(
            controller: _pageController,
            count: _featuredEvents.length,
            effect: ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: AppColors.primary,
              dotColor: AppColors.border,
              expansionFactor: 3,
              spacing: 6,
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.border.withValues(alpha: 0.3),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildBannerItem(EventModel event) {
    return GestureDetector(
      onTap: () {
        // event.id is always the real UUID from EventModel
        context.push(RouteNames.eventDetail.replaceAll(':id', event.id));
      },
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _buildBannerImage(event),
        ),
      ),
    );
  }

  Widget _buildBannerImage(EventModel event) {
    final imageUrl = event.imageUrl;

    // If no image provided, show branded gradient fallback
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildGradientFallback(event);
    }

    // Try loading asset or network image
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildGradientFallback(event),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          _buildGradientFallback(event),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildGradientFallback(event);
      },
    );
  }

  Widget _buildGradientFallback(EventModel event) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background shimmer overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.4),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Event info overlay
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.category,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Calendar icon
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.event_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
