import 'package:flutter/material.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/services/certificate_service.dart';
import '../../../../../core/services/event_service.dart';
import '../../../../../core/models/certificate_model.dart';
import '../widgets/certificate_preview_widget.dart';

// PHASE 5: 4 sample certificates hardcoded REMOVED.
// 'Classmeet 2026' hardcoded title REMOVED.
// Data sekarang di-fetch dari Supabase via CertificateService.getEventCertificates().
// Event title diambil dari EventService.getEventById().
// UI layout dan preview dialog DIPERTAHANKAN.
// REQUIRES RUNTIME DATABASE VERIFICATION — Supabase not yet tested at runtime.

class CertificateListScreen extends StatefulWidget {
  final String eventId;

  const CertificateListScreen({super.key, required this.eventId});

  @override
  State<CertificateListScreen> createState() => _CertificateListScreenState();
}

class _CertificateListScreenState extends State<CertificateListScreen> {
  final CertificateService _certificateService = CertificateService();
  final EventService _eventService = EventService();

  String _searchQuery = '';
  List<CertificateModel> _certificates = [];
  String _eventTitle = '';
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // Fetch event title dan certificates secara paralel
      final results = await Future.wait([
        _eventService.getEventById(widget.eventId),
        _certificateService.getEventCertificates(widget.eventId),
      ]);

      final event = results[0];
      final certs = results[1] as List<CertificateModel>;

      setState(() {
        _eventTitle = (event != null)
            ? (event as dynamic).title as String
            : widget.eventId; // fallback ke eventId jika event tidak ditemukan
        _certificates = certs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<CertificateModel> get _filteredCerts {
    if (_searchQuery.isEmpty) return _certificates;
    final query = _searchQuery.toLowerCase();
    return _certificates.where((cert) {
      return cert.participantName.toLowerCase().contains(query) ||
          cert.participantNis.toLowerCase().contains(query) ||
          cert.certificateNumber.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Certificates', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
              tooltip: 'Refresh',
            ),
          if (!_isLoading && _certificates.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _handleDownloadAll,
              tooltip: 'Download All',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorState()
              : Column(
                  children: [
                    // Event Info Card — judul dari database
                    _buildEventInfoCard(),

                    // Search Bar — hanya tampil jika ada data
                    if (_certificates.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.horizontalPadding),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search by name, NIS, or cert number...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: AppColors.card,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusLG),
                              borderSide:
                                  BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusLG),
                              borderSide:
                                  BorderSide(color: AppColors.border),
                            ),
                          ),
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Certificates List
                    Expanded(
                      child: _certificates.isEmpty
                          ? _buildEmptyState()
                          : _filteredCerts.isEmpty
                              ? _buildNoSearchResultState()
                              : RefreshIndicator(
                                  onRefresh: _loadData,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          AppSpacing.horizontalPadding,
                                    ),
                                    itemCount: _filteredCerts.length,
                                    itemBuilder: (context, index) {
                                      return _buildCertificateCard(
                                          _filteredCerts[index]);
                                    },
                                  ),
                                ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEventInfoCard() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.horizontalPadding),
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Judul event nyata dari database, bukan hardcoded
                  _eventTitle.isNotEmpty ? _eventTitle : 'Loading...',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_certificates.length} certificates generated',
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
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
              'Gagal memuat sertifikat',
              style:
                  AppTextStyles.heading3.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: AppTextStyles.body2
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.workspace_premium_outlined,
              size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'Belum ada sertifikat',
            style: AppTextStyles.heading3
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate sertifikat terlebih dahulu\ndari halaman Certificate.',
            style: AppTextStyles.body2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResultState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'Tidak ditemukan',
            style: AppTextStyles.heading3
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba kata kunci lain.',
            style: AppTextStyles.body2,
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(CertificateModel cert) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingLG),
            child: Row(
              children: [
                // Avatar — inisial dari nama nyata
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary10,
                  child: Text(
                    cert.participantName.isNotEmpty
                        ? cert.participantName
                            .substring(0, 1)
                            .toUpperCase()
                        : '?',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cert.participantName,
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'NIS: ${cert.participantNis}',
                        style: AppTextStyles.body2,
                      ),
                    ],
                  ),
                ),

                // More Menu
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'preview',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 18),
                          SizedBox(width: 12),
                          Text('Preview'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(Icons.download, size: 18),
                          SizedBox(width: 12),
                          Text('Download'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share, size: 18),
                          SizedBox(width: 12),
                          Text('Share'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'preview') {
                      _showPreviewDialog(cert);
                    } else if (value == 'download') {
                      _handleDownload(cert);
                    } else if (value == 'share') {
                      _handleShare(cert);
                    }
                  },
                ),
              ],
            ),
          ),

          // Certificate Number + Issue Date — dari CertificateModel nyata
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.paddingLG,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppSpacing.radiusLG),
                bottomRight: Radius.circular(AppSpacing.radiusLG),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.tag, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  cert.certificateNumber,
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  cert.formattedIssuedDate,
                  style: AppTextStyles.body2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPreviewDialog(CertificateModel cert) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Certificate Preview',
                      style: AppTextStyles.heading3),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Preview menggunakan data nyata dari CertificateModel
              CertificatePreviewWidget(
                templateId: cert.templateId.isNotEmpty ? cert.templateId : '1',
                participantName: cert.participantName.toUpperCase(),
                eventTitle: cert.eventTitle.toUpperCase(),
                eventDate: cert.formattedEventDate,
                certificateNumber: cert.certificateNumber,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleDownload(cert);
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Download'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDownload(CertificateModel cert) {
    // REQUIRES RUNTIME IMPLEMENTATION: PDF generation & download
    // Saat ini menampilkan notifikasi; implementasi PDF diluar scope Phase 5.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Download: ${cert.certificateNumber} — ${cert.participantName}'),
      ),
    );
  }

  void _handleShare(CertificateModel cert) {
    // REQUIRES RUNTIME IMPLEMENTATION: share sheet / deep link
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Share: ${cert.certificateNumber} — ${cert.participantName}'),
      ),
    );
  }

  void _handleDownloadAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Download All Certificates',
            style: AppTextStyles.heading3),
        content: Text(
          'Download all ${_certificates.length} certificates as a ZIP file?',
          style: AppTextStyles.body1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // REQUIRES RUNTIME IMPLEMENTATION: ZIP generation & download
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Downloading ${_certificates.length} certificates...'),
                ),
              );
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }
}
