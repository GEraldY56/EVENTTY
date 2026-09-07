import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/services/certificate_service.dart';
import '../../../../../core/models/event_model.dart';
import '../../../../../core/models/participant_model.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final CertificateService _certificateService = CertificateService();
  List<EventModel> _events = [];
  bool _isLoading = true;
  Map<String, int> _certificateCounts = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      // Load events with certificate enabled
      final response = await Supabase.instance.client
          .from('events')
          .select()
          .eq('certificate_enabled', true)
          .order('date', ascending: false);
      
      _events = (response as List)
          .map((json) => EventModel.fromJson(json))
          .toList();
      
      // Load certificate counts for each event
      for (final event in _events) {
        final count = await _certificateService.getEventCertificateCount(event.id);
        _certificateCounts[event.id] = count;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading events: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Certificates', style: AppTextStyles.heading3),
            Text(
              'Generate sertifikat untuk event',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? _buildEmptyState()
              : _buildEventsList(),
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
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: AppColors.info),
                      const SizedBox(width: 8),
                      Text(
                        'Cara Mengaktifkan Sertifikat:',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoStep('1', 'Buka halaman Events'),
                  _buildInfoStep('2', 'Edit event yang ingin diberi sertifikat'),
                  _buildInfoStep('3', 'Aktifkan toggle "Certificate Enabled"'),
                  _buildInfoStep('4', 'Pilih tipe sertifikat (Semua peserta / Pemenang)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.info,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: AppTextStyles.captionSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: AppTextStyles.body2.copyWith(color: AppColors.info),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          final certCount = _certificateCounts[event.id] ?? 0;
          return _buildEventCard(event, certCount);
        },
      ),
    );
  }

  Widget _buildEventCard(EventModel event, int certCount) {
    final bool hasGenerated = certCount > 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.paddingMD),
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(
          color: hasGenerated 
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Event Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: hasGenerated
                        ? [AppColors.success, AppColors.success.withValues(alpha: 0.7)]
                        : [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                ),
                child: Icon(
                  hasGenerated ? Icons.verified : Icons.workspace_premium,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTextStyles.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.formattedDate,
                      style: AppTextStyles.body2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Certificate Info
          Row(
            children: [
              _buildInfoChip(
                Icons.category,
                _getCertificateTypeLabel(event.certificateType),
                AppColors.info,
              ),
              const SizedBox(width: 8),
              if (hasGenerated)
                _buildInfoChip(
                  Icons.check_circle,
                  '$certCount sertifikat',
                  AppColors.success,
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Actions
          Row(
            children: [
              if (hasGenerated) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewGeneratedCertificates(event),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Lihat Sertifikat'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _generateCertificates(event),
                  icon: Icon(
                    hasGenerated ? Icons.refresh : Icons.auto_awesome,
                    size: 18,
                  ),
                  label: Text(hasGenerated ? 'Generate Ulang' : 'Generate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasGenerated ? AppColors.warning : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getCertificateTypeLabel(CertificateType type) {
    switch (type) {
      case CertificateType.allParticipants:
        return 'Semua Peserta';
      case CertificateType.winners:
        return 'Pemenang Saja';
      case CertificateType.none:
        return 'Tidak Aktif';
    }
  }

  Future<void> _generateCertificates(EventModel event) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Generate Sertifikat', style: AppTextStyles.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event: ${event.title}',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Generate sertifikat untuk peserta yang eligible?',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: AppColors.info),
                      const SizedBox(width: 8),
                      Text(
                        'Kriteria Eligible:',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '✓ Peserta sudah melakukan absensi (status = attended)',
                    style: AppTextStyles.caption.copyWith(color: AppColors.info),
                  ),
                  Text(
                    event.certificateType == CertificateType.winners
                        ? '✓ Peserta adalah pemenang (Juara 1/2/3)'
                        : '✓ Semua peserta yang hadir',
                    style: AppTextStyles.caption.copyWith(color: AppColors.info),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading dialog
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
      // Get participants from registrations table (attended status)
      final registrationsResponse = await Supabase.instance.client
          .from('registrations')
          .select()
          .eq('event_id', event.id)
          .eq('status', 'attended');
      
      // Convert to ParticipantModel format
      final participants = (registrationsResponse as List).map((json) {
        return ParticipantModel(
          id: json['id'] as String,
          eventId: json['event_id'] as String,
          studentId: json['student_id'] as String,
          studentName: json['student_name'] as String,
          studentNis: json['student_id'] as String, // Using student_id as NIS fallback
          studentClass: json['student_class'] as String? ?? '',
          email: json['student_email'] as String? ?? '',
          phone: json['student_phone'] as String? ?? '',
          registrationDate: DateTime.parse(json['registered_at'] as String),
          status: ParticipantStatus.attended,
          hasCertificate: false,
        );
      }).toList();
      
      if (participants.isEmpty) {
        if (!mounted) return;
        Navigator.pop(context); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Tidak ada peserta yang sudah attended untuk event ini'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
      
      // Generate certificates
      final generated = await _certificateService.generateCertificatesForEvent(
        event: event,
        participants: participants,
        templateId: 'default', // Using default template
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${generated.length} sertifikat berhasil digenerate!'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );

      _loadEvents(); // Refresh list
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _viewGeneratedCertificates(EventModel event) async {
    try {
      final certificates = await _certificateService.getEventCertificates(event.id);
      
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Sertifikat - ${event.title}', style: AppTextStyles.heading3),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: certificates.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Belum ada sertifikat yang digenerate.'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: certificates.length,
                    itemBuilder: (context, index) {
                      final cert = certificates[index];
                      return ListTile(
                        leading: const Icon(Icons.workspace_premium, color: AppColors.primary),
                        title: Text(cert.participantName),
                        subtitle: Text(cert.certificateNumber),
                        trailing: Text(
                          cert.achievement ?? 'Peserta',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading certificates: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
