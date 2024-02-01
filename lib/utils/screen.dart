import 'package:flutter/material.dart';

class Screen {
  BuildContext context;

  Screen(this.context);

  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;
  Size get size => Size(width, height);

  bool get isHorizontal => width > height;
  bool get isVertical => !isHorizontal;

  double get keyboardHeigth => MediaQuery.of(context).viewInsets.bottom;
  double get reimainingHeight => height - keyboardHeigth;

  hideKeyboard() {
    FocusManager.instance.primaryFocus.unfocus();
  }

  static Screen of(BuildContext context) {
    return Screen(context);
  }
}
