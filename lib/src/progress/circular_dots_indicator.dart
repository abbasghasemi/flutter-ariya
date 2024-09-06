import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ariya/ariya.dart';

/// A circular dots widget
class ProgressCircularDotsIndicator extends StatefulWidget {
  /// Animation duration
  final Duration duration;

  /// Progress dot color
  final Color color;

  /// Progress dot rotate
  final bool rotated;

  /// Progress dot scale
  final bool scaled;

  /// Progress dot fade
  final bool faded;

  /// Widget size
  final Size size;

  /// Widget padding
  final EdgeInsets? padding;

  /// Default constructor
  const ProgressCircularDotsIndicator({
    super.key,
    this.duration = const Duration(milliseconds: 1000),
    this.size = const Size(40, 40),
    this.padding,
    required this.color,
    this.rotated = false,
    this.scaled = true,
    this.faded = true,
  });

  @override
  State<ProgressCircularDotsIndicator> createState() =>
      _ProgressCircularDotsIndicatorState();
}

class _ProgressCircularDotsIndicatorState
    extends State<ProgressCircularDotsIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
  );

  void update() {
    controller.duration = widget.duration;
  }

  @override
  void initState() {
    super.initState();
    update();
    controller.addListener(() {
      setState(() {});
    });
    controller.repeat();
  }

  @override
  void didUpdateWidget(covariant ProgressCircularDotsIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    update();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size,
      painter: _ProgressCircularDotsPainter(
        progress: controller.value,
        padding: widget.padding,
        color: widget.color,
        rotated: widget.rotated,
        scaled: widget.scaled,
        faded: widget.faded,
      ),
    );
  }
}

class _ProgressCircularDotsPainter extends BasePainter {
  final double progress;
  final bool rotated;
  final bool scaled;
  final bool faded;
  final painter = Paint();
  final Color color;

  _ProgressCircularDotsPainter({
    super.padding,
    required this.color,
    required this.progress,
    required this.rotated,
    required this.scaled,
    required this.faded,
  });

  @override
  void draw(Canvas canvas, double width, double height) {
    final s = min(width, height) / 6;
    canvas.translate(width / 2, height / 2);
    if (rotated) canvas.rotate(progress * (6 + pi / 12));
    for (int i = 0; i < 12; i++) {
      final angle = 2 * pi / 12 * i;
      final x = cos(angle) * s * 2.5;
      final y = sin(angle) * s * 2.5;
      double p = i / 12 - progress;
      if (p < 0) p += 1;
      if (faded)
        painter.color = color.withOpacity(p);
      else
        painter.color = color;
      final _s = scaled ? s * p : s;
      canvas.drawOval(Rect.fromLTWH(x - _s / 2, y - _s / 2, _s, _s), painter);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressCircularDotsPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        color != oldDelegate.color ||
        scaled != oldDelegate.scaled ||
        faded != oldDelegate.faded ||
        rotated != oldDelegate.rotated ||
        super.shouldRepaint(oldDelegate);
  }
}
