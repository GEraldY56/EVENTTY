import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_auth_service.dart';
import 'nis_auth_service.dart';

/// Authentication Service
/// Menjaga API lama EVENTTY agar halaman yang sudah ada tetap kompatibel,
/// tetapi authentication sekarang menggunakan NISAuthService untuk students.
class AuthService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserRole = 'userRole';
  static const String _keyUserId = 'userId';
  static const String _keyUserName = 'userName';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserClass = 'userClass';

  final SharedPreferences _prefs;
  final SupabaseAuthService _supabaseAuth = SupabaseAuthService();
  final NISAuthService _nisAuth = NISAuthService();

  AuthService(this._prefs);

  bool get isLoggedIn {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  String? get userRole => _prefs.getString(_keyUserRole);

  String? get userId => _prefs.getString(_keyUserId);

  String? get userName => _prefs.getString(_keyUserName);

  String? get userEmail => _prefs.getString(_keyUserEmail);

  String? get userClass => _prefs.getString(_keyUserClass);

  /// Get formatted class from profile (computed from major + semester)
  Future<String> getUserClass() async {
    try {
      final profile = await _nisAuth.getCurrentUserProfile();
      if (profile != null && profile.major != null && profile.semester != null) {
        // Convert semester to grade level (1-2 = X, 3-4 = XI, 5-6 = XII)
        String grade;
        if (profile.semester! <= 2) {
          grade = 'X';
        } else if (profile.semester! <= 4) {
          grade = 'XI';
        } else {
          grade = 'XII';
        }
        return '$grade ${profile.major}';
      }
      // Fallback to stored value or default
      return userClass ?? 'XII RPL 1';
    } catch (e) {
      return userClass ?? 'XII RPL 1';
    }
  }

  bool get isAdmin => userRole == 'admin';

  bool get isStudent => userRole == 'student';

  /// Register student dengan NIS (NEW - Task #2)
  Future<void> registerWithNIS({
    required String fullName,
    required String nis,
    required String password,
  }) async {
    // Delegate to NISAuthService
    await _nisAuth.registerWithNIS(
      fullName: fullName,
      nis: nis,
      password: password,
    );

    // Profile will be auto-created by database trigger
    // No need to manually save session here - user should login after registration
  }

  /// Login dengan NIS (NEW - Task #1)
  Future<void> loginWithNIS({
    required String nis,
    required String password,
  }) async {
    // Delegate to NISAuthService
    final user = await _nisAuth.loginWithNIS(
      nis: nis,
      password: password,
    );

    // Get profile from database
    final profile = await _nisAuth.getCurrentUserProfile();

    if (profile == null) {
      throw const AuthException('Profile tidak ditemukan');
    }

    // Save session to SharedPreferences for compatibility
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserRole, profile.role);
    await _prefs.setString(_keyUserId, user.id);
    await _prefs.setString(_keyUserName, profile.fullName);
    await _prefs.setString(_keyUserEmail, user.email ?? '$nis@eventty.local');
  }

  /// Login menggunakan Supabase Auth (LEGACY - keep for admin/email-based auth)
  Future<void> login({
    required String email,
    required String password,
    String? role,
    String? userId,
    String? userName,
  }) async {
    // Login ke Supabase Auth
    final response = await _supabaseAuth.signIn(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw const AuthException('User tidak ditemukan setelah login.');
    }

    // Ambil profile dari tabel profiles
    final profile = await _supabaseAuth.getUserProfile();

    final actualRole =
        profile?.role ?? role ?? 'student';

    final actualName =
        profile?.fullName ??
        userName ??
        user.email?.split('@').first ??
        'User';

    // Note: 'class' field removed - not in database schema
    // Use 'major' or 'semester' if needed in future

    // Simpan session info agar kode lama EVENTTY tetap bisa digunakan
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserRole, actualRole);
    await _prefs.setString(_keyUserId, user.id);
    await _prefs.setString(_keyUserName, actualName);
    await _prefs.setString(
      _keyUserEmail,
      user.email ?? email,
    );
  }

  Future<void> logout() async {
    await _supabaseAuth.signOut();
    await _prefs.clear();
  }

  Future<void> updateProfile({
    String? userName,
    String? userEmail,
  }) async {
    if (userName != null) {
      await _prefs.setString(_keyUserName, userName);
    }

    if (userEmail != null) {
      await _prefs.setString(_keyUserEmail, userEmail);
    }
  }
}