import 'package:diacritic/diacritic.dart';

class CharacterCheck {
  static bool containsLower(String value) {
    return RegExp('(?=.*[a-z])').hasMatch(value);
  }

  static bool containsUpper(String value) {
    return RegExp('(?=.*[A-Z])').hasMatch(value);
  }

  static bool containsNumeric(String value) {
    return RegExp('(?=.*\\d)').hasMatch(value);
  }

  static bool containsSpecialCharacter(String value) {
    return RegExp('(?=.*[-+_!@#\$%^&*., ?])').hasMatch(value);
  }

  static String removeAcentos(String value) {
    return removeDiacritics(value);
  }
}
