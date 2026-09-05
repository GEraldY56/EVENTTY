import 'package:intl/intl.dart';

/// Date Formatter Utilities
class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime date, {String format = 'd MMMM yyyy'}) {
    return DateFormat(format, 'id_ID').format(date);
  }

  static String formatTime(DateTime time, {String format = 'HH:mm'}) {
    return DateFormat(format).format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(dateTime);
  }

  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} tahun lalu';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} bulan lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('d MMM', 'id_ID').format(date);
  }

  static String getDayName(DateTime date) {
    return DateFormat('EEEE', 'id_ID').format(date);
  }

  static String getMonthName(DateTime date) {
    return DateFormat('MMMM', 'id_ID').format(date);
  }
}
