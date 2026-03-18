import 'package:flutter/material.dart';

import '../../core/theme/app_theme_tokens.dart';

class AppAnimatedReveal extends StatefulWidget {
  const AppAnimatedReveal({
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.03),
    this.duration = AppDurations.medium,
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Offset offset;
  final Duration duration;

  @override
  State<AppAnimatedReveal> createState() => _AppAnimatedRevealState();
}

class _AppAnimatedRevealState extends State<AppAnimatedReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : widget.offset,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
