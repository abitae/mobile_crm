import 'package:flutter/material.dart';

/// Widget para animaciones staggered (escalonadas) en listas
class StaggerAnimation extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDuration;
  final Duration delayBetweenItems;
  final Curve curve;

  const StaggerAnimation({
    super.key,
    required this.child,
    required this.index,
    this.baseDuration = const Duration(milliseconds: 300),
    this.delayBetweenItems = const Duration(milliseconds: 50),
    this.curve = Curves.easeOut,
  });

  @override
  State<StaggerAnimation> createState() => _StaggerAnimationState();
}

class _StaggerAnimationState extends State<StaggerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.baseDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    // Calcular delay basado en el índice
    final delay = widget.delayBetweenItems * widget.index;
    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
