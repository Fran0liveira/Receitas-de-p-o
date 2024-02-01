class DurationUtils {
  static formatDefault(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);

    String formattedMinutes = _formatMinutes(minutes);

    String formattedHours = '';

    if (hours == 0) {
      return formattedMinutes;
    } else {
      formattedHours = _formatHour(hours);
      return '$formattedHours:$formattedMinutes';
    }
  }

  static _formatHour(int hours) {
    return '${hours.toString().padLeft(1, '0')}h';
  }

  static _formatMinutes(int minutes) {
    return '${minutes.toString().padLeft(2, '0')}min';
  }
}
