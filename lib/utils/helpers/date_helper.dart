import 'package:intl/intl.dart';
import '../../app/constants/app_constants.dart';

class DateHelper {
  // Format date to readable string
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  // Format time to readable string
  static String formatTime(DateTime date) {
    return DateFormat(AppConstants.timeFormat).format(date);
  }

  // Format date and time
  static String formatDateTime(DateTime date) {
    return DateFormat(AppConstants.dateTimeFormat).format(date);
  }

  // Get date only (without time)
  static DateTime getDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  // Get display text (Today, Yesterday, or formatted date)
  static String getDisplayDate(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else {
      return formatDate(date);
    }
  }

  // Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 0, 0);
  }

  // Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  // Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return startOfDay(monday);
  }

  // Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final sunday = date.add(Duration(days: 7 - date.weekday));
    return endOfDay(sunday);
  }

  // Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1, 0, 0, 0);
  }

  // Get end of month
  static DateTime endOfMonth(DateTime date) {
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    final lastDay = nextMonth.subtract(const Duration(days: 1));
    return endOfDay(lastDay);
  }

  // Get start of year
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1, 0, 0, 0);
  }

  // Get end of year
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59);
  }

  // Get month name
  static String getMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }

  // Get month and year
  static String getMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }
}
