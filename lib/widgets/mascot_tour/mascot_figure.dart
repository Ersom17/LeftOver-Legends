// lib/widgets/mascot_tour/mascot_figure.dart
//
// Renders the red line-art mascot in one of three poses (left/right/up) plus
// a fourth "end" figure for the finale. Adds a gentle idle bob and blink so
// the character feels alive when stationary.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../providers/mascot_tour_provider.dart';

class MascotFigure extends StatefulWidget {
  final MascotPose pose;
  final double height;
  final bool animate;

  const MascotFigure({
    super.key,
    required this.pose,
    this.height = 120,
    this.animate = true,
  });

  @override
  State<MascotFigure> createState() => _MascotFigureState();
}

class _MascotFigureState extends State<MascotFigure>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.animate) _bob.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant MascotFigure oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_bob.isAnimating) {
      _bob.repeat(reverse: true);
    } else if (!widget.animate && _bob.isAnimating) {
      _bob.stop();
    }
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  String get _assetPath {
    switch (widget.pose) {
      case MascotPose.left:
        return 'assets/mascot/left.svg';
      case MascotPose.right:
        return 'assets/mascot/right.svg';
      case MascotPose.up:
        return 'assets/mascot/up.svg';
      case MascotPose.end:
        return 'assets/mascot/end.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final svg = SvgPicture.asset(_assetPath, height: widget.height);
    if (!widget.animate) return svg;

    return AnimatedBuilder(
      animation: _bob,
      builder: (context, child) {
        final curved = Curves.easeInOut.transform(_bob.value);
        final dy = -4.0 * curved;
        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
      child: svg,
    );
  }
}
