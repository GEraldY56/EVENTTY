import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/constants/strings.dart';
import '../../../../../core/routes/route_names.dart';
import '../widgets/home_header.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/featured_event_carousel.dart';
import '../widgets/quick_actions.dart';
import '../widgets/category_grid.dart';
import '../widgets/section_title.dart';
import '../widgets/upcoming_events_list.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get safe area insets untuk accurate bottom padding
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bottomNavBarHeight = kBottomNavigationBarHeight; // 56.0
    // Padding just enough agar tidak tertutup bottom nav (no extra space)
    final totalBottomSpace = bottomNavBarHeight + bottomInset;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Decorative Background Gradient (Top)
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.06),
                    AppColors.secondary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          
          // Main Content
          CustomScrollView(
            slivers: [
              // Modern Header dengan Greeting
              const SliverToBoxAdapter(
                child: HomeHeader(userName: 'Muhammad Faqih'),
              ),

          // Content dengan padding
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.horizontalPadding,
              AppSpacing.paddingLG,
              AppSpacing.horizontalPadding,
              0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Search Bar
                SearchBarWidget(
                  onTap: () {
                    context.push(RouteNames.events);
                  },
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                // Featured Event Carousel
                const FeaturedEventCarousel(),

                const SizedBox(height: AppSpacing.sectionGap),

                // Quick Actions
                const QuickActions(),

                const SizedBox(height: AppSpacing.sectionGap),

                // Event Categories
                SectionTitle(
                  title: AppStrings.categories,
                  onSeeAll: () {
                    context.push(RouteNames.events);
                  },
                ),

                const SizedBox(height: AppSpacing.paddingLG),

                const CategoryGrid(),

                const SizedBox(height: AppSpacing.sectionGap),

                // Upcoming Events Section
                SectionTitle(
                  title: 'Upcoming Events',
                  onSeeAll: () {
                    context.push(RouteNames.events);
                  },
                ),

                const SizedBox(height: AppSpacing.paddingLG),
              ]),
            ),
          ),

          // Upcoming Events List (langsung SliverList tanpa padding tambahan)
          const UpcomingEventsList(),

          // Bottom spacing - Dynamic berdasarkan Bottom Navigation height
          SliverPadding(
            padding: EdgeInsets.only(bottom: totalBottomSpace),
          ),
            ],
          ),
        ],
      ),
    );
  }
}
