import 'package:flutter/material.dart';

class Arguments {
  T get<T>(BuildContext context) {
    return ModalRoute.of(context).settings.arguments as T;
  }
}
