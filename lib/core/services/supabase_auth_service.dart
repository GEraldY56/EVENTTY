import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  String? get userId => currentUser?.id;

  bool get isLoggedIn => currentUser != null;

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
      print('Error getting user role: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (userId == null) return null;

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId!)
          .single();

      return response;
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? studentId,
    String? classInfo,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role,
        'student_id': studentId,
        'class': classInfo,
      },
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? studentId,
    String? classInfo,
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

      if (studentId != null) {
        updates['student_id'] = studentId;
      }

      if (classInfo != null) {
        updates['class'] = classInfo;
      }

      await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId!);

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }
}