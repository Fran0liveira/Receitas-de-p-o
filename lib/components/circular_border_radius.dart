import 'package:flutter/material.dart';

class CircularBorderRadius {
  static all(double radius) {
    return BorderRadius.all(Radius.circular(radius));
  }

  static only(
      {double topLeft,
      double topRight,
      double bottomLeft,
      double bottomRight}) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }

  static top({double left, double right}) {
    return BorderRadius.only(
      topLeft: Radius.circular(left),
      topRight: Radius.circular(right),
    );
  }

  static onlyTop(double top) {
    return BorderRadius.only(
      topLeft: Radius.circular(top),
      topRight: Radius.circular(top),
    );
  }

  static onlyBottom(double bottom) {
    return BorderRadius.only(
      bottomLeft: Radius.circular(bottom),
      bottomRight: Radius.circular(bottom),
    );
  }

  static onlyLeft(double left) {
    return BorderRadius.only(
      topLeft: Radius.circular(left),
      bottomLeft: Radius.circular(left),
    );
  }

  static onlyRight(double right) {
    return BorderRadius.only(
      topRight: Radius.circular(right),
      bottomRight: Radius.circular(right),
    );
  }

  static bottom({double left, double right}) {
    return BorderRadius.only(
      bottomLeft: Radius.circular(left),
      bottomRight: Radius.circular(right),
    );
  }

  static right({double top, double bottom}) {
    return BorderRadius.only(
      topRight: Radius.circular(top),
      bottomRight: Radius.circular(bottom),
    );
  }

  static left({double top, double bottom}) {
    return BorderRadius.only(
      topLeft: Radius.circular(top),
      bottomLeft: Radius.circular(bottom),
    );
  }
}
