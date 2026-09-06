import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/registration_model.dart';
import '../utils/logger.dart';

/// Registration Service - Handle event registrations (INDIVIDUAL & TEAM)
class RegistrationService {
  // Singleton pattern
  static final RegistrationService _instance = RegistrationService._internal();

  factory RegistrationService() => _instance;

  RegistrationService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Stream controller for registration updates
  final _registrationsController =
      StreamController<List<RegistrationModel>>.broadcast();

  // ============================================================
  // REGISTER INDIVIDUAL
  // ============================================================

  Future<RegistrationResult> registerIndividual({
    required String eventId,
    required String userId,
    required String userName,
    required Map<String, dynamic> formData,
  }) async {
    try {
      // Check apakah user sudah terdaftar
      final existingResponse = await _supabase
          .from('registrations')
          .select()
          .eq('event_id', eventId);

      final existingRegistrations = (existingResponse as List)
          .map((json) => RegistrationModel.fromJson(json))
          .toList();

      final alreadyRegistered = existingRegistrations.any(
        (registration) => registration.includesStudent(userId),
      );

      if (alreadyRegistered) {
        final existing = existingRegistrations.firstWhere(
          (registration) => registration.includesStudent(userId),
        );

        return RegistrationResult(
          success: false,
          message: existing.isTeam
              ? 'Anda sudah terdaftar sebagai anggota team untuk event ini'
              : 'Anda sudah terdaftar di event ini',
        );
      }

      // Buat registration
      final registration = RegistrationModel(
        id: 'reg_${DateTime.now().millisecondsSinceEpoch}',
        eventId: eventId,
        type: RegistrationType.individual,
        userId: userId,
        userName: userName,
        formData: formData,
        registrationDate: DateTime.now(),
        status: RegistrationStatus.pending,
      );

      await _supabase.from('registrations').insert(
        registration.toJson(),
      );

      await _notifyUpdateFromDatabase();

      return RegistrationResult(
        success: true,
        message: 'Pendaftaran berhasil! Menunggu konfirmasi admin.',
        registrationId: registration.id,
      );
    } catch (e) {
      AppLogger.error('Error registering individual', e);

      return RegistrationResult(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // REGISTER TEAM
  // ============================================================

  Future<RegistrationResult> registerTeam({
    required String eventId,
    required String teamName,
    required String className,
    required String leaderId,
    required String leaderName,
    required List<TeamMember> members,
    required Map<String, dynamic> formData,
  }) async {
    try {
      // Ambil semua registration event ini
      final response = await _supabase
          .from('registrations')
          .select();

      final registrations = (response as List)
          .map((json) => RegistrationModel.fromJson(json))
          .where((registration) => registration.eventId == eventId)
          .toList();

      // Check apakah team/class sudah terdaftar
      final existingTeam = registrations.where(
        (registration) =>
            registration.isTeam &&
            (registration.className == className ||
                registration.teamName == teamName),
      );

      if (existingTeam.isNotEmpty) {
        return RegistrationResult(
          success: false,
          message: 'Team/kelas $className sudah terdaftar untuk event ini',
        );
      }

      // Check apakah member sudah ada di team lain
      for (final member in members) {
        final memberAlreadyInTeam = registrations.any(
          (registration) =>
              registration.isTeam &&
              registration.includesStudent(member.studentId),
        );

        if (memberAlreadyInTeam) {
          return RegistrationResult(
            success: false,
            message:
                '${member.name} sudah terdaftar di team lain untuk event ini',
          );
        }
      }

      // Buat registration team
      final registration = RegistrationModel(
        id: 'reg_${DateTime.now().millisecondsSinceEpoch}',
        eventId: eventId,
        type: RegistrationType.team,
        teamName: teamName,
        className: className,
        leaderId: leaderId,
        leaderName: leaderName,
        members: members,
        formData: formData,
        registrationDate: DateTime.now(),
        status: RegistrationStatus.pending,
      );

      await _supabase.from('registrations').insert(
        registration.toJson(),
      );

      await _notifyUpdateFromDatabase();

      return RegistrationResult(
        success: true,
        message: 'Pendaftaran team berhasil! Menunggu konfirmasi admin.',
        registrationId: registration.id,
      );
    } catch (e) {
      AppLogger.error('Error registering team', e);

      return RegistrationResult(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // GET USER REGISTRATIONS
  // ============================================================

  Future<List<RegistrationModel>> getUserRegistrations(
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from('registrations')
          .select()
          .order('registration_date', ascending: false);

      final registrations = (response as List)
          .map((json) => RegistrationModel.fromJson(json))
          .toList();

      return registrations
          .where((registration) => registration.includesStudent(userId))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching user registrations', e);
      return [];
    }
  }

  // ============================================================
  // GET EVENT REGISTRATIONS
  // ============================================================

  Future<List<RegistrationModel>> getEventRegistrations(
    String eventId,
  ) async {
    try {
      final response = await _supabase
          .from('registrations')
          .select()
          .eq('event_id', eventId)
          .order('registration_date', ascending: false);

      return (response as List)
          .map((json) => RegistrationModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching event registrations', e);
      return [];
    }
  }

  // ============================================================
  // REGISTRATION STREAM
  // ============================================================

  Stream<List<RegistrationModel>> get registrationsStream =>
      _registrationsController.stream;

  // ============================================================
  // CHECK USER REGISTERED
  // ============================================================

  Future<bool> isUserRegistered(
    String userId,
    String eventId,
  ) async {
    final registrations = await getEventRegistrations(eventId);

    return registrations.any(
      (registration) => registration.includesStudent(userId),
    );
  }

  // ============================================================
  // GET USER REGISTRATION FOR EVENT
  // ============================================================

  Future<RegistrationModel?> getUserRegistrationForEvent(
    String userId,
    String eventId,
  ) async {
    try {
      final registrations = await getEventRegistrations(eventId);

      for (final registration in registrations) {
        if (registration.includesStudent(userId)) {
          return registration;
        }
      }

      return null;
    } catch (e) {
      AppLogger.error('Error getting user registration', e);
      return null;
    }
  }

  // ============================================================
  // CANCEL REGISTRATION
  // ============================================================

  Future<bool> cancelRegistration(
    String registrationId,
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from('registrations')
          .select()
          .eq('id', registrationId)
          .maybeSingle();

      if (response == null) {
        return false;
      }

      final registration = RegistrationModel.fromJson(response);

      // Team hanya leader yang boleh cancel
      if (registration.isTeam &&
          registration.leaderId != userId) {
        return false;
      }

      // Individual hanya pemilik yang boleh cancel
      if (!registration.isTeam &&
          registration.userId != userId) {
        return false;
      }

      await _supabase
          .from('registrations')
          .delete()
          .eq('id', registrationId);

      await _notifyUpdateFromDatabase();

      return true;
    } catch (e) {
      AppLogger.error('Error cancelling registration', e);
      return false;
    }
  }

  // ============================================================
  // UPDATE REGISTRATION STATUS
  // ============================================================

  Future<bool> updateRegistrationStatus({
    required String registrationId,
    required RegistrationStatus status,
  }) async {
    try {
      await _supabase
          .from('registrations')
          .update({
            'status': status.name,
          })
          .eq('id', registrationId);

      await _notifyUpdateFromDatabase();

      return true;
    } catch (e) {
      AppLogger.error('Error updating registration status', e);
      return false;
    }
  }

  // ============================================================
  // GET ALL REGISTRATIONS
  // ============================================================

  Future<List<RegistrationModel>> getAllRegistrations() async {
    try {
      final response = await _supabase
          .from('registrations')
          .select()
          .order('registration_date', ascending: false);

      return (response as List)
          .map((json) => RegistrationModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching all registrations', e);
      return [];
    }
  }

  // ============================================================
  // GET EVENT REGISTRATION COUNT
  // ============================================================

  Future<int> getEventRegistrationCount(
    String eventId,
  ) async {
    try {
      final response = await _supabase
          .from('registrations')
          .select()
          .eq('event_id', eventId);

      return (response as List).length;
    } catch (e) {
      AppLogger.error('Error getting registration count', e);
      return 0;
    }
  }

  // ============================================================
  // GET EVENT PARTICIPANT COUNT
  // ============================================================

  Future<int> getEventParticipantCount(
    String eventId,
  ) async {
    try {
      final registrations = await getEventRegistrations(eventId);

      int total = 0;

      for (final registration in registrations) {
        total += registration.memberCount;
      }

      return total;
    } catch (e) {
      AppLogger.error('Error getting participant count', e);
      return 0;
    }
  }

  // ============================================================
  // REFRESH STREAM
  // ============================================================

  Future<void> _notifyUpdateFromDatabase() async {
    try {
      final registrations = await getAllRegistrations();

      if (!_registrationsController.isClosed) {
        _registrationsController.add(registrations);
      }
    } catch (e) {
      AppLogger.error('Error updating registration stream', e);
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  void dispose() {
    _registrationsController.close();
  }
}

// ================================================================
// BACKWARD COMPATIBILITY CLASS
// ================================================================

/// Event Registration Model (DEPRECATED - Use RegistrationModel)
class EventRegistration {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final Map<String, dynamic> formData;
  final DateTime registrationDate;
  RegistrationStatus status;

  EventRegistration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.formData,
    required this.registrationDate,
    this.status = RegistrationStatus.pending,
  });

  String get fullName => formData['fullName'] ?? userName;
  String get nis => formData['nis'] ?? '';
  String get kelas => formData['kelas'] ?? '';
  String get phone => formData['phone'] ?? '';
  String get email => formData['email'] ?? '';
  String get reason => formData['reason'] ?? '';
}