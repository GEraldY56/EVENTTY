import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/routes/route_names.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _selectedFilter = 'All';
  
  final List<String> _filters = ['All', 'Event', 'Academic', 'Achievement', 'Announcement'];
  
  // Mock news data dengan detail lengkap
  final List<Map<String, dynamic>> _allNews = [
    {
      'id': 'news_0',
      'title': 'SMKN 20 Jakarta Wins National Programming Competition',
      'category': 'Achievement',
      'excerpt': 'Our programming team brought home the championship trophy from the National Coding Championship 2027...',
      'content': 'SMKN 20 Jakarta programming team has achieved a remarkable victory at the National Coding Championship 2027 held in Surabaya. The team, consisting of three talented students, competed against 50 teams from various schools across Indonesia.\n\nThe competition lasted for two days and included multiple challenging rounds including algorithm design, web development, and mobile app creation. Our team demonstrated exceptional skills and teamwork throughout the competition.\n\nCongratulations to our winners and special thanks to the coaches who have dedicated their time and expertise to train our students.',
      'author': 'Admin OSIS',
      'date': '2 hours ago',
      'readTime': '3 min read',
      'image': 'assets/images/detail/workcod.jpeg',
      'views': 234,
      'isImportant': true,
    },
    {
      'id': 'news_1',
      'title': 'Basketball Team Advances to Regional Finals',
      'category': 'Achievement',
      'excerpt': 'After a thrilling semi-final match, our basketball team has secured their spot in the regional finals...',
      'content': 'Our school basketball team has made history by advancing to the regional finals after defeating their opponents 78-72 in an intense semi-final match.\n\nThe game was closely contested throughout, with both teams displaying excellent skills and sportsmanship. Our team\'s perseverance and strategic play in the final quarter proved to be the winning factor.\n\nThe regional finals will be held next month, and we encourage all students to come and support our team. Let\'s show them our school spirit!',
      'author': 'Sports Club',
      'date': '5 hours ago',
      'readTime': '2 min read',
      'image': 'assets/images/detail/basket.jpeg',
      'views': 187,
      'isImportant': true,
    },
    {
      'id': 'news_2',
      'title': 'Important: Final Exam Schedule Released',
      'category': 'Academic',
      'excerpt': 'The final examination schedule for this semester has been officially released. Please check the details...',
      'content': 'The Academic Affairs Office has released the final examination schedule for the current semester. All students are advised to review the schedule carefully and prepare accordingly.\n\nKey Dates:\n- Examination Period: December 10-20, 2027\n- Review Sessions: December 1-8, 2027\n- Results Announcement: January 5, 2028\n\nPlease note that the examination schedule is also available on the school website and student portal. Students with scheduling conflicts should contact the Academic Affairs Office immediately.\n\nGood luck with your preparations!',
      'author': 'Academic Affairs',
      'date': '1 day ago',
      'readTime': '4 min read',
      'image': null,
      'views': 456,
      'isImportant': true,
    },
    {
      'id': 'news_3',
      'title': 'Career Day 2027 Registration Now Open',
      'category': 'Event',
      'excerpt': 'Don\'t miss the opportunity to meet industry professionals and explore career paths at Career Day 2027...',
      'content': 'We are excited to announce that registration for Career Day 2027 is now open! This year\'s event will feature speakers from various industries including technology, healthcare, finance, and creative arts.\n\nEvent Highlights:\n- Keynote speeches from industry leaders\n- Interactive workshops and seminars\n- One-on-one career counseling sessions\n- Company booth exhibitions\n- Networking opportunities\n\nRegistration is free but seats are limited. Sign up through the Events page before November 30th to secure your spot.\n\nThis is a valuable opportunity to gain insights into various career paths and make important connections for your future.',
      'author': 'Guidance Counseling',
      'date': '1 day ago',
      'readTime': '3 min read',
      'image': 'assets/images/detail/career.jpeg',
      'views': 312,
      'isImportant': false,
    },
    {
      'id': 'news_4',
      'title': 'New Library Digital Resources Available',
      'category': 'Academic',
      'excerpt': 'The school library has added new digital resources including e-books and online journals...',
      'content': 'We are pleased to announce that our school library has expanded its digital collection with hundreds of new e-books and access to online academic journals.\n\nNew Resources Include:\n- 500+ e-books across various subjects\n- Academic journals from major publishers\n- Research databases for student projects\n- Interactive learning modules\n\nAll students can access these resources using their student ID and password through the library portal. The library staff is available to provide orientation and assistance.\n\nLibrary hours: Monday-Friday, 7:00 AM - 5:00 PM',
      'author': 'Library Staff',
      'date': '2 days ago',
      'readTime': '2 min read',
      'image': null,
      'views': 145,
      'isImportant': false,
    },
    {
      'id': 'news_5',
      'title': 'Class Meeting 2027 Spectacular Success',
      'category': 'Event',
      'excerpt': 'This year\'s Class Meeting was filled with exciting competitions and memorable moments...',
      'content': 'Class Meeting 2027 concluded with great success, featuring various competitions that showcased our students\' talents and spirit.\n\nCompetition Results:\n- Basketball Championship: Class XII RPL 1\n- Futsal Tournament: Class XI RPL 2\n- Volleyball Cup: Class XII TKJ 1\n- Academic Quiz: Class XI RPL 1\n\nCongratulations to all winners and participants! Special thanks to OSIS and all committee members who worked tirelessly to make this event memorable.\n\nStay tuned for more exciting school events!',
      'author': 'Admin OSIS',
      'date': '3 days ago',
      'readTime': '4 min read',
      'image': 'assets/images/detail/classmeet.jpeg',
      'views': 523,
      'isImportant': false,
    },
    {
      'id': 'news_6',
      'title': 'Student Council Elections Announcement',
      'category': 'Announcement',
      'excerpt': 'The annual student council elections will be held next month. Nomination period opens soon...',
      'content': 'The school is preparing for the annual Student Council elections. This is an opportunity for students to demonstrate leadership and contribute to school governance.\n\nImportant Dates:\n- Nomination Period: November 15-25\n- Campaign Period: November 26 - December 5\n- Election Day: December 6\n- Results Announcement: December 7\n\nEligible students who wish to run for positions should submit their nomination forms to the Student Affairs Office. Detailed requirements and guidelines are available on the school website.\n\nLet\'s exercise our democratic rights and choose the best leaders for our school!',
      'author': 'Student Affairs',
      'date': '4 days ago',
      'readTime': '3 min read',
      'image': null,
      'views': 278,
      'isImportant': true,
    },
    {
      'id': 'news_7',
      'title': 'Art Exhibition Features Student Masterpieces',
      'category': 'Event',
      'excerpt': 'The annual art exhibition showcases incredible works from our talented student artists...',
      'content': 'Our school\'s annual art exhibition is currently on display in the Art Gallery, featuring stunning works from students across all grades.\n\nExhibition Details:\n- Duration: November 10-30\n- Location: School Art Gallery\n- Opening Hours: 9 AM - 5 PM (Monday-Friday)\n- Free Entry\n\nThe exhibition includes various art forms including paintings, sculptures, digital art, and photography. Many pieces reflect themes of diversity, innovation, and youth perspectives.\n\nVisitors are welcome! Come support our talented student artists and appreciate their creativity.',
      'author': 'Art Club',
      'date': '5 days ago',
      'readTime': '2 min read',
      'image': 'assets/images/detail/art.jpeg',
      'views': 167,
      'isImportant': false,
    },
    {
      'id': 'news_8',
      'title': 'School Orchestra Performs at National Music Festival',
      'category': 'Achievement',
      'excerpt': 'Our school orchestra will perform at the National Music Festival 2027, representing SMKN 20 Jakarta...',
      'content': 'SMKN 20 Jakarta\'s Orchestra has been selected to perform at the prestigious National Music Festival 2027 in Jakarta Convention Center. This is a remarkable achievement as we are one of only 10 schools invited from across Indonesia.\n\nOur talented musicians have been rehearsing intensively for the past three months, preparing a diverse repertoire including classical, contemporary, and traditional Indonesian music.\n\nPerformance Details:\n- Date: December 15, 2027\n- Time: 19:00 WIB\n- Venue: Jakarta Convention Center\n\nTickets are available for students and parents who wish to attend. Let\'s show our support!',
      'author': 'Arts Department',
      'date': '6 days ago',
      'readTime': '3 min read',
      'image': 'assets/images/detail/music.jpeg',
      'views': 189,
      'isImportant': false,
    },
    {
      'id': 'news_9',
      'title': 'School Newsletter: November 2027 Edition Released',
      'category': 'Announcement',
      'excerpt': 'The latest edition of our school newsletter is here with exciting stories, interviews, and updates...',
      'content': 'The November 2027 edition of our school newsletter "SMKN 20 Insight" is now available! This month\'s edition features exciting stories, interviews, and updates from our school community.\n\nHighlights in This Edition:\n- Cover Story: Innovation in Education\n- Interview: Principal\'s Vision for 2028\n- Photo Essay: Behind the Scenes of Classmeet 2027\n- Student Spotlight: Meet Our National Champions\n- Study Tips from Top Students\n\nThe newsletter is available in both digital and printed formats. Digital copies can be accessed through the school portal.\n\nWe welcome contributions from students for our next edition!',
      'author': 'Communications Team',
      'date': '1 week ago',
      'readTime': '4 min read',
      'image': 'assets/images/detail/news.jpeg',
      'views': 278,
      'isImportant': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredNews {
    if (_selectedFilter == 'All') {
      return _allNews;
    }
    return _allNews.where((news) => news['category'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Gradient
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: const Color(0xFF2980B9),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF6DD5FA), // Light blue
                      Color(0xFF2980B9), // Medium blue
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -50,
                      bottom: -50,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.newspaper_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'News & Updates',
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter Chips
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF6DD5FA), // Light blue
                                    Color(0xFF2980B9), // Medium blue
                                  ],
                                )
                              : null,
                          color: isSelected ? null : AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : AppColors.border,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF2980B9).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          filter,
                          style: AppTextStyles.body2.copyWith(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // News List
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final news = _filteredNews[index];
                  return _buildNewsCard(context, news, index);
                },
                childCount: _filteredNews.length,
              ),
            ),
          ),

          const SliverPadding(
            padding: EdgeInsets.only(bottom: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, Map<String, dynamic> news, int index) {
    final hasImage = news['image'] != null;
    
    return GestureDetector(
      onTap: () {
        context.push(RouteNames.newsDetail.replaceAll(':id', news['id']));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: news['isImportant'] 
                ? const Color(0xFF2980B9).withValues(alpha: 0.3)
                : AppColors.border,
            width: news['isImportant'] ? 1.5 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image or Header with Gradient
            if (hasImage)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Stack(
                  children: [
                    Image.asset(
                      news['image'],
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getCategoryColor(news['category']),
                                _getCategoryColor(news['category']).withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.5),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    // Category Badge on Image
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _buildCategoryBadge(news['category']),
                    ),
                    if (news['isImportant'])
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.priority_high_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Important',
                                style: AppTextStyles.captionSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getCategoryColor(news['category']).withValues(alpha: 0.15),
                      _getCategoryColor(news['category']).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(
                        _getCategoryIcon(news['category']),
                        size: 80,
                        color: _getCategoryColor(news['category']).withValues(alpha: 0.2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCategoryBadge(news['category']),
                          if (news['isImportant'])
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.priority_high_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Important',
                                    style: AppTextStyles.captionSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    news['title'],
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Excerpt
                  Text(
                    news['excerpt'],
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Meta Info
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        news['author'],
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        news['date'],
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${news['views']}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _getCategoryColor(category),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(category),
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            category,
            style: AppTextStyles.captionSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Event':
        return AppColors.categoryClassmeet;
      case 'Academic':
        return AppColors.categorySeminar;
      case 'Achievement':
        return AppColors.warning;
      case 'Announcement':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Event':
        return Icons.event_rounded;
      case 'Academic':
        return Icons.school_rounded;
      case 'Achievement':
        return Icons.emoji_events_rounded;
      case 'Announcement':
        return Icons.campaign_rounded;
      default:
        return Icons.article_rounded;
    }
  }
}
