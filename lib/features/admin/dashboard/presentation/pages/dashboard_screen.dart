import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/routes/route_names.dart';
import '../../../../../core/providers/auth_provider.dart';
import '../../../../../core/services/event_service.dart';
import '../../../../../core/services/registration_service.dart';
import '../../../../../core/models/event_model.dart';
import '../../../../../core/models/registration_model.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _eventService = EventService();
  final _registrationService = RegistrationService();
  final _supabase = Supabase.instance.client;

  // Stats
  int _totalEvents = 0;
  int _activeEvents = 0;
  int _totalParticipants = 0;
  int _pendingRegistrations = 0;

  // Today's events
  List<EventModel> _todayEvents = [];

  // State
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // ================================================================
  // LOAD DASHBOARD DATA
  // ================================================================

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch all data in parallel for performance
      final results = await Future.wait([
        _fetchTotalEvents(),
        _fetchActiveEvents(),
        _fetchTotalParticipants(),
        _fetchPendingRegistrations(),
        _fetchTodayEvents(),
      ]);

      if (!mounted) return;

      setState(() {
        _totalEvents = results[0] as int;
        _activeEvents = results[1] as int;
        _totalParticipants = results[2] as int;
        _pendingRegistrations = results[3] as int;
        _todayEvents = results[4] as List<EventModel>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data dashboard. Silakan coba lagi.';
      });
    }
  }

  // ================================================================
  // FETCH METHODS
  // ================================================================

  /// Total Events = COUNT(*) FROM events WHERE is_published = true
  Future<int> _fetchTotalEvents() async {
    final events = await _eventService.getAllEvents();
    return events.where((e) => e.isPublished).length;
  }

  /// Active Events = COUNT(*) FROM events
  /// WHERE status='open' AND is_published=true AND is_registration_open=true
  Future<int> _fetchActiveEvents() async {
    final events = await _eventService.getAllEvents();
    return events
        .where((e) =>
            e.status.toLowerCase() == 'open' &&
            e.isPublished &&
            e.isRegistrationOpen)
        .length;
  }

  /// Total Participants = COUNT(*) FROM participants
  /// WHERE status IN ('approved', 'attended')
  Future<int> _fetchTotalParticipants() async {
    try {
      final response = await _supabase
          .from('participants')
          .select()
          .inFilter('status', ['approved', 'attended']);

      return (response as List).length;
    } catch (e) {
      // If participants query fails, return 0
      return 0;
    }
  }

  /// Pending Registrations = COUNT(*) FROM registrations WHERE status='pending'
  Future<int> _fetchPendingRegistrations() async {
    final registrations = await _registrationService.getAllRegistrations();
    return registrations
        .where((r) => r.status == RegistrationStatus.pending)
        .length;
  }

  /// Today's Events = SELECT * FROM events
  /// WHERE DATE(date) = CURRENT_DATE AND is_published = true
  /// ORDER BY time
  Future<List<EventModel>> _fetchTodayEvents() async {
    final events = await _eventService.getAllEvents();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return events
        .where((e) {
          final eventDate = DateTime(e.date.year, e.date.month, e.date.day);
          return eventDate == today && e.isPublished;
        })
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Decorative Background Elements
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.categoryClassmeet.withValues(alpha: 0.1),
                    AppColors.categoryClassmeet.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 150,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.success.withValues(alpha: 0.08),
                    AppColors.success.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _buildLoadedState(authService),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // LOADING STATE
  // ================================================================

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Memuat data dashboard...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // ERROR STATE
  // ================================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // LOADED STATE
  // ================================================================

  Widget _buildLoadedState(dynamic authService) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.paddingLG),
                Text(
                  'Dashboard',
                  style: AppTextStyles.heading1,
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome back, ${authService.userName}',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.sectionGap),
        ),

        // Statistics Cards
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontalPadding,
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard(
                  'Total Events',
                  '$_totalEvents',
                  Icons.event,
                  AppColors.categoryClassmeet,
                ),
                _buildStatCard(
                  'Active Events',
                  '$_activeEvents',
                  Icons.event_available,
                  AppColors.success,
                ),
                _buildStatCard(
                  'Participants',
                  '$_totalParticipants',
                  Icons.people,
                  AppColors.info,
                ),
                _buildStatCard(
                  'Pending',
                  '$_pendingRegistrations',
                  Icons.pending,
                  AppColors.warning,
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.sectionGap),
        ),

        // Quick Menu
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Menu',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: AppSpacing.paddingLG),

                // Main Quick Menu (2x2 Grid)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildQuickMenuItem(
                      context,
                      'Buat Event',
                      Icons.add_circle,
                      AppColors.primary,
                      () => context.push(RouteNames.adminCreateEvent),
                    ),
                    _buildQuickMenuItem(
                      context,
                      'Pengumuman',
                      Icons.campaign,
                      AppColors.info,
                      () => context.go(RouteNames.adminAnnouncement),
                    ),
                    _buildQuickMenuItem(
                      context,
                      'Peserta',
                      Icons.people,
                      AppColors.success,
                      () => context.go(RouteNames.adminParticipants),
                    ),
                    _buildQuickMenuItem(
                      context,
                      'Sertifikat',
                      Icons.workspace_premium,
                      AppColors.secondary,
                      () => context.push(RouteNames.adminCertificate),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Secondary Access
                Text(
                  'Akses Lainnya',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildSecondaryMenuItem(
                        context,
                        'Dokumentasi',
                        Icons.folder_open,
                        AppColors.categoryWorkshop,
                        () => context.push(RouteNames.adminDocumentation),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSecondaryMenuItem(
                        context,
                        'Messages',
                        Icons.message,
                        AppColors.categorySports,
                        () => context.push(RouteNames.adminMessages),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.sectionGap),
        ),

        // Today's Events Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontalPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Events",
                  style: AppTextStyles.heading3,
                ),
                if (_todayEvents.isNotEmpty)
                  Text(
                    '${_todayEvents.length} event${_todayEvents.length > 1 ? 's' : ''}',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.paddingLG),
        ),

        // Today's Events List or Empty State
        _todayEvents.isEmpty
            ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.horizontalPadding,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada event hari ini',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Event yang dijadwalkan hari ini akan muncul di sini',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontalPadding,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final event = _todayEvents[index];
                      return _buildTodayEventCard(event);
                    },
                    childCount: _todayEvents.length,
                  ),
                ),
              ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  // ================================================================
  // STAT CARD
  // ================================================================

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.card,
            color.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(color: AppColors.border, width: 0.5),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: AppTextStyles.body2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // TODAY'S EVENT CARD
  // ================================================================

  Widget _buildTodayEventCard(EventModel event) {
    // Determine status color
    Color statusColor;
    String statusText;

    if (event.status.toLowerCase() == 'ongoing') {
      statusColor = AppColors.success;
      statusText = 'Ongoing';
    } else if (event.status.toLowerCase() == 'open') {
      statusColor = AppColors.info;
      statusText = 'Upcoming';
    } else {
      statusColor = AppColors.textTertiary;
      statusText = 'Closed';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.paddingMD),
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Date indicator
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary10,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${event.date.day}',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    _getMonthAbbreviation(event.date.month),
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.paddingLG),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTextStyles.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  event.time,
                  style: AppTextStyles.body2,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: AppTextStyles.captionSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }

  // ================================================================
  // QUICK MENU ITEMS
  // ================================================================

  Widget _buildQuickMenuItem(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: AppTextStyles.captionSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryMenuItem(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // HELPERS
  // ================================================================

  String _getMonthAbbreviation(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    return months[month - 1];
  }
}
