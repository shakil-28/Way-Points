/// Formatting helpers for travel durations and estimated arrival times (ETA).
class TimeUtils {
  /// Formats a DateTime for history display.
  static String formatTimestamp(DateTime timestamp) {
    final local = timestamp.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();

    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  /// Format minutes into human-readable duration (e.g. "45 min" or "2h 15m")
  static String formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainingMinutes}m';
  }

  /// Calculates estimated arrival timestamp formatted as "03:45 PM"
  static String calculateEta({required int durationMinutes, DateTime? fromTime}) {
    final start = fromTime ?? DateTime.now();
    final arrival = start.add(Duration(minutes: durationMinutes));
    final hour = arrival.hour == 0 ? 12 : (arrival.hour > 12 ? arrival.hour - 12 : arrival.hour);
    final minute = arrival.minute.toString().padLeft(2, '0');
    final period = arrival.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Calculates detour impact text (e.g. "+8 min detour")
  static String formatDetourMinutes(int detourMinutes) {
    return '+$detourMinutes min';
  }
}
