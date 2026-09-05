import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';

class NewsDetailScreen extends StatelessWidget {
  final String newsId;

  const NewsDetailScreen({super.key, required this.newsId});

  // Get news data by ID
  Map<String, dynamic> _getNewsData() {
    final allNews = {
      'news_0': {
        'title': 'SMKN 20 Jakarta Wins National Programming Competition',
        'category': 'Achievement',
        'content': 'SMKN 20 Jakarta programming team has achieved a remarkable victory at the National Coding Championship 2027 held in Surabaya. The team, consisting of three talented students, competed against 50 teams from various schools across Indonesia.\n\nThe competition lasted for two days and included multiple challenging rounds including algorithm design, web development, and mobile app creation. Our team demonstrated exceptional skills and teamwork throughout the competition.\n\nKey Achievements:\n• First Place in Algorithm Design\n• Best Mobile App Award\n• Team Spirit Award\n\nThe winning team members are:\n1. Ahmad Rizky (XII RPL 1) - Team Leader\n2. Siti Nurhaliza (XII RPL 1) - Backend Developer\n3. Budi Santoso (XII RPL 2) - Frontend Developer\n\nCongratulations to our winners and special thanks to Mr. Hendra and Ms. Fitri, the coaches who have dedicated their time and expertise to train our students. This achievement brings great pride to our school and demonstrates the quality of education in computer science at SMKN 20 Jakarta.',
        'author': 'Admin OSIS',
        'date': '2 hours ago',
        'readTime': '3 min read',
        'image': 'assets/images/banner/workshop-coding-banner.jpeg',
        'views': 234,
      },
      'news_1': {
        'title': 'Basketball Team Advances to Regional Finals',
        'category': 'Achievement',
        'content': 'Our school basketball team has made history by advancing to the regional finals after defeating their opponents 78-72 in an intense semi-final match.\n\nThe game was closely contested throughout, with both teams displaying excellent skills and sportsmanship. Our team\'s perseverance and strategic play in the final quarter proved to be the winning factor.\n\nMatch Highlights:\n• Outstanding performance by team captain\n• 25 points scored in the final quarter\n• Excellent defensive strategy\n• Strong team coordination\n\nThe regional finals will be held next month at the Regional Sports Complex. This is a historic moment for our school as this is the first time our basketball team has reached the regional finals in the past five years.\n\nWe encourage all students, teachers, and parents to come and support our team. Let\'s show them our school spirit and cheer them on to victory!\n\nMatch Details:\n- Date: December 15, 2027\n- Time: 3:00 PM\n- Venue: Regional Sports Complex\n- Entry: Free for students with ID',
        'author': 'Sports Club',
        'date': '5 hours ago',
        'readTime': '2 min read',
        'image': 'assets/images/banner/basket-banner.jpeg',
        'views': 187,
      },
      'news_2': {
        'title': 'Important: Final Exam Schedule Released',
        'category': 'Academic',
        'content': 'The Academic Affairs Office has released the final examination schedule for the current semester. All students are advised to review the schedule carefully and prepare accordingly.\n\nKey Dates:\n• Examination Period: December 10-20, 2027\n• Review Sessions: December 1-8, 2027\n• Results Announcement: January 5, 2028\n\nImportant Guidelines:\n1. Students must arrive 30 minutes before exam time\n2. Bring student ID card and exam card\n3. No electronic devices allowed during exams\n4. Late arrivals will not be permitted\n\nThe detailed examination schedule is available on:\n- School website (www.smkn20jakarta.sch.id)\n- Student portal\n- Information boards in each building\n\nPreparation Tips:\n- Start reviewing early\n- Create a study schedule\n- Join study groups\n- Attend review sessions\n- Get adequate rest\n\nStudents with scheduling conflicts or special requirements should contact the Academic Affairs Office at academics@smkn20jakarta.sch.id or visit Room 201 during office hours (8 AM - 4 PM).\n\nGood luck with your preparations! We believe in your potential to excel.',
        'author': 'Academic Affairs',
        'date': '1 day ago',
        'readTime': '4 min read',
        'image': null,
        'views': 456,
      },
      'news_3': {
        'title': 'Career Day 2027 Registration Now Open',
        'category': 'Event',
        'content': 'We are excited to announce that registration for Career Day 2027 is now open! This year\'s event will feature speakers from various industries including technology, healthcare, finance, and creative arts.\n\nEvent Highlights:\n• Keynote speeches from industry leaders\n• Interactive workshops and seminars\n• One-on-one career counseling sessions\n• Company booth exhibitions\n• Networking opportunities\n• Resume review sessions\n\nConfirmed Speakers:\n1. Dr. Sarah Johnson - Tech Entrepreneur\n2. Ahmad Dhani - Creative Director\n3. Linda Wijaya - Finance Manager at Bank Mandiri\n4. Dr. Bambang Sutrisno - Medical Director\n\nWorkshops Available:\n- CV Writing Workshop\n- Interview Skills Training\n- Personal Branding in Digital Age\n- Entrepreneurship Basics\n\nParticipating Companies:\n- Google Indonesia\n- Gojek\n- Tokopedia\n- Bank Mandiri\n- And many more!\n\nRegistration is free but seats are limited to 300 participants. Sign up through the Events page before November 30th to secure your spot.\n\nThis is a valuable opportunity to:\n- Gain insights into various career paths\n- Make important connections for your future\n- Learn directly from industry professionals\n- Explore potential internship opportunities\n\nDon\'t miss this chance to plan your future career!',
        'author': 'Guidance Counseling',
        'date': '1 day ago',
        'readTime': '3 min read',
        'image': 'assets/images/banner/career-banner.jpeg',
        'views': 312,
      },
      'news_4': {
        'title': 'New Library Digital Resources Available',
        'category': 'Academic',
        'content': 'We are pleased to announce that our school library has expanded its digital collection with hundreds of new e-books and access to online academic journals.\n\nNew Resources Include:\n• 500+ e-books across various subjects\n• Academic journals from major publishers\n• Research databases for student projects\n• Interactive learning modules\n• Audio books for language learning\n\nSubject Categories:\n- Computer Science & Programming\n- Mathematics & Physics\n- Literature & Languages\n- Social Sciences\n- Arts & Design\n- Business & Economics\n\nHow to Access:\n1. Visit library.smkn20jakarta.sch.id\n2. Login using your student ID\n3. Browse or search for resources\n4. Download or read online\n\nAll students can access these resources 24/7 from anywhere using their student ID and password through the library portal.\n\nThe library staff is available to provide:\n- Orientation sessions\n- Search assistance\n- Citation guidance\n- Technical support\n\nLibrary Contact:\n- Email: library@smkn20jakarta.sch.id\n- Phone: (021) 1234-5678\n- Hours: Monday-Friday, 7:00 AM - 5:00 PM\n\nWe encourage all students to take advantage of these valuable learning resources!',
        'author': 'Library Staff',
        'date': '2 days ago',
        'readTime': '2 min read',
        'image': null,
        'views': 145,
      },
      'news_5': {
        'title': 'Class Meeting 2027 Spectacular Success',
        'category': 'Event',
        'content': 'Class Meeting 2027 concluded with great success, featuring various competitions that showcased our students\' talents and spirit.\n\nCompetition Results:\n\nSports:\n• Basketball Championship: Class XII RPL 1\n• Futsal Tournament: Class XI RPL 2\n• Volleyball Cup: Class XII TKJ 1\n• Badminton Singles: Ahmad (XI RPL 1)\n• Table Tennis: Siti (XII TKJ 2)\n\nAcademics:\n• Academic Quiz: Class XI RPL 1\n• Debate Competition: Class XII TKJ 1\n• Essay Writing: Budi (XII RPL 2)\n\nArts:\n• Singing Competition: Dian (XI RPL 2)\n• Dance Performance: Class XII RPL 1\n• Art Exhibition: Class XI TKJ 2\n\nSpecial Awards:\n• Best Supporter Class: XII RPL 2\n• Fair Play Award: XI TKJ 1\n• Most Creative Class: XI RPL 1\n\nEvent Statistics:\n- Total Participants: 500+ students\n- Events Held: 15 competitions\n- Days Duration: 3 days\n- Committee Members: 50 students\n\nCongratulations to all winners and participants! Your enthusiasm and sportsmanship made this event truly memorable.\n\nSpecial thanks to:\n- OSIS Executive Board\n- All committee members\n- Teachers and staff\n- Sponsors and supporters\n\nStay tuned for more exciting school events!',
        'author': 'Admin OSIS',
        'date': '3 days ago',
        'readTime': '4 min read',
        'image': 'assets/images/banner/classmeet-banner.jpeg',
        'views': 523,
      },
      'news_6': {
        'title': 'Student Council Elections Announcement',
        'category': 'Announcement',
        'content': 'The school is preparing for the annual Student Council elections. This is an opportunity for students to demonstrate leadership and contribute to school governance.\n\nImportant Dates:\n• Nomination Period: November 15-25\n• Campaign Period: November 26 - December 5\n• Candidates Debate: December 3\n• Election Day: December 6\n• Results Announcement: December 7\n\nPositions Available:\n1. President\n2. Vice President\n3. Secretary\n4. Treasurer\n5. Department Heads (5 positions)\n\nEligibility Requirements:\n- Grade 10 or 11 students\n- Minimum GPA of 3.0\n- Good discipline record\n- Active in extracurricular activities\n- Endorsement from homeroom teacher\n\nNomination Process:\n1. Download nomination form from school website\n2. Complete all required information\n3. Gather required endorsements\n4. Submit to Student Affairs Office (Room 301)\n5. Attend mandatory candidates briefing\n\nCampaign Guidelines:\n- Respectful and professional conduct\n- Creative but appropriate materials\n- Follow school regulations\n- No negative campaigning\n\nVoting Process:\n- Electronic voting system\n- One vote per student\n- Anonymous and secure\n- Results verified by independent committee\n\nFor detailed requirements and guidelines:\n- Visit: www.smkn20jakarta.sch.id/elections\n- Email: studentaffairs@smkn20jakarta.sch.id\n- Visit: Student Affairs Office, Room 301\n\nLet\'s exercise our democratic rights and choose the best leaders for our school! Your voice matters!',
        'author': 'Student Affairs',
        'date': '4 days ago',
        'readTime': '3 min read',
        'image': null,
        'views': 278,
      },
      'news_7': {
        'title': 'Art Exhibition Features Student Masterpieces',
        'category': 'Event',
        'content': 'Our school\'s annual art exhibition is currently on display in the Art Gallery, featuring stunning works from students across all grades.\n\nExhibition Details:\n• Duration: November 10-30, 2027\n• Location: School Art Gallery, Building C, Floor 2\n• Opening Hours: 9 AM - 5 PM (Monday-Friday)\n• Entry: Free for all students and staff\n• Guided Tours: Available upon request\n\nArtwork Categories:\n1. Paintings (Oil, Acrylic, Watercolor)\n2. Sculptures (Clay, Wire, Mixed Media)\n3. Digital Art & Graphic Design\n4. Photography\n5. Traditional Indonesian Art\n6. Calligraphy\n\nFeatured Artists:\n- Dina Permata (XII): "Urban Dreams" series\n- Raka Wijaya (XI): Sculpture installations\n- Sari Indah (X): Digital art collection\n- Ahmad Faiz (XII): Photography portfolio\n\nExhibition Themes:\n• Diversity & Unity\n• Innovation & Technology\n• Youth Perspectives\n• Indonesian Heritage\n• Environmental Awareness\n\nSpecial Events:\n- Artist Talk: November 15, 2 PM\n- Workshop: "Introduction to Digital Art"\n- Closing Ceremony: November 30, 3 PM\n\nMany pieces reflect deep thoughts about contemporary issues affecting young people today. The creativity and skill demonstrated by our students is truly impressive.\n\nVisitors are welcome! Come support our talented student artists and appreciate their creativity. Photography is allowed but please respect the artworks.\n\nFor group visits or guided tours:\n- Contact: artclub@smkn20jakarta.sch.id\n- Phone: (021) 1234-5678 ext. 204',
        'author': 'Art Club',
        'date': '5 days ago',
        'readTime': '2 min read',
        'image': 'assets/images/banner/art-banner.jpeg',
        'views': 167,
      },
    };

    return allNews[newsId] ?? {
      'title': 'News Not Found',
      'category': 'General',
      'content': 'The requested news article could not be found.',
      'author': 'Admin',
      'date': 'Unknown',
      'readTime': '1 min read',
      'image': null,
      'views': 0,
    };
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

  @override
  Widget build(BuildContext context) {
    final news = _getNewsData();
    final categoryColor = _getCategoryColor(news['category']);
    final hasImage = news['image'] != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image or Gradient
          SliverAppBar(
            expandedHeight: hasImage ? 280 : 200,
            pinned: true,
            backgroundColor: const Color(0xFF2980B9),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.arrow_back, color: const Color(0xFF2980B9), size: 20),
                ),
                onPressed: () => context.pop(),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.share_rounded, color: const Color(0xFF2980B9), size: 20),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share feature coming soon!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.bookmark_outline_rounded, color: const Color(0xFF2980B9), size: 20),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bookmark saved!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image or Gradient
                  if (hasImage)
                    Image.asset(
                      news['image']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
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
                        );
                      },
                    )
                  else
                    Container(
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
                    ),

                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Category Badge
                  Positioned(
                    top: 90,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(news['category']),
                            size: 14,
                            color: categoryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            news['category'],
                            style: AppTextStyles.captionSmall.copyWith(
                              color: categoryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  
                  // Title
                  Text(
                    news['title'],
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Meta Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          categoryColor.withValues(alpha: 0.08),
                          categoryColor.withValues(alpha: 0.03),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: categoryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: categoryColor.withValues(alpha: 0.15),
                          child: Icon(
                            Icons.person_rounded,
                            color: categoryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                news['author'],
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${news['date']} • ${news['readTime']}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.visibility_outlined,
                                    size: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${news['views']} views',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
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
                  
                  const SizedBox(height: 24),
                  
                  // Content
                  Text(
                    news['content'],
                    style: AppTextStyles.body1.copyWith(
                      height: 1.8,
                      fontSize: 15,
                      letterSpacing: 0.2,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Share Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          categoryColor.withValues(alpha: 0.1),
                          categoryColor.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: categoryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.thumb_up_outlined,
                              color: categoryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Found this helpful?',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                context,
                                icon: Icons.thumb_up_outlined,
                                label: 'Helpful',
                                color: categoryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                context,
                                icon: Icons.share_rounded,
                                label: 'Share',
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label feature coming soon!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
