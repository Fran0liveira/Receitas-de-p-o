import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:receitas_de_pao/animation/scroll_animation.dart';

import 'animaton_factory.dart';

class Scroll {
  ScrollController scrollController;
  Scroll(this.scrollController);

  scrollToTop() async {
    await Future.delayed(const Duration(milliseconds: 300));

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      ScrollAnimation scrollAnimation = AnimationFactory()
          .scrollToPosition(scrollController.position.minScrollExtent);

      scrollController.animateTo(scrollAnimation.position,
          duration: scrollAnimation.duration, curve: scrollAnimation.curve);
    });
  }

  jumpToPosition(double position) async {
    await Future.delayed(const Duration(milliseconds: 300));

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.jumpTo(position);
    });
  }

  jumpToTop() async {
    await Future.delayed(const Duration(milliseconds: 300));

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.jumpTo(0);
    });
  }
}
