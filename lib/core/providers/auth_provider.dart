import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/nis_auth_service.dart';

// Provider untuk SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences belum di-initialize');
});

// Provider untuk AuthService yang membaca dari SharedPreferences
final authServiceProvider = Provider<AuthService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthService(prefs);
});

// Provider untuk NISAuthService
final nisAuthServiceProvider = Provider<NISAuthService>((ref) {
  return NISAuthService();
});

// Provider untuk userName - fetch dari Supabase real-time
final userNameProvider = FutureProvider<String>((ref) async {
  final nisAuthService = ref.watch(nisAuthServiceProvider);
  
  // Try to get profile from Supabase
  final profile = await nisAuthService.getCurrentUserProfile();
  
  if (profile != null && profile.fullName.isNotEmpty) {
    return profile.fullName;
  }
  
  // Fallback to SharedPreferences if Supabase fails
  final authService = ref.watch(authServiceProvider);
  return authService.userName ?? 'User';
});
