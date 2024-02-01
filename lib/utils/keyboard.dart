import 'package:flutter/cupertino.dart';

class Keyboard {
  static hide(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}
