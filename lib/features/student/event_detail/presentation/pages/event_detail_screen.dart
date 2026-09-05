import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/services/registration_service.dart';
import '../../../../../core/services/event_service.dart';
import '../../../../../core/services/bookmark_service.dart';
import '../../../../../core/models/event_model.dart';
import '../../../../../core/providers/message_context_provider.dart';
import '../../../../../main.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../widgets/registration_dialog_simple.dart';
import 'event_rules_screen.dart';
import 'event_timeline_screen.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  final RegistrationService _registrationService = RegistrationService();
  final EventService _eventService = EventService();
  final BookmarkService _bookmarkService = BookmarkService();
  
  bool _isRegistered = false;
  bool _isBookmarked = false;
  EventModel? _event;
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

  final isRegistered =
      await _registrationService.isUserRegistered(
    userId,
    widget.eventId,
  );

  if (mounted) {
    setState(() {
      _isRegistered = isRegistered;
    });
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

  Future<void> _shareEvent() async {
    if (_event == null) return;
    
    final shareText = '''
🎉 ${_event!.title}

${_event!.description.substring(0, _event!.description.length > 100 ? 100 : _event!.description.length)}...

📅 ${DateFormat('d MMMM yyyy').format(_event!.date)}
⏰ ${_event!.time}
📍 ${_event!.location}

Daftar sekarang di aplikasi Eventty!
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

  void _askAdmin() {
    if (_event == null) return;
    
    // Set message context - will be consumed by Messages screen in postFrameCallback
    ref.read(messageContextProvider.notifier).state = MessageContext(
      eventId: widget.eventId,
      eventTitle: _event!.title,
      initialMessage: 'Saya ingin bertanya tentang ${_event!.title}.',
    );
    
    // Navigate ke messages
    context.go('/messages');
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
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_event == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
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
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Hero Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: _getCategoryColor(),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
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
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                  ),
                  onPressed: _shareEvent,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: _toggleBookmark,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (_event!.imageUrl != null && _event!.imageUrl!.isNotEmpty)
                    Image.asset(
                      _event!.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: _getCategoryColor(),
                      ),
                    )
                  else
                    Container(color: _getCategoryColor()),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black26, Colors.black54],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _event!.category,
                            style: AppTextStyles.captionSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _event!.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Event Info Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_event!.title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _event!.status == 'open' ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 14,
                                      color: _event!.status == 'open' ? AppColors.success : AppColors.error,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _event!.status == 'open' ? 'Pendaftaran Dibuka' : 'Pendaftaran Ditutup',
                                      style: AppTextStyles.captionSmall.copyWith(
                                        color: _event!.status == 'open' ? AppColors.success : AppColors.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${_event!.registered} / ${_event!.capacity}',
                              style: AppTextStyles.heading2.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _getCategoryColor(),
                              ),
                            ),
                            Text('terdaftar', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quick Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          Icons.calendar_today,
                          'Tanggal',
                          DateFormat('d MMM yyyy').format(_event!.date),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoCard(Icons.access_time, 'Waktu', _event!.time),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(Icons.location_on, 'Lokasi', _event!.location),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoCard(Icons.groups, 'Organizer', _event!.organizer),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text('Tentang Event', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(_event!.description, style: AppTextStyles.body1.copyWith(height: 1.6)),

                  const SizedBox(height: 24),

                  // Highlight Event Section
                  Text('✨ Highlight Event', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildHighlightCard(
                          icon: '🏆',
                          title: 'Hadiah',
                          subtitle: 'Menarik',
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildHighlightCard(
                          icon: '👥',
                          title: 'Peserta',
                          subtitle: 'Max ${_event!.capacity} orang',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildHighlightCard(
                          icon: '🎁',
                          title: 'Benefit',
                          subtitle: 'Pengalaman',
                          color: Colors.pink,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Interactive Buttons Section
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.folder_open_rounded,
                          title: 'Dokumentasi',
                          subtitle: 'Lihat dokumentasi\nevent sebelumnya.',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Dokumentasi belum tersedia')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.card_membership_rounded,
                          title: 'Sertifikat',
                          subtitle: _getCertificateText(),
                          onTap: () {
                            _showCertificateInfo();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Tanya Admin',
                          subtitle: 'Punya pertanyaan?\nHubungi admin event ini.',
                          onTap: _askAdmin,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Rules and Timeline
                  _buildListTile(
                    icon: Icons.shield_outlined,
                    title: 'Aturan & Persyaratan',
                    subtitle: 'Lihat peraturan dan ketentuan event',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventRulesScreen(event: _event!),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildListTile(
                    icon: Icons.timeline_rounded,
                    title: 'Timeline Event',
                    subtitle: 'Lihat jadwal lengkap rangkaian event',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventTimelineScreen(event: _event!),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 8,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: SafeArea(
          child: AppButton(
            text: _isRegistered ? 'Sudah Terdaftar' : 'Daftar Sekarang',
            onPressed: _isRegistered || _event!.status != 'open' ? null : _showRegistrationDialog,
            backgroundColor: _isRegistered ? AppColors.success : null,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: _getCategoryColor(), size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard({
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.captionSmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCategoryColor().withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _getCategoryColor(), size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
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
            Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getCategoryColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
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
                    style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
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

  String _getCertificateText() {
    if (_event!.certificateEnabled) {
      switch (_event!.certificateType) {
        case CertificateType.allParticipants:
          return 'Sertifikat diberikan\nkepada semua peserta.';
        case CertificateType.winners:
          return 'Sertifikat diberikan\nkepada pemenang.';
        case CertificateType.none:
          return 'Event ini tidak\nmenyediakan sertifikat.';
      }
    }
    return 'Event ini tidak\nmenyediakan sertifikat.';
  }

  void _showCertificateInfo() {
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getCertificateText().replaceAll('\n', ' '),
              style: AppTextStyles.body1,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sertifikat akan muncul di menu Certificate setelah event selesai.',
                      style: AppTextStyles.captionSmall.copyWith(color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
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
}
