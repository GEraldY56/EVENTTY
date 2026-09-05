import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_auth_service.dart';

/// Authentication Service
/// Menjaga API lama EVENTTY agar halaman yang sudah ada tetap kompatibel,
/// tetapi authentication sekarang menggunakan Supabase.
class AuthService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserRole = 'userRole';
  static const String _keyUserId = 'userId';
  static const String _keyUserName = 'userName';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserClass = 'userClass';

  final SharedPreferences _prefs;
  final SupabaseAuthService _supabaseAuth = SupabaseAuthService();

  AuthService(this._prefs);

  bool get isLoggedIn {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  String? get userRole => _prefs.getString(_keyUserRole);

  String? get userId => _prefs.getString(_keyUserId);

  String? get userName => _prefs.getString(_keyUserName);

  String? get userEmail => _prefs.getString(_keyUserEmail);

  String? get userClass => _prefs.getString(_keyUserClass);

  bool get isAdmin => userRole == 'admin';

  bool get isStudent => userRole == 'student';

  /// Login menggunakan Supabase Auth
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
        profile?['role'] as String? ?? role ?? 'student';

    final actualName =
        profile?['full_name'] as String? ??
        userName ??
        user.email?.split('@').first ??
        'User';

    final actualClass =
        profile?['class'] as String?;

    // Simpan session info agar kode lama EVENTTY tetap bisa digunakan
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserRole, actualRole);
    await _prefs.setString(_keyUserId, user.id);
    await _prefs.setString(_keyUserName, actualName);
    await _prefs.setString(
      _keyUserEmail,
      user.email ?? email,
    );

    if (actualClass != null) {
      await _prefs.setString(_keyUserClass, actualClass);
    }
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