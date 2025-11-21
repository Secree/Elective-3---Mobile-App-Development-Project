import 'package:intl/intl.dart';

/// Helper class for formatting dates and times
class DateTimeFormatter {
  /// Format date as "Jan 15, 2025"
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  /// Format time as "2:30 PM"
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  /// Format datetime as "Jan 15, 2025 at 2:30 PM"
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y \'at\' h:mm a').format(dateTime);
  }

  /// Format for flight schedules "14:30"
  static String formatFlightTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  /// Parse string to datetime
  static DateTime? parseDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return null;
    try {
      return DateTime.parse(dateTimeStr);
    } catch (e) {
      return null;
    }
  }

  /// Get relative time (e.g., "2 hours ago", "in 3 days")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      // Past
      final absDiff = difference.abs();
      if (absDiff.inDays > 365) {
        final years = (absDiff.inDays / 365).floor();
        return '$years ${years == 1 ? 'year' : 'years'} ago';
      } else if (absDiff.inDays > 30) {
        final months = (absDiff.inDays / 30).floor();
        return '$months ${months == 1 ? 'month' : 'months'} ago';
      } else if (absDiff.inDays > 0) {
        return '${absDiff.inDays} ${absDiff.inDays == 1 ? 'day' : 'days'} ago';
      } else if (absDiff.inHours > 0) {
        return '${absDiff.inHours} ${absDiff.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (absDiff.inMinutes > 0) {
        return '${absDiff.inMinutes} ${absDiff.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else {
        return 'Just now';
      }
    } else {
      // Future
      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return 'in $years ${years == 1 ? 'year' : 'years'}';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return 'in $months ${months == 1 ? 'month' : 'months'}';
      } else if (difference.inDays > 0) {
        return 'in ${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
      } else if (difference.inHours > 0) {
        return 'in ${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'}';
      } else if (difference.inMinutes > 0) {
        return 'in ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'}';
      } else {
        return 'Now';
      }
    }
  }

  /// Calculate flight duration
  static String getFlightDuration(DateTime departure, DateTime arrival) {
    final duration = arrival.difference(departure);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}
