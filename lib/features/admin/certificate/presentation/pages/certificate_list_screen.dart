import 'package:flutter/material.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../widgets/certificate_preview_widget.dart';

class CertificateListScreen extends StatefulWidget {
  final String eventId;

  const CertificateListScreen({super.key, required this.eventId});

  @override
  State<CertificateListScreen> createState() => _CertificateListScreenState();
}

class _CertificateListScreenState extends State<CertificateListScreen> {
  String _searchQuery = '';
  
  // Sample certificates data
  final List<Map<String, dynamic>> _certificates = [
    {
      'id': 'cert_1',
      'participantName': 'Muhammad Faqih',
      'participantNis': '12345',
      'certificateNumber': 'CERT-2026-001',
      'issuedDate': '15 Agustus 2026',
      'downloaded': false,
    },
    {
      'id': 'cert_2',
      'participantName': 'Ahmad Zaki',
      'participantNis': '12346',
      'certificateNumber': 'CERT-2026-002',
      'issuedDate': '15 Agustus 2026',
      'downloaded': true,
    },
    {
      'id': 'cert_3',
      'participantName': 'Siti Nurhaliza',
      'participantNis': '12347',
      'certificateNumber': 'CERT-2026-003',
      'issuedDate': '15 Agustus 2026',
      'downloaded': false,
    },
    {
      'id': 'cert_4',
      'participantName': 'Budi Santoso',
      'participantNis': '12348',
      'certificateNumber': 'CERT-2026-004',
      'issuedDate': '15 Agustus 2026',
      'downloaded': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredCerts = _certificates.where((cert) {
      if (_searchQuery.isEmpty) return true;
      final name = (cert['participantName'] as String).toLowerCase();
      final nis = cert['participantNis'] as String;
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || nis.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Certificates', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _handleDownloadAll,
            tooltip: 'Download All',
          ),
        ],
      ),
      body: Column(
        children: [
          // Event Info Card
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                            'Classmeet 2026',
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
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or NIS...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          const SizedBox(height: 16),

          // Certificates List
          Expanded(
            child: filteredCerts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontalPadding,
                    ),
                    itemCount: filteredCerts.length,
                    itemBuilder: (context, index) {
                      final cert = filteredCerts[index];
                      return _buildCertificateCard(cert);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(Map<String, dynamic> cert) {
    final downloaded = cert['downloaded'] as bool;

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
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary10,
                  child: Text(
                    (cert['participantName'] as String).substring(0, 1).toUpperCase(),
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
                        cert['participantName'] as String,
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'NIS: ${cert['participantNis']}',
                            style: AppTextStyles.body2,
                          ),
                          const SizedBox(width: 12),
                          if (downloaded)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.download_done,
                                    size: 12,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Downloaded',
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

          // Certificate Number
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
                  cert['certificateNumber'] as String,
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  cert['issuedDate'] as String,
                  style: AppTextStyles.body2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No certificates found',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: AppTextStyles.body2,
          ),
        ],
      ),
    );
  }

  void _showPreviewDialog(Map<String, dynamic> cert) {
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
                  Text('Certificate Preview', style: AppTextStyles.heading3),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CertificatePreviewWidget(
                templateId: '1',
                participantName: (cert['participantName'] as String).toUpperCase(),
                eventTitle: 'CLASSMEET 2026',
                eventDate: '15 Agustus 2026',
                certificateNumber: cert['certificateNumber'] as String,
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

  void _handleDownload(Map<String, dynamic> cert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading certificate for ${cert['participantName']}...'),
      ),
    );
    
    // Mark as downloaded
    setState(() {
      cert['downloaded'] = true;
    });
  }

  void _handleShare(Map<String, dynamic> cert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing certificate for ${cert['participantName']}...'),
      ),
    );
  }

  void _handleDownloadAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Download All Certificates', style: AppTextStyles.heading3),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Downloading all certificates...'),
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
