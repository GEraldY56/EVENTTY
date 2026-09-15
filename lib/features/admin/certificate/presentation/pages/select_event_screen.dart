import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/routes/route_names.dart';
import '../../../../../core/services/event_service.dart';
import '../../../../../core/services/certificate_service.dart';
import '../../../../../core/models/event_model.dart';
import '../../../../../core/models/participant_model.dart';

// PHASE 4: Hardcoded event list REMOVED.
// Events now fetched from Supabase via EventService.
// Certificate generation now calls CertificateService (real DB operation).
// REQUIRES RUNTIME DATABASE VERIFICATION — Supabase not yet tested at runtime.

class SelectEventScreen extends StatefulWidget {
  final String templateId;

  const SelectEventScreen({super.key, required this.templateId});

  @override
  State<SelectEventScreen> createState() => _SelectEventScreenState();
}

class _SelectEventScreenState extends State<SelectEventScreen> {
  final EventService _eventService = EventService();
  final CertificateService _certificateService = CertificateService();

  String? _selectedEventId;
  List<EventModel> _events = [];
  Map<String, int> _certCounts = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Fetch only events with certificate enabled from Supabase
      final events = await _eventService.getAllEvents();
      final certEnabledEvents =
          events.where((e) => e.certificateEnabled).toList();

      // Also load certificate counts per event
      final counts = <String, int>{};
      for (final event in certEnabledEvents) {
        counts[event.id] =
            await _certificateService.getEventCertificateCount(event.id);
      }

      setState(() {
        _events = certEnabledEvents;
        _certCounts = counts;
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Select Event', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _events.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        // Info Card
                        _buildInfoCard(),

                        // Events List
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _loadEvents,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.horizontalPadding),
                              itemCount: _events.length,
                              itemBuilder: (context, index) {
                                final event = _events[index];
                                return _buildEventCard(event);
                              },
                            ),
                          ),
                        ),

                        // Bottom Action Button
                        if (_selectedEventId != null)
                          _buildGenerateButton(),
                      ],
                    ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.horizontalPadding),
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.info.withValues(alpha: 0.1),
            AppColors.info.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.info, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Select an event to generate certificates for eligible participants',
              style: AppTextStyles.body2.copyWith(color: AppColors.info),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat event',
              style:
                  AppTextStyles.heading3.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadEvents,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Event dengan Sertifikat',
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Event yang mengaktifkan fitur certificate akan muncul di sini',
              style: AppTextStyles.body1
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    final isSelected = _selectedEventId == event.id;
    final certCount = _certCounts[event.id] ?? 0;
    final hasGeneratedCerts = certCount > 0;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEventId = event.id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.paddingMD),
        padding: const EdgeInsets.all(AppSpacing.paddingLG),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary10 : AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Selection Radio
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                      width: 2,
                    ),
                    color: isSelected
                        ? AppColors.primary
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check,
                          size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),

                // Event Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            event.formattedDate,
                            style: AppTextStyles.body2,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Already Generated Badge
                if (hasGeneratedCerts)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 12,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Generated',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Participants Count & Category
            Row(
              children: [
                Icon(Icons.people,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  '${event.capacity} capacity',
                  style: AppTextStyles.body2,
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    event.category,
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (certCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$certCount sertifikat',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Warning if already generated
            if (hasGeneratedCerts) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sudah ada $certCount sertifikat untuk event ini. Generate ulang akan menambahkan sertifikat baru untuk peserta yang belum terdaftar.',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: _handleGenerateCertificates,
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Generate Certificates'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGenerateCertificates() async {
    if (_selectedEventId == null) return;

    final selectedEvent =
        _events.firstWhere((e) => e.id == _selectedEventId);

    // Confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Generate Certificates', style: AppTextStyles.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to generate certificates for:',
              style: AppTextStyles.body1,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedEvent.title,
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Peserta yang sudah hadir (status: attended) akan mendapatkan sertifikat.',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Proses ini akan mengakses database Supabase.',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating certificates...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Fetch attended participants from the participants table (real DB)
      final participantsResponse =
          await Supabase.instance.client
              .from('participants')
              .select()
              .eq('event_id', selectedEvent.id)
              .eq('status', 'attended');

      final participants = (participantsResponse as List)
          .map((json) => ParticipantModel.fromJson(json))
          .toList();

      if (!mounted) return;
      Navigator.pop(context); // close loading

      if (participants.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '⚠️ Tidak ada peserta yang sudah attended untuk event ini'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      // Call real CertificateService — actual DB insert
      final generated =
          await _certificateService.generateCertificatesForEvent(
        event: selectedEvent,
        participants: participants,
        templateId: widget.templateId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '✅ ${generated.length} sertifikat berhasil digenerate!'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );

      // Refresh cert counts then navigate back
      await _loadEvents();
      if (!mounted) return;
      context.go(RouteNames.adminCertificate);
    } catch (e) {
      if (!mounted) return;
      // Close loading dialog if still open
      try {
        Navigator.pop(context);
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
