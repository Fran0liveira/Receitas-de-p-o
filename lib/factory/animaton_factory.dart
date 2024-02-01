import 'package:flutter/material.dart';
import 'package:receitas_de_pao/animation/scroll_animation.dart';

class AnimationFactory {
  ScrollAnimation scrollToPosition(double position) {
    return ScrollAnimation(
        position, Duration(milliseconds: 400), Curves.fastOutSlowIn);
  }
}
