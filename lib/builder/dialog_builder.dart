import 'package:flutter/material.dart';
import 'package:receitas_de_pao/components/app_button.dart';

class DialogBuilder extends StatelessWidget {
  BuildContext context;
  AppButton appButtonRight;
  AppButton appButtonLeft;
  String title;
  String message;

  DialogBuilder(
      {this.context,
      this.title,
      this.appButtonRight,
      this.appButtonLeft,
      this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [appButtonLeft, appButtonRight],
    );
  }
}
