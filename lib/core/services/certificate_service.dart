import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main.dart';
import '../models/certificate_model.dart';
import '../models/event_model.dart';
import '../models/participant_model.dart';
import '../utils/logger.dart';

/// Certificate Service untuk mengelola logika sertifikat
/// Menangani eligibility checking berdasarkan tipe sertifikat event
/// dan menyimpan data sertifikat ke Supabase.
class CertificateService {
  final SupabaseClient _supabase = supabase;

  /// Cek apakah participant eligible untuk mendapatkan sertifikat
  /// Berdasarkan konfigurasi certificate event.
  bool isParticipantEligibleForCertificate({
    required EventModel event,
    required ParticipantModel participant,
  }) {
    // Jika event tidak mengaktifkan sertifikat, tidak eligible.
    if (!event.certificateEnabled) {
      return false;
    }

    // Participant harus sudah hadir.
    if (!participant.isAttended) {
      return false;
    }

    // Cek berdasarkan certificate type.
    switch (event.certificateType) {
      case CertificateType.none:
        return false;

      case CertificateType.allParticipants:
        return true;

      case CertificateType.winners:
        return participant.isWinner;
    }
  }

  /// Generate sertifikat untuk participant yang eligible.
  Future<CertificateModel?> generateCertificate({
    required EventModel event,
    required ParticipantModel participant,
    required String templateId,
  }) async {
    if (!isParticipantEligibleForCertificate(
      event: event,
      participant: participant,
    )) {
      return null;
    }

    // Cek apakah participant sudah menerima sertifikat untuk event ini.
    final alreadyReceived = await hasParticipantReceivedCertificate(
      studentId: participant.studentId,
      eventId: event.id,
    );

    if (alreadyReceived) {
      return await getStudentCertificateForEvent(
        studentId: participant.studentId,
        eventId: event.id,
      );
    }

    final certNumber = await _generateCertificateNumber();

    final certificateType = _getCertificateType(event, participant);
    final winnerPosition = _getWinnerPosition(event, participant);

    try {
      final response = await _supabase
          .from('certificates')
          .insert({
            'event_id': event.id,
            'event_title': event.title,
            'student_id': participant.studentId,
            'student_name': participant.studentName,
            'certificate_type': certificateType,
            'certificate_number': certNumber,
            'winner_position': winnerPosition,
          })
          .select()
          .single();

      return _certificateFromSupabase(
        response,
        event: event,
        participant: participant,
        templateId: templateId,
      );
    } catch (e) {
      AppLogger.error('Error generating certificate', e);
      return null;
    }
  }

  /// Generate sertifikat untuk semua participant yang eligible dalam event.
  Future<List<CertificateModel>> generateCertificatesForEvent({
    required EventModel event,
    required List<ParticipantModel> participants,
    required String templateId,
  }) async {
    final generatedCerts = <CertificateModel>[];

    for (final participant in participants) {
      final cert = await generateCertificate(
        event: event,
        participant: participant,
        templateId: templateId,
      );

      if (cert != null) {
        generatedCerts.add(cert);
      }
    }

    return generatedCerts;
  }

  /// Get certificates untuk student tertentu.
  Future<List<CertificateModel>> getStudentCertificates(
    String studentId,
  ) async {
    try {
      final response = await _supabase
          .from('certificates')
          .select()
          .eq('student_id', studentId)
          .order('issue_date', ascending: false);

      return (response as List)
          .map(
            (json) => _certificateFromSupabase(
              json,
            ),
          )
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching student certificates', e);
      return [];
    }
  }

  /// Get certificates untuk event tertentu.
  Future<List<CertificateModel>> getEventCertificates(
    String eventId,
  ) async {
    try {
      final response = await _supabase
          .from('certificates')
          .select()
          .eq('event_id', eventId)
          .order('issue_date', ascending: false);

      return (response as List)
          .map(
            (json) => _certificateFromSupabase(
              json,
            ),
          )
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching event certificates', e);
      return [];
    }
  }

  /// Get certificate by ID.
  Future<CertificateModel?> getCertificateById(
    String certificateId,
  ) async {
    try {
      final response = await _supabase
          .from('certificates')
          .select()
          .eq('id', certificateId)
          .single();

      return _certificateFromSupabase(response);
    } catch (e) {
      AppLogger.error('Error fetching certificate', e);
      return null;
    }
  }

