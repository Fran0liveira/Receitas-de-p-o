class StringUtils {
  static String getEmptyIfNull(String value) {
    return value != null ? value : "";
  }

  static bool isNullOrEmpty(String value) {
    return value == null || value.trim().isEmpty;
  }

  static String valueOf(var value) {
    return value != null ? value.toString() : 'null';
  }
}
