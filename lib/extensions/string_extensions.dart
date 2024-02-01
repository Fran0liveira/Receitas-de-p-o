extension StringExtensions on String {
  String capitalize() {
    String value = this.toString();
    return "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";
  }
}
