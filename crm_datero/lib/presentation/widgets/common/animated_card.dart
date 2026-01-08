import 'package:flutter/material.dart';

/// Tarjeta con animación de entrada y efecto hover/press
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;
  final VoidCallback? onTap;
  final Duration animationDuration;
  final int animationDelay;

  const AnimatedCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.elevation,
    this.shape,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationDelay = 0,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Iniciar animación con delay
    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
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
        child: Card(
          margin: widget.margin,
          color: widget.color,
          elevation: widget.elevation,
          shape: widget.shape,
          child: widget.onTap != null
              ? InkWell(
                  onTap: widget.onTap,
                  borderRadius: widget.shape is RoundedRectangleBorder
                      ? (widget.shape as RoundedRectangleBorder).borderRadius
                      : BorderRadius.circular(12),
                  child: widget.padding != null
                      ? Padding(
                          padding: widget.padding!,
                          child: widget.child,
                        )
                      : widget.child,
                )
              : widget.padding != null
                  ? Padding(
                      padding: widget.padding!,
                      child: widget.child,
                    )
                  : widget.child,
        ),
      ),
    );
  }
}
