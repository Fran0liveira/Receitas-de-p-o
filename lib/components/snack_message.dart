import 'package:flutter/material.dart';

class SnackMessage {
  BuildContext context;
  SnackMessage(this.context);
  show(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
    ));
  }
}