  /// Cek apakah participant sudah memiliki sertifikat untuk event tertentu.
  Future<bool> hasParticipantReceivedCertificate({
    required String studentId,
    required String eventId,
  }) async {
    try {
      final response = await _supabase
          .from('certificates')
          .select('id')
          .eq('student_id', studentId)
          .eq('event_id', eventId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      AppLogger.error('Error checking certificate existence', e);
      return false;
    }
  }

  /// Get certificate participant berdasarkan student + event.
  Future<CertificateModel?> getStudentCertificateForEvent({
    required String studentId,
    required String eventId,
  }) async {
    try {
      final response = await _supabase
          .from('certificates')
          .select()
          .eq('student_id', studentId)
          .eq('event_id', eventId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return _certificateFromSupabase(response);
    } catch (e) {
      AppLogger.error('Error fetching student certificate for event', e);
      return null;
    }
  }

  /// Get total sertifikat yang sudah digenerate untuk event.
  Future<int> getEventCertificateCount(String eventId) async {
    try {
      final response = await _supabase
          .from('certificates')
          .select('id')
          .eq('event_id', eventId);

      return (response as List).length;
    } catch (e) {
      AppLogger.error('Error counting event certificates', e);
      return 0;
    }
  }

  /// Generate certificate number berdasarkan jumlah certificate saat ini.
  Future<String> _generateCertificateNumber() async {
    try {
      final response = await _supabase
          .from('certificates')
          .select('id');

      final number = ((response as List).length + 1)
          .toString()
          .padLeft(4, '0');

      return 'CERT-${DateTime.now().year}-$number';
    } catch (e) {
      // Fallback supaya proses generate tetap aman.
      final fallback =
          DateTime.now().millisecondsSinceEpoch.toString().substring(7);
      return 'CERT-${DateTime.now().year}-$fallback';
    }
  }

  /// Tentukan certificate type sesuai konfigurasi event.
  String _getCertificateType(
    EventModel event,
    ParticipantModel participant,
  ) {
    if (event.certificateType == CertificateType.winners &&
        participant.isWinner) {
      return 'winner';
    }

    return 'participation';
  }

  /// Tentukan posisi pemenang jika ada.
  String? _getWinnerPosition(
    EventModel event,
    ParticipantModel participant,
  ) {
    if (event.certificateType != CertificateType.winners ||
        !participant.isWinner) {
      return null;
    }

    switch (participant.placement) {
      case ParticipantPlacement.first:
        return 'Juara 1';
      case ParticipantPlacement.second:
        return 'Juara 2';
      case ParticipantPlacement.third:
        return 'Juara 3';
      default:
        return null;
    }
  }

  /// Ubah row Supabase menjadi CertificateModel.
  ///
  /// Karena tabel Supabase tidak memiliki semua field yang ada di
  /// CertificateModel lama, field yang tidak tersedia diberi fallback.
  CertificateModel _certificateFromSupabase(
    Map<String, dynamic> json, {
    EventModel? event,
    ParticipantModel? participant,
    String? templateId,
  }) {
    final eventId = json['event_id'] as String? ?? event?.id ?? '';
    final eventTitle =
        json['event_title'] as String? ?? event?.title ?? 'Event';

    final studentId =
        json['student_id'] as String? ?? participant?.studentId ?? '';

    final studentName =
        json['student_name'] as String? ?? participant?.studentName ?? '';

    final certificateType =
        json['certificate_type'] as String? ?? 'participation';

    final winnerPosition = json['winner_position'] as String?;

    final achievement = winnerPosition ?? 'Peserta';

    return CertificateModel(
      id: json['id'] as String,
      eventId: eventId,
      eventTitle: eventTitle,
      eventCategory: event?.category ?? 'Event',
      participantId: studentId,
      participantName: studentName,
      participantNis: participant?.studentNis ?? studentId,
      templateId: templateId ?? '',
      eventDate: event?.date,
      issuedDate: _parseDate(json['issue_date']) ?? DateTime.now(),
      certificateNumber: json['certificate_number'] as String? ?? '',
      signedBy: 'OSIS SMKN 20 Jakarta',
      additionalInfo: null,
      achievement: certificateType == 'winner'
          ? achievement
          : 'Peserta',
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}