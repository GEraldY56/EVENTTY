import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/services/registration_service.dart';
import '../../../../../core/services/event_service.dart';
import '../../../../../core/services/bookmark_service.dart';
import '../../../../../core/services/documentation_service.dart';
import '../../../../../core/models/event_model.dart';
import '../../../../../core/models/documentation_model.dart';
import '../../../../../core/providers/message_context_provider.dart';
import '../../../../../core/providers/auth_provider.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../widgets/registration_dialog_simple.dart';

class EventDetailScreenNew extends ConsumerStatefulWidget {
  final String eventId;

  const EventDetailScreenNew({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreenNew> createState() => _EventDetailScreenNewState();
}

class _EventDetailScreenNewState extends ConsumerState<EventDetailScreenNew> {
  final RegistrationService _registrationService = RegistrationService();
  final EventService _eventService = EventService();
  final BookmarkService _bookmarkService = BookmarkService();
  final DocumentationService _documentationService = DocumentationService();
  
  bool _isRegistered = false;
  bool _isBookmarked = false;
  EventModel? _event;
  DocumentationModel? _documentation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadEvent();
    await _checkRegistrationStatus();
    await _checkBookmarkStatus();
    await _loadDocumentation();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadEvent() async {
    final event = await _eventService.getEventById(widget.eventId);
    if (mounted) {
      setState(() => _event = event);
    }
  }

  Future<void> _checkRegistrationStatus() async {
    final authService = ref.read(authServiceProvider);
    final userId = authService.userId ?? '';

    final isRegistered = await _registrationService.isUserRegistered(
      userId,
      widget.eventId,
    );

    if (mounted) {
      setState(() => _isRegistered = isRegistered);
    }
  }

  Future<void> _checkBookmarkStatus() async {
    final authService = ref.read(authServiceProvider);
    final userId = authService.userId ?? '';
    final isBookmarked = await _bookmarkService.isBookmarked(userId, widget.eventId);
    if (mounted) {
      setState(() => _isBookmarked = isBookmarked);
    }
  }

  Future<void> _toggleBookmark() async {
    final authService = ref.read(authServiceProvider);
    final userId = authService.userId ?? '';
    
    await _bookmarkService.toggleBookmark(userId, widget.eventId);
    await _checkBookmarkStatus();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBookmarked ? 'Event disimpan' : 'Event dihapus dari bookmark'),
          backgroundColor: _isBookmarked ? AppColors.success : AppColors.textSecondary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _loadDocumentation() async {
    try {
      final doc = await _documentationService.getDocumentationByEventId(widget.eventId);
      if (mounted) {
        setState(() => _documentation = doc);
      }
    } catch (e) {
      // Documentation is optional, so don't show error
      if (mounted) {
        setState(() => _documentation = null);
      }
    }
  }

  Future<void> _shareEvent() async {
    if (_event == null) return;
    
    final shareText = '''
🎉 ${_event!.title}

${_event!.description.substring(0, _event!.description.length > 100 ? 100 : _event!.description.length)}...

📅 ${DateFormat('d MMMM yyyy').format(_event!.date)}
⏰ ${_event!.time}
📍 ${_event!.location}

Daftar sekarang di aplikasi EVENTTY!
''';

    try {
      await Share.share(shareText);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membagikan event')),
        );
      }
    }
  }

