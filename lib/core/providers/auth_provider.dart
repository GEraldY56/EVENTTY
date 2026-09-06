import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

// Provider untuk SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences belum di-initialize');
});

// Provider untuk AuthService yang membaca dari SharedPreferences
final authServiceProvider = Provider<AuthService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthService(prefs);
});

// Provider untuk userName
final userNameProvider = Provider<String>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.userName ?? 'User';
});
