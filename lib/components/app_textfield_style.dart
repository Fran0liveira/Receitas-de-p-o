import 'package:flutter/material.dart';
import 'package:receitas_de_pao/style/palete.dart';

class AppTextFieldStyle {
  Color fillColor;
  Color enabledColor;
  Color focusedColor;
  Color errorColor;
  double fontSize;

  AppTextFieldStyle(
      {this.fillColor,
      this.enabledColor,
      this.focusedColor,
      this.errorColor,
      this.fontSize}) {
    var palete = Palete();
    if (fillColor == null) {
      fillColor = Colors.red[50];
    }
    if (enabledColor == null) {
      enabledColor = palete.RED_700;
    }
    if (errorColor == null) {
      errorColor = palete.BLACK;
    }
    if (focusedColor == null) {
      focusedColor = palete.RED_700;
    }
    if (fontSize == null) {
      fontSize = 15;
    }
  }
}
