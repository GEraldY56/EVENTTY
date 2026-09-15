import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

/// Chat Operating Hours Service
/// Manages CS availability checking
class ChatOperatingHoursService {
  // Singleton pattern
  static final ChatOperatingHoursService _instance = ChatOperatingHoursService._internal();
  factory ChatOperatingHoursService() => _instance;
  ChatOperatingHoursService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Cache operating hours to reduce database calls
  List<OperatingHours>? _cachedHours;
  DateTime? _lastFetch;

  /// Get all operating hours from database
  Future<List<OperatingHours>> getOperatingHours() async {
    try {
      // Use cache if fetched within last 5 minutes
      if (_cachedHours != null && _lastFetch != null) {
        final diff = DateTime.now().difference(_lastFetch!);
        if (diff.inMinutes < 5) {
          return _cachedHours!;
        }
      }

      final response = await _supabase
          .from('chat_operating_hours')
          .select()
          .order('day_of_week', ascending: true);

      _cachedHours = (response as List)
          .map((json) => OperatingHours.fromJson(json))
          .toList();
      _lastFetch = DateTime.now();

      return _cachedHours!;
    } catch (e) {
      AppLogger.error('Error fetching operating hours', e);
      return _getDefaultHours(); // Fallback to hardcoded schedule
    }
  }

  /// Check if CS is currently online
  Future<bool> isCSOnline() async {
    try {
      final now = DateTime.now();
      final dayOfWeek = now.weekday; // 1=Monday, 7=Sunday
      final currentTime = TimeOfDay.fromDateTime(now);

      final hours = await getOperatingHours();
      final todayHours = hours.firstWhere(
        (h) => h.dayOfWeek == dayOfWeek,
        orElse: () => OperatingHours(
          dayOfWeek: dayOfWeek,
          dayName: _getDayName(dayOfWeek),
          isOpen: false,
        ),
      );

      if (!todayHours.isOpen) {
        return false;
      }

      if (todayHours.openTime == null || todayHours.closeTime == null) {
        return false;
      }

      return _isTimeBetween(
        currentTime,
        todayHours.openTime!,
        todayHours.closeTime!,
      );
    } catch (e) {
      AppLogger.error('Error checking CS online status', e);
      return false; // Safe default: assume offline
    }
  }

  /// Get operating hours text for display
  Future<String> getOperatingHoursText() async {
    try {
      final hours = await getOperatingHours();
      final workdays = hours.where((h) => h.isOpen).toList();

      if (workdays.isEmpty) {
        return 'Customer Service tidak tersedia';
      }

      // Check if all workdays have same hours
      final firstOpen = workdays.first.openTime;
      final firstClose = workdays.first.closeTime;
      final allSame = workdays.every(
        (h) => h.openTime == firstOpen && h.closeTime == firstClose,
      );

      if (allSame) {
        // Simple format: "Senin-Jumat, 06:00 - 15:00"
        final firstDay = workdays.first.dayName;
        final lastDay = workdays.last.dayName;
        return '$firstDay - $lastDay, ${_formatTime(firstOpen!)} - ${_formatTime(firstClose!)}';
      } else {
        // Detailed format
        return workdays
            .map((h) =>
                '${h.dayName}: ${_formatTime(h.openTime!)} - ${_formatTime(h.closeTime!)}')
            .join('\n');
      }
    } catch (e) {
      return 'Senin - Jumat, 06:00 - 15:00'; // Fallback
    }
  }

  /// Get status info for UI
  Future<CSStatusInfo> getCSStatusInfo() async {
    final isOnline = await isCSOnline();
    final hoursText = await getOperatingHoursText();

    return CSStatusInfo(
      isOnline: isOnline,
      statusText: isOnline ? 'CS Online' : 'CS Offline',
      hoursText: hoursText,
    );
  }

  /// Clear cache (call when admin updates operating hours)
  void clearCache() {
    _cachedHours = null;
    _lastFetch = null;
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  bool _isTimeBetween(TimeOfDay current, TimeOfDay open, TimeOfDay close) {
    final currentMinutes = current.hour * 60 + current.minute;
    final openMinutes = open.hour * 60 + open.minute;
    final closeMinutes = close.hour * 60 + close.minute;

    return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  /// Default hours if database fetch fails
  List<OperatingHours> _getDefaultHours() {
    return [
      OperatingHours(
        dayOfWeek: 1,
        dayName: 'Monday',
        openTime: const TimeOfDay(hour: 6, minute: 0),
        closeTime: const TimeOfDay(hour: 15, minute: 0),
        isOpen: true,
      ),
      OperatingHours(
        dayOfWeek: 2,
        dayName: 'Tuesday',
        openTime: const TimeOfDay(hour: 6, minute: 0),
        closeTime: const TimeOfDay(hour: 15, minute: 0),
        isOpen: true,
      ),
      OperatingHours(
        dayOfWeek: 3,
        dayName: 'Wednesday',
        openTime: const TimeOfDay(hour: 6, minute: 0),
        closeTime: const TimeOfDay(hour: 15, minute: 0),
        isOpen: true,
      ),
      OperatingHours(
        dayOfWeek: 4,
        dayName: 'Thursday',
        openTime: const TimeOfDay(hour: 6, minute: 0),
        closeTime: const TimeOfDay(hour: 15, minute: 0),
        isOpen: true,
      ),
      OperatingHours(
        dayOfWeek: 5,
        dayName: 'Friday',
        openTime: const TimeOfDay(hour: 6, minute: 0),
        closeTime: const TimeOfDay(hour: 15, minute: 0),
        isOpen: true,
      ),
      OperatingHours(
        dayOfWeek: 6,
        dayName: 'Saturday',
        isOpen: false,
      ),
      OperatingHours(
        dayOfWeek: 7,
        dayName: 'Sunday',
        isOpen: false,
      ),
    ];
  }
}

// ============================================================
// MODELS
// ============================================================

/// Operating Hours Model
class OperatingHours {
  final String id;
  final int dayOfWeek; // 1=Monday, 7=Sunday
  final String dayName;
  final TimeOfDay? openTime;
  final TimeOfDay? closeTime;
  final bool isOpen;

  OperatingHours({
    this.id = '',
    required this.dayOfWeek,
    required this.dayName,
    this.openTime,
    this.closeTime,
    required this.isOpen,
  });

  factory OperatingHours.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parseTime(String? timeStr) {
      if (timeStr == null) return null;
      try {
        final parts = timeStr.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } catch (e) {
        return null;
      }
    }

    return OperatingHours(
      id: json['id'] ?? '',
      dayOfWeek: json['day_of_week'] as int,
      dayName: json['day_name'] as String,
      openTime: parseTime(json['open_time']),
      closeTime: parseTime(json['close_time']),
      isOpen: json['is_open'] as bool,
    );
  }
}

/// CS Status Info for UI
class CSStatusInfo {
  final bool isOnline;
  final String statusText;
  final String hoursText;

  CSStatusInfo({
    required this.isOnline,
    required this.statusText,
    required this.hoursText,
  });
}

/// TimeOfDay extension for comparison
extension TimeOfDayExtension on TimeOfDay {
  int toMinutes() => hour * 60 + minute;

  bool isBefore(TimeOfDay other) => toMinutes() < other.toMinutes();
  bool isAfter(TimeOfDay other) => toMinutes() > other.toMinutes();
  bool isBetween(TimeOfDay start, TimeOfDay end) {
    final current = toMinutes();
    final startMinutes = start.toMinutes();
    final endMinutes = end.toMinutes();
    return current >= startMinutes && current <= endMinutes;
  }
}
