import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/registration_model.dart';
import '../utils/logger.dart';
import 'notification_service.dart';

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
      // Validate authentication
      if (userId.isEmpty) {
        return RegistrationResult(
          success: false,
          message: 'Silakan login terlebih dahulu',
        );
      }

      // Get event details for validation
      final eventResponse = await _supabase
          .from('events')
          .select()
          .eq('id', eventId)
          .maybeSingle();

      if (eventResponse == null) {
        return RegistrationResult(
          success: false,
          message: 'Event tidak ditemukan',
        );
      }

      final event = eventResponse;

      // Validate event is published
      if (event['is_published'] != true) {
        return RegistrationResult(
          success: false,
          message: 'Event belum dipublikasikan',
        );
      }

      // Validate registration is open
      if (event['is_registration_open'] != true) {
        return RegistrationResult(
          success: false,
          message: 'Pendaftaran event sudah ditutup',
        );
      }

      // Validate event status
      if (event['status'] == 'closed') {
        return RegistrationResult(
          success: false,
          message: 'Event sudah ditutup',
        );
      }

      // Validate registration deadline
      if (event['registration_deadline'] != null) {
        final deadline = DateTime.parse(event['registration_deadline'] as String);
        if (DateTime.now().isAfter(deadline)) {
          return RegistrationResult(
            success: false,
            message: 'Batas waktu pendaftaran sudah berakhir',
          );
        }
      }

      // Validate capacity
      final capacity = event['capacity'] as int;
      final registered = event['registered'] as int;
      if (registered >= capacity) {
        return RegistrationResult(
          success: false,
          message: 'Kuota event sudah penuh',
        );
      }

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

      // Buat registration - let database generate UUID
      final registrationData = {
        'event_id': eventId,
        'type': RegistrationType.individual.name,
        'user_id': userId,
        'user_name': userName,
        'form_data': formData,
        'registration_date': DateTime.now().toIso8601String(),
        'status': RegistrationStatus.pending.name,
      };

      final insertedResponse = await _supabase
          .from('registrations')
          .insert(registrationData)
          .select()
          .single();

      await _notifyUpdateFromDatabase();

      return RegistrationResult(
        success: true,
        message: 'Pendaftaran berhasil! Menunggu konfirmasi admin.',
        registrationId: insertedResponse['id'] as String,
      );
    } catch (e) {
      AppLogger.error('Error registering individual', e);

      // Provide more specific error messages
      final errorMessage = e.toString();
      if (errorMessage.contains('duplicate key') || errorMessage.contains('unique constraint')) {
        return RegistrationResult(
          success: false,
          message: 'Anda sudah terdaftar di event ini',
        );
      } else if (errorMessage.contains('permission') || errorMessage.contains('policy')) {
        return RegistrationResult(
          success: false,
          message: 'Akses ditolak. Pastikan Anda sudah login',
        );
      } else {
        return RegistrationResult(
          success: false,
          message: 'Terjadi kesalahan saat mendaftar. Silakan coba lagi.',
        );
      }
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
      // Validate authentication
      if (leaderId.isEmpty) {
        return RegistrationResult(
          success: false,
          message: 'Silakan login terlebih dahulu',
        );
      }

      // Get event details for validation
      final eventResponse = await _supabase
          .from('events')
          .select()
          .eq('id', eventId)
          .maybeSingle();

      if (eventResponse == null) {
        return RegistrationResult(
          success: false,
          message: 'Event tidak ditemukan',
        );
      }

      final event = eventResponse;

      // Validate event is published
      if (event['is_published'] != true) {
        return RegistrationResult(
          success: false,
          message: 'Event belum dipublikasikan',
        );
      }

      // Validate registration is open
      if (event['is_registration_open'] != true) {
        return RegistrationResult(
          success: false,
          message: 'Pendaftaran event sudah ditutup',
        );
      }

      // Validate event status
      if (event['status'] == 'closed') {
        return RegistrationResult(
          success: false,
          message: 'Event sudah ditutup',
        );
      }

      // Validate registration type matches
      if (event['registration_type'] != 'team') {
        return RegistrationResult(
          success: false,
          message: 'Event ini hanya menerima pendaftaran individual',
        );
      }

      // Validate registration deadline
      if (event['registration_deadline'] != null) {
        final deadline = DateTime.parse(event['registration_deadline'] as String);
        if (DateTime.now().isAfter(deadline)) {
          return RegistrationResult(
            success: false,
            message: 'Batas waktu pendaftaran sudah berakhir',
          );
        }
      }

      // Validate capacity
      final capacity = event['capacity'] as int;
      final registered = event['registered'] as int;
      if (registered >= capacity) {
        return RegistrationResult(
          success: false,
          message: 'Kuota event sudah penuh',
        );
      }

      // Ambil semua registration event ini
      final response = await _supabase
          .from('registrations')
          .select()
          .eq('event_id', eventId);

      final registrations = (response as List)
          .map((json) => RegistrationModel.fromJson(json))
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

      // Buat registration team - let database generate UUID
      final registrationData = {
        'event_id': eventId,
        'type': RegistrationType.team.name,
        'team_name': teamName,
        'class_name': className,
        'leader_id': leaderId,
        'leader_name': leaderName,
        'members': members.map((m) => m.toJson()).toList(),
        'form_data': formData,
        'registration_date': DateTime.now().toIso8601String(),
        'status': RegistrationStatus.pending.name,
      };

      final insertedResponse = await _supabase
          .from('registrations')
          .insert(registrationData)
          .select()
          .single();

      await _notifyUpdateFromDatabase();

      return RegistrationResult(
        success: true,
        message: 'Pendaftaran team berhasil! Menunggu konfirmasi admin.',
        registrationId: insertedResponse['id'] as String,
      );
    } catch (e) {
      AppLogger.error('Error registering team', e);

      // Provide more specific error messages
      final errorMessage = e.toString();
      if (errorMessage.contains('duplicate key') || errorMessage.contains('unique constraint')) {
        return RegistrationResult(
          success: false,
          message: 'Team ini sudah terdaftar di event ini',
        );
      } else if (errorMessage.contains('permission') || errorMessage.contains('policy')) {
        return RegistrationResult(
          success: false,
          message: 'Akses ditolak. Pastikan Anda sudah login',
        );
      } else {
        return RegistrationResult(
          success: false,
          message: 'Terjadi kesalahan saat mendaftar. Silakan coba lagi.',
        );
      }
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
      // Get registration details before updating (for notification)
      final registrationData = await _supabase
          .from('registrations')
          .select('*, events!inner(id, title)')
          .eq('id', registrationId)
          .single();

      // Update status
      await _supabase
          .from('registrations')
          .update({
            'status': status.name,
          })
          .eq('id', registrationId);

      await _notifyUpdateFromDatabase();

      // Send notification if approved or rejected
      if (status == RegistrationStatus.confirmed || status == RegistrationStatus.cancelled) {
        _sendRegistrationStatusNotification(
          registrationData: registrationData,
          newStatus: status,
        );
      }

      return true;
    } catch (e) {
      AppLogger.error('Error updating registration status', e);
      return false;
    }
  }

  /// Send notification when registration status changes (fire-and-forget)
  void _sendRegistrationStatusNotification({
    required Map<String, dynamic> registrationData,
    required RegistrationStatus newStatus,
  }) {
    // Fire-and-forget: don't await, don't block main operation
    Future(() async {
      try {
        final notificationService = NotificationService();
        final userId = registrationData['user_id'] as String?;
        final eventData = registrationData['events'] as Map<String, dynamic>?;
        
        if (userId == null || eventData == null) return;
        
        final eventId = eventData['id'] as String;
        final eventTitle = eventData['title'] as String;

        if (newStatus == RegistrationStatus.confirmed) {
          await notificationService.notifyRegistrationApproved(
            userId: userId,
            eventId: eventId,
            eventTitle: eventTitle,
          );
        } else if (newStatus == RegistrationStatus.cancelled) {
          await notificationService.notifyRegistrationRejected(
            userId: userId,
            eventId: eventId,
            eventTitle: eventTitle,
          );
        }
      } catch (e) {
        // Silent fail - don't break registration update
        AppLogger.error('Failed to send registration notification', e);
      }
    });
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