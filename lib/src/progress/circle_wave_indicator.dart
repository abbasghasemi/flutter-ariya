import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ariya/ariya.dart';

/// A Circle wave widget
class ProgressCircleWaveIndicator extends StatefulWidget {
  /// Animation duration
  final Duration duration;

  /// Circle color
  final Color color;

  /// Widget size
  final Size size;

  /// Widget padding
  final EdgeInsets? padding;

  /// Default constructor
  const ProgressCircleWaveIndicator({
    super.key,
    this.duration = const Duration(milliseconds: 1200),
    this.size = const Size(40, 40),
    this.padding,
    required this.color,
  });

  @override
  State<ProgressCircleWaveIndicator> createState() =>
      _ProgressCircleWaveIndicatorState();
}

class _ProgressCircleWaveIndicatorState
    extends State<ProgressCircleWaveIndicator> with TickerProviderStateMixin {
  late final List<AnimationController> controllers = [
    AnimationController(
      vsync: this,
    ),
    AnimationController(
      vsync: this,
    ),
    AnimationController(
      vsync: this,
    )
  ];
  final List<double> scales = [0, 0, 0];

  void update() {
    for (var controller in controllers) {
      controller.duration = widget.duration;
    }
  }

  @override
  void initState() {
    super.initState();
    update();
    for (int i = 0; i < 3; i++) {
      final anim = Tween(
        begin: 1.0,
        end: 0.0,
      ).animate(controllers[i]);
      anim.addListener(() {
        if (!mounted) return;
        setState(() {
          scales[i] = anim.value;
        });
      });
      controllers[i].value = i * 0.33;
      controllers[i].repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ProgressCircleWaveIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    update();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size,
      painter: _ProgressCircleWavePainter(
        scales: scales.toList(growable: false),
        padding: widget.padding,
        color: widget.color,
      ),
    );
  }
}

class _ProgressCircleWavePainter extends BasePainter {
  final List<double> scales;
  final painter = Paint();
  final Color color;

  _ProgressCircleWavePainter({
    super.padding,
    required this.color,
    required this.scales,
  });

  @override
  void draw(Canvas canvas, double width, double height) {
    canvas.translate(width / 2, height / 2);
    for (int i = 0; i < 3; i++) {
      final scale = 1 - scales[i];
      painter.color = color.withOpacity(scales[i]);
      canvas.save();
      canvas.scale(scale, scale);
      canvas.drawCircle(Offset.zero, min(width, height) / 2, painter);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressCircleWavePainter oldDelegate) {
    return scales != oldDelegate.scales ||
        color != oldDelegate.color ||
        super.shouldRepaint(oldDelegate);
  }
}
