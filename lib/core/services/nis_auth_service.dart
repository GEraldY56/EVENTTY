import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../utils/logger.dart';

/// NIS-Based Authentication Service for EVENTTY V3.2
/// 
/// REGISTER FLOW:
/// 1. User enters: Full Name, NIS (5 digits), Password, Confirm Password
/// 2. Flutter validates: password == confirmPassword
/// 3. Flutter calls: registerWithNIS()
/// 4. Service creates internal email: {NIS}@eventty.local
/// 5. Supabase Auth creates user with metadata
/// 6. Database trigger auto-creates profile (role = student)
/// 
/// LOGIN FLOW:
/// 1. User enters: NIS, Password
/// 2. Flutter calls: loginWithNIS()
/// 3. Service converts NIS to internal email
/// 4. Supabase Auth verifies credentials
/// 
/// INTERNAL EMAIL FORMAT:
/// - 12345@eventty.local
/// - Not shown to users
/// - Used only for Supabase Auth
class NISAuthService {
  static const String _emailDomain = '@eventty.local';
  
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Convert NIS to internal email
  String _nisToEmail(String nis) {
    return '$nis$_emailDomain';
  }

  /// Validate NIS format (exactly 5 digits)
  bool validateNIS(String nis) {
    final regex = RegExp(r'^\d{5}$');
    return regex.hasMatch(nis);
  }

  /// Validate password strength
  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (password.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null; // Valid
  }

  /// Validate full name
  String? validateFullName(String fullName) {
    if (fullName.trim().isEmpty) {
      return 'Nama lengkap tidak boleh kosong';
    }
    if (fullName.trim().length < 3) {
      return 'Nama lengkap minimal 3 karakter';
    }
    return null; // Valid
  }

  // ============================================================
  // REGISTER
  // ============================================================

  /// Register new student with NIS
  /// 
  /// Parameters:
  /// - fullName: Student's full name
  /// - nis: 5-digit student ID
  /// - password: Account password
  /// - confirmPassword: Must match password (validated before calling)
  /// 
  /// Returns:
  /// - Success: User object
  /// - Error: Throws AuthException
  Future<User> registerWithNIS({
    required String fullName,
    required String nis,
    required String password,
  }) async {
    try {
      // ========================================================
      // Validations
      // ========================================================

      // Validate full name
      final nameError = validateFullName(fullName);
      if (nameError != null) {
        throw AuthException(nameError);
      }

      // Validate NIS
      if (!validateNIS(nis)) {
        throw AuthException('NIS harus terdiri dari tepat 5 angka');
      }

      // Validate password
      final passwordError = validatePassword(password);
      if (passwordError != null) {
        throw AuthException(passwordError);
      }

      // ========================================================
      // Check if NIS already registered
      // ========================================================

      final existingProfile = await _supabase
          .from('profiles')
          .select('nis')
          .eq('nis', nis)
          .maybeSingle();

      if (existingProfile != null) {
        throw AuthException('NIS $nis sudah terdaftar');
      }

      // ========================================================
      // Create Supabase Auth account
      // ========================================================

      final authEmail = _nisToEmail(nis);

      final response = await _supabase.auth.signUp(
        email: authEmail,
        password: password,
        data: {
          'full_name': fullName.trim(),
          'nis': nis,
        },
      );

      if (response.user == null) {
        throw AuthException('Registrasi gagal. Silakan coba lagi.');
      }

      AppLogger.info('User registered successfully: $nis');

      // Profile will be auto-created by database trigger
      // Role will automatically be 'student'

      return response.user!;
    } on AuthException catch (e) {
      AppLogger.error('Registration error', e);
      rethrow;
    } catch (e) {
      AppLogger.error('Unexpected registration error', e);
      throw AuthException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  /// Login with NIS and password
  /// 
  /// Parameters:
  /// - nis: 5-digit student ID
  /// - password: Account password
  /// 
  /// Returns:
  /// - Success: User object
  /// - Error: Throws AuthException
  Future<User> loginWithNIS({
    required String nis,
    required String password,
  }) async {
    try {
      // ========================================================
      // Validations
      // ========================================================

      if (!validateNIS(nis)) {
        throw AuthException('NIS harus terdiri dari 5 angka');
      }

      if (password.isEmpty) {
        throw AuthException('Password tidak boleh kosong');
      }

      // ========================================================
      // Login via Supabase Auth
      // ========================================================

      final authEmail = _nisToEmail(nis);

      final response = await _supabase.auth.signInWithPassword(
        email: authEmail,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Login gagal');
      }

      AppLogger.info('User logged in: $nis');

      return response.user!;
    } on AuthException catch (e) {
      AppLogger.error('Login error', e);
      
      // User-friendly error messages
      if (e.message.contains('Invalid login credentials')) {
        throw AuthException('NIS atau password salah');
      }
      
      rethrow;
    } catch (e) {
      AppLogger.error('Unexpected login error', e);
      throw AuthException('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  /// Logout current user
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      AppLogger.info('User logged out');
    } catch (e) {
      AppLogger.error('Logout error', e);
      throw AuthException('Logout gagal');
    }
  }

  // ============================================================
  // GET CURRENT USER
  // ============================================================

  /// Get current logged in user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Get current user's NIS from profile
  Future<String?> getCurrentUserNIS() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final profile = await _supabase
          .from('profiles')
          .select('nis')
          .eq('id', user.id)
          .single();

      return profile['nis'] as String?;
    } catch (e) {
      AppLogger.error('Error fetching user NIS', e);
      return null;
    }
  }

  /// Get current user's profile as ProfileModel
  Future<ProfileModel?> getCurrentUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return ProfileModel.fromJson(profile);
    } catch (e) {
      AppLogger.error('Error fetching user profile', e);
      return null;
    }
  }

  /// Check if current user is admin
  Future<bool> isAdmin() async {
    try {
      final profile = await getCurrentUserProfile();
      return profile?.isAdmin ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Check if current user is student
  Future<bool> isStudent() async {
    try {
      final profile = await getCurrentUserProfile();
      return profile?.isStudent ?? false;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // AUTH STATE CHANGES
  // ============================================================

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // ============================================================
  // PASSWORD RESET
  // ============================================================

  /// Send password reset email (for future implementation)
  /// Note: Since we use internal emails ({NIS}@eventty.local),
  /// password reset needs custom implementation
  Future<void> resetPassword(String nis) async {
    // TODO: Implement custom password reset flow
    // Option 1: Admin manually resets via dashboard
    // Option 2: SMS OTP verification
    // Option 3: Security questions
    throw UnimplementedError('Password reset not yet implemented');
  }
}

/// Auth Result Model
class AuthResult {
  final bool success;
  final String message;
  final User? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });

  factory AuthResult.success(User user) {
    return AuthResult(
      success: true,
      message: 'Berhasil',
      user: user,
    );
  }

  factory AuthResult.error(String message) {
    return AuthResult(
      success: false,
      message: message,
    );
  }
}