  void _showRegistrationDialog() {
    if (_event == null) return;
    
    final authService = ref.read(authServiceProvider);
    final userName = authService.userName ?? 'User';
    final userNis = authService.userId ?? '';
    final userId = authService.userId ?? '';
    final userKelas = authService.userClass ?? 'XII RPL 1';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleRegistrationDialog(
        event: _event!,
        userName: userName,
        userNis: userNis,
        userId: userId,
        userKelas: userKelas,
        onSubmit: (formData) async {
          final result = await _registrationService.registerIndividual(
            eventId: widget.eventId,
            userId: userId,
            userName: userName,
            formData: formData,
          );

          if (!mounted) return;
          
          if (context.mounted) {
            Navigator.pop(context);

            if (result.success) {
              setState(() => _isRegistered = true);
              _showSuccessDialog(result.message);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
            ),
            const SizedBox(height: 16),
            Text('Berhasil!', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text(message, style: AppTextStyles.body1, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (_event!.category.toLowerCase()) {
      case 'classmeet':
        return AppColors.categoryClassmeet;
      case 'career':
      case 'career development':
        return AppColors.categoryCareer;
      case 'sports':
      case 'sports competition':
        return AppColors.categorySports;
      case 'seminar':
        return AppColors.categorySeminar;
      case 'workshop':
        return AppColors.categoryWorkshop;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_event == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Event tidak ditemukan', style: AppTextStyles.heading3),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan Image
            _buildHeader(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Registration Status Card
                    _buildRegistrationStatusCard(),
                    
                    const SizedBox(height: 16),
                    
                    // Quick Info Grid
                    _buildQuickInfoGrid(),
                    
                    const SizedBox(height: 20),
                    
                    // Tentang Event
                    _buildSectionTitle('Tentang Event'),
                    const SizedBox(height: 12),
                    Text(
                      _event!.description,
                      style: AppTextStyles.body2.copyWith(
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Highlight Event
                    _buildHighlightSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Action Grid
                    _buildActionGrid(),
                    
                    const SizedBox(height: 24),
                    
                    // Additional Info
                    _buildAdditionalInfo(),
                    
                    const SizedBox(height: 24),
                    
                    // Documentation Section
                    if (_documentation != null) _buildDocumentationSection(),
                    
                    if (_documentation != null) const SizedBox(height: 24),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Button
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        // Hero Image
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_getCategoryColor().withValues(alpha: 0.3), _getCategoryColor()],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: _event!.imageUrl != null && _event!.imageUrl!.isNotEmpty
              ? Image.asset(
                  _event!.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                )
              : Center(
                  child: Icon(
                    Icons.event,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
        ),
        
        // Top Bar with Icons
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconButton(Icons.arrow_back, () => context.pop()),
              Row(
                children: [
                  _buildIconButton(Icons.share, _shareEvent),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    _toggleBookmark,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Category and Title at bottom of image
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _getCategoryColor(),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sports_basketball, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      _event!.category,
                      style: AppTextStyles.captionSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // Title
              Text(
                _event!.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _event!.status == 'open' 
                      ? AppColors.success 
                      : AppColors.error,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      _event!.status == 'open' ? 'Pendaftaran Dibuka' : 'Pendaftaran Ditutup',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildRegistrationStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getCategoryColor().withValues(alpha: 0.05),
            _getCategoryColor().withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getCategoryColor().withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getCategoryColor().withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.groups, color: _getCategoryColor(), size: 24),
          ),
          
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _event!.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _event!.status == 'open' 
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _event!.status == 'open' ? '✓ Pendaftaran Dibuka' : '✕ Pendaftaran Ditutup',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: _event!.status == 'open' ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Counter
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_event!.registered}/${_event!.capacity}',
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getCategoryColor(),
                ),
              ),
              Text(
                'terdaftar',
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickInfoCard(
            icon: Icons.calendar_today,
            label: 'Tanggal',
            value: DateFormat('d Dec yyyy', 'id').format(_event!.date),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickInfoCard(
            icon: Icons.access_time,
            label: 'Waktu',
            value: _event!.time,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getCategoryColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _getCategoryColor(), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: _getCategoryColor(),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text('✨', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'Highlight Event',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lihat Semua',
                    style: AppTextStyles.caption.copyWith(
                      color: _getCategoryColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 12, color: _getCategoryColor()),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildHighlightCard(
                emoji: '🏆',
                title: 'Hadiah',
                subtitle: 'Menarik',
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHighlightCard(
                emoji: '👥',
                title: 'Peserta',
                subtitle: 'Max ${_event!.capacity} orang',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHighlightCard(
                emoji: '🎁',
                title: 'Benefit',
                subtitle: 'Pengalaman',
                color: Colors.pink,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHighlightCard({
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: [
        _buildActionCard(
          icon: Icons.folder_open_rounded,
          title: 'Dokumentasi',
          subtitle: 'Lihat dokumentasi\nevent',
          color: Colors.orange,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dokumentasi belum tersedia')),
            );
          },
        ),
        _buildActionCard(
          icon: Icons.card_membership_rounded,
          title: 'Sertifikat',
          subtitle: _event!.certificateEnabled ? 'Sertifikat\ntersedia' : 'Tidak ada\nsertifikat',
          color: Colors.purple,
          onTap: () => _showCertificateInfo(),
        ),
        _buildActionCard(
          icon: Icons.groups_rounded,
          title: 'Tanya Admin',
          subtitle: 'Hubungi admin\nevent',
          color: Colors.teal,
          onTap: () {
            ref.read(messageContextProvider.notifier).state = MessageContext(
              eventId: widget.eventId,
              eventTitle: _event!.title,
              initialMessage: 'Saya ingin bertanya tentang ${_event!.title}.',
            );
            context.go('/messages');
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Column(
      children: [
        _buildInfoTile(
          icon: Icons.shield_outlined,
          title: 'Aturan & Persyaratan',
          subtitle: 'Lihat peraturan dan ketentuan event',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur dalam pengembangan')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildInfoTile(
          icon: Icons.timeline_rounded,
          title: 'Timeline Event',
          subtitle: 'Lihat jadwal lengkap rangkaian event',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur dalam pengembangan')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getCategoryColor().withValues(alpha: 0.2),
                    _getCategoryColor().withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _getCategoryColor(), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  void _showCertificateInfo() {
    String certificateText = 'Event ini tidak menyediakan sertifikat.';
    
    if (_event!.certificateEnabled) {
      switch (_event!.certificateType) {
        case CertificateType.allParticipants:
          certificateText = 'Sertifikat diberikan kepada semua peserta yang mengikuti event ini.';
          break;
        case CertificateType.winners:
          certificateText = 'Sertifikat hanya diberikan kepada pemenang kompetisi.';
          break;
        case CertificateType.none:
          certificateText = 'Event ini tidak menyediakan sertifikat.';
          break;
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.card_membership_rounded, color: _getCategoryColor()),
            const SizedBox(width: 12),
            const Text('Informasi Sertifikat'),
          ],
        ),
        content: Text(certificateText, style: AppTextStyles.body2),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getCategoryColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.edit_rounded, color: _getCategoryColor(), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                text: _isRegistered ? 'Sudah Terdaftar' : 'Daftar Sekarang',
                onPressed: _isRegistered || _event!.status != 'open' 
                    ? null 
                    : _showRegistrationDialog,
                backgroundColor: _isRegistered ? AppColors.success : _getCategoryColor(),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.pink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.favorite_border, color: Colors.pink, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentationSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.folder_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dokumentasi Event',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _documentation!.title,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.border, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _documentation!.description,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final url = Uri.parse(_documentation!.googleDriveUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tidak dapat membuka link'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.open_in_new, size: 20),
                    label: const Text('Buka Google Drive'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
}
