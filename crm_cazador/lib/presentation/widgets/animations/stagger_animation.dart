import 'package:flutter/material.dart';
import '../../utils/animation_utils.dart';
import 'fade_in_animation.dart';
import 'slide_animation.dart';

class StaggerAnimation extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration itemDuration;
  final Duration staggerDelay;
  final Offset slideOffset;

  const StaggerAnimation({
    super.key,
    required this.child,
    required this.index,
    this.itemDuration = AnimationUtils.defaultDuration,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.slideOffset = const Offset(0, 0.1),
  });

  @override
  Widget build(BuildContext context) {
    final delay = staggerDelay * index;
    return FadeInAnimation(
      duration: itemDuration,
      delay: delay,
      child: SlideAnimation(
        duration: itemDuration,
        delay: delay,
        beginOffset: slideOffset,
        child: child,
      ),
    );
  }
}
