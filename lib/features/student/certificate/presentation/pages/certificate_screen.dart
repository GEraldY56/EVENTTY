import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/services/certificate_service.dart';
import '../../../../../core/utils/logger.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> with SingleTickerProviderStateMixin {
  final _certificateService = CertificateService();
  List<Map<String, dynamic>> _certificates = [];
  bool _isLoading = true;
  
  // Tab Controller
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _loadCertificates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCertificates() async {
    setState(() => _isLoading = true);
    
    try {
      // Get stored student ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString('userId');
      
      if (studentId == null) {
        setState(() => _isLoading = false);
        return;
      }
      
      // Get certificates dari Supabase
      final certs = await _certificateService.getStudentCertificates(studentId);
      
      // Convert to map untuk UI
      _certificates = certs.map((cert) {
        // Determine certificate type
        String type = 'event'; // default
        final achievement = cert.achievement?.toLowerCase() ?? '';
        if (achievement.contains('juara') || achievement.contains('winner')) {
          type = 'prestasi';
        }
        
        return {
          'id': cert.id,
          'eventName': cert.eventTitle,
          'category': cert.eventCategory,
          'date': '${cert.issuedDate.day} ${_getMonthName(cert.issuedDate.month)} ${cert.issuedDate.year}',
          'status': 'ready',
          'color': _getCategoryColor(cert.eventCategory),
          'achievement': cert.achievement ?? 'Participation',
          'type': type, // 'event' or 'prestasi'
          'organizer': 'OSIS SMKN 20 Jakarta',
        };
      }).toList();
      
      setState(() => _isLoading = false);
    } catch (e) {
      AppLogger.error('Error loading certificates', e);
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredCertificates {
    if (_selectedTabIndex == 0) {
      return _certificates; // Semua
    } else if (_selectedTabIndex == 1) {
      return _certificates.where((c) => c['type'] == 'event').toList(); // Sertifikat Event
    } else {
      return _certificates.where((c) => c['type'] == 'prestasi').toList(); // Sertifikat Prestasi
    }
  }

  Color _getCategoryColor(String category) {
    if (category.toLowerCase().contains('sport')) return AppColors.categorySports;
    if (category.toLowerCase().contains('seminar')) return AppColors.categorySeminar;
    if (category.toLowerCase().contains('workshop')) return AppColors.categoryWorkshop;
    if (category.toLowerCase().contains('career')) return AppColors.categoryCareer;
    if (category.toLowerCase().contains('classmeet')) return AppColors.categoryClassmeet;
    return AppColors.primary;
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Certificate',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false, // Remove back button karena ini tab
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppColors.textPrimary),
            onPressed: () {
              // Filter action
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats Card with Trophy
                _buildStatsCard(),
                
                // Tabs
                _buildTabs(),
                
                // Certificate List
                Expanded(
                  child: _filteredCertificates.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
                          itemCount: _filteredCertificates.length,
                          itemBuilder: (context, index) {
                            return _buildCertificateListItem(
                              context,
                              _filteredCertificates[index],
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.horizontalPadding),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6DD5FA).withValues(alpha: 0.2),
            const Color(0xFF2980B9).withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2980B9).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Left: Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Sertifikat',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_certificates.length}',
                  style: AppTextStyles.heading1.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2980B9),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Terus tingkatkan dan\nkumpulkan lebih banyak sertifikat!',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          // Right: 3D Trophy Illustration
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFDB931).withValues(alpha: 0.3),
                  const Color(0xFFF7941D).withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Trophy icon with shadow effect for 3D look
                Positioned(
                  bottom: 20,
                  child: Container(
                    width: 50,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                // Trophy
                Transform.translate(
                  offset: const Offset(0, -5),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFDB931),
                          Color(0xFFF7941D),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF7941D).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Shine effect
                Positioned(
                  top: 15,
                  right: 20,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF2980B9),
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.body2.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.body2,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Color(0xFF2980B9),
            width: 3,
          ),
          insets: EdgeInsets.symmetric(horizontal: 16),
        ),
        tabs: const [
          Tab(text: 'Semua'),
          Tab(text: 'Sertifikat Event'),
          Tab(text: 'Sertifikat Prestasi'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    if (_selectedTabIndex == 1) {
      message = 'Belum ada sertifikat event';
    } else if (_selectedTabIndex == 2) {
      message = 'Belum ada sertifikat prestasi';
    } else {
      message = 'Belum ada sertifikat';
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 80,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ikuti event dan dapatkan sertifikat',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateListItem(BuildContext context, Map<String, dynamic> cert) {
    final color = cert['color'] as Color;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to certificate detail
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening ${cert['eventName']} certificate...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Certificate Thumbnail
                Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.15),
                        color.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative lines
                      Positioned(
                        top: 20,
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 28,
                        left: 15,
                        right: 15,
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(0.5),
                          ),
                        ),
                      ),
                      // Certificate icon
                      Center(
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          size: 32,
                          color: color,
                        ),
                      ),
                      // Achievement badge
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: color.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              cert['type'] == 'prestasi' ? 'PRESTASI' : 'EVENT',
                              style: AppTextStyles.captionSmall.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 8,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Certificate Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Name
                      Text(
                        cert['eventName'],
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      
                      // Date
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            cert['date'],
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Organizer
                      Row(
                        children: [
                          Icon(
                            Icons.business_rounded,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              cert['organizer'],
                              style: AppTextStyles.captionSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Status & Download
                      Row(
                        children: [
                          // Status
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tersedia',
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          // Download button
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Downloading ${cert['eventName']}...'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2980B9).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.download_rounded,
                                size: 16,
                                color: Color(0xFF2980B9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Arrow
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
