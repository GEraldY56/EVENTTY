import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/models/event_model.dart';

class EventRulesScreen extends StatelessWidget {
  final EventModel event;

  const EventRulesScreen({
    super.key,
    required this.event,
  });

  List<String> _getRules() {
    // Return event-specific rules based on category
    switch (event.category.toLowerCase()) {
      case 'classmeet':
        return [
          'Setiap kelas wajib mengirimkan delegasi untuk semua kategori lomba',
          'Peserta harus hadir 30 menit sebelum lomba dimulai',
          'Tidak diperbolehkan mengganti peserta setelah pendaftaran ditutup',
          'Keputusan juri bersifat final dan tidak dapat diganggu gugat',
          'Peserta wajib mematuhi tata tertib yang berlaku',
          'Peserta yang melanggar aturan akan didiskualifikasi',
        ];
      case 'sports competition':
      case 'sports':
        return [
          'Peserta wajib membawa kelengkapan olahraga sendiri',
          'Technical meeting wajib dihadiri oleh ketua tim',
          'Peserta harus mengikuti aturan permainan yang berlaku',
          'Pertandingan menggunakan sistem gugur/kompetisi',
          'Keputusan wasit bersifat final',
          'Tidak diperbolehkan melakukan tindakan unsportsmanlike',
        ];
      case 'seminar':
        return [
          'Peserta wajib hadir tepat waktu',
          'Berpakaian rapi dan sopan',
          'Handphone dalam mode silent selama acara',
          'Dilarang keluar masuk ruangan saat sesi berlangsung',
          'Peserta diharapkan aktif bertanya dan berdiskusi',
          'Sertifikat hanya diberikan kepada peserta yang hadir penuh',
        ];
      case 'workshop':
        return [
          'Peserta wajib membawa laptop dan peralatan pribadi',
          'Hadir tepat waktu karena materi bersifat berkelanjutan',
          'Aktif mengikuti praktik dan hands-on session',
          'Bertanggung jawab atas peralatan yang digunakan',
          'Sertifikat diberikan setelah menyelesaikan mini project',
          'Dilarang mengganggu peserta lain selama workshop',
        ];
      case 'career development':
      case 'career day':
        return [
          'Peserta wajib berpakaian formal/business casual',
          'Membawa CV dan portofolio (jika ada)',
          'Bersikap profesional saat berinteraksi dengan pembicara',
          'Manfaatkan sesi networking sebaik mungkin',
          'Dilarang menggunakan handphone saat sesi berlangsung',
          'Peserta dapat bertanya langsung kepada narasumber',
        ];
      default:
        return [
          'Peserta wajib hadir tepat waktu',
          'Mengikuti seluruh rangkaian acara',
          'Mematuhi protokol kesehatan yang berlaku',
          'Bersikap sopan dan menghormati panitia',
          'Tidak diperbolehkan membawa barang berbahaya',
          'Keputusan panitia bersifat mutlak',
        ];
    }
  }

  List<String> _getRequirements() {
    // Return event-specific requirements
    switch (event.category.toLowerCase()) {
      case 'classmeet':
        return [
          'Siswa aktif SMKN 20 Jakarta',
          'Terdaftar sebagai anggota kelas yang didaftarkan',
          'Sehat jasmani dan rohani',
          'Tidak sedang menjalani sanksi disiplin',
        ];
      case 'sports competition':
      case 'sports':
        return [
          'Siswa aktif SMKN 20 Jakarta',
          'Sehat jasmani dan mampu berolahraga',
          'Membawa surat keterangan sehat (untuk final)',
          'Memiliki perlengkapan olahraga yang memadai',
        ];
      case 'seminar':
      case 'workshop':
        return [
          'Siswa aktif atau alumni SMKN 20 Jakarta',
          'Memiliki ketertarikan dengan topik yang dibahas',
          'Mampu mengikuti seluruh rangkaian acara',
          'Memiliki perangkat yang diperlukan (khusus workshop)',
        ];
      case 'career development':
      case 'career day':
        return [
          'Siswa kelas X, XI, atau XII',
          'Memiliki CV yang up-to-date',
          'Serius dalam mempersiapkan karir',
          'Berpenampilan profesional',
        ];
      default:
        return [
          'Siswa aktif SMKN 20 Jakarta',
          'Sehat jasmani dan rohani',
          'Memiliki minat pada event ini',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final rules = _getRules();
    final requirements = _getRequirements();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Aturan & Persyaratan',
          style: AppTextStyles.heading3,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Title
            Text(
              event.title,
              style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Harap baca dengan seksama sebelum mendaftar',
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            ),
            
            const SizedBox(height: 24),
            
            // Rules Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.rule, color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Aturan Event',
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...rules.asMap().entries.map((entry) {
                    final index = entry.key;
                    final rule = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              rule,
                              style: AppTextStyles.body1.copyWith(height: 1.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            
            if (requirements.isNotEmpty) ...[
              const SizedBox(height: 16),
              
              // Requirements Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.checklist, color: Colors.green, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Persyaratan',
                          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...requirements.map((req) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              req,
                              style: AppTextStyles.body1.copyWith(height: 1.6),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Warning Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber, color: Colors.amber[700], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Perhatian!',
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dengan mendaftar, Anda menyetujui untuk mematuhi semua aturan dan persyaratan yang telah ditetapkan. Pelanggaran dapat mengakibatkan diskualifikasi.',
                          style: AppTextStyles.body2.copyWith(
                            color: Colors.amber[900],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
