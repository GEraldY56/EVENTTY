import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../utils/logger.dart';

/// Supabase Auth Service - Wrapper for Supabase Auth with ProfileModel integration
class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  String? get userId => currentUser?.id;

  bool get isLoggedIn => currentUser != null;

  /// Get user role from profiles table
  Future<String?> getUserRole() async {
    if (userId == null) return null;

    try {
      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', userId!)
          .single();

      return response['role'] as String?;
    } catch (e) {
      AppLogger.error('Error getting user role', e);
      return null;
    }
  }

  /// Get user profile as ProfileModel
  Future<ProfileModel?> getUserProfile() async {
    if (userId == null) return null;

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId!)
          .single();

      return ProfileModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error getting profile', e);
      return null;
    }
  }

  /// Sign in with email and password (generic)
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up (generic - prefer using NISAuthService for student registration)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? nis,
    String? major,
    int? semester,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'nis': nis,
        'major': major,
        'semester': semester,
      },
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Update profile (uses Database V3.2 schema)
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? major,
    int? semester,
  }) async {
    if (userId == null) return false;

    try {
      final updates = <String, dynamic>{};

      if (fullName != null) {
        updates['full_name'] = fullName;
      }

      if (phone != null) {
        updates['phone'] = phone;
      }

      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }

      if (major != null) {
        updates['major'] = major;
      }

      if (semester != null) {
        updates['semester'] = semester;
      }

      if (updates.isNotEmpty) {
        updates['updated_at'] = DateTime.now().toIso8601String();

        await _supabase
            .from('profiles')
            .update(updates)
            .eq('id', userId!);
      }

      return true;
    } catch (e) {
      AppLogger.error('Error updating profile', e);
      return false;
    }
  }

  /// Check if user is admin
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin';
  }

  /// Check if user is student
  Future<bool> isStudent() async {
    final role = await getUserRole();
    return role == 'student';
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Update password for currently authenticated user
  /// Note: Supabase Auth does NOT verify the current password when updating.
  /// This method will succeed if the user has an active session, regardless
  /// of whether the provided 'current password' is correct.
  /// The current password should be used for UI confirmation only.
  Future<bool> updatePassword(String newPassword) async {
    if (currentUser == null) {
      AppLogger.error('Cannot update password: no authenticated user');
      return false;
    }

    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return true;
    } catch (e) {
      AppLogger.error('Error updating password', e);
      return false;
    }
  }
}