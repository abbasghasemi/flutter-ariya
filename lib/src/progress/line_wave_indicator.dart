import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ariya/ariya.dart';

/// A line wave widget
class ProgressLineWaveIndicator extends StatefulWidget {
  /// Animation duration
  final Duration duration;

  /// Line color
  final Color color;

  /// Between 0.0 and 1.0
  /// Progress time
  final double timing;

  /// Widget size
  final Size size;

  /// Widget padding
  final EdgeInsets? padding;

  /// Default constructor
  const ProgressLineWaveIndicator({
    super.key,
    this.duration = const Duration(milliseconds: 1200),
    this.size = const Size(40, 40),
    this.padding,
    required this.color,
    this.timing = 0.2,
  });

  @override
  State<ProgressLineWaveIndicator> createState() =>
      _ProgressLineWaveIndicatorState();
}

class _ProgressLineWaveIndicatorState extends State<ProgressLineWaveIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
  );
  final List<double> scales = [0, 0, 0, 0, 0];

  void update() {
    controller.duration = widget.duration;
  }

  @override
  void initState() {
    super.initState();
    update();
    for (int i = 0; i < 3; i++) {
      final anim = CircleTween(
        begin: 0.3,
        end: 1,
        offset: i * widget.timing,
      ).animate(controller);
      anim.addListener(() {
        if (!mounted) return;
        scales[i] = anim.value.abs();
        if (i == 0) {
          scales[4] = anim.value.abs();
          setState(() {});
        } else if (i == 1) {
          scales[3] = anim.value.abs();
        }
      });
    }
    controller.repeat();
  }

  @override
  void didUpdateWidget(covariant ProgressLineWaveIndicator oldWidget) {
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
      painter: _ProgressLineWavePainter(
        scales: scales.toList(growable: false),
        padding: widget.padding,
        color: widget.color,
      ),
    );
  }
}

class _ProgressLineWavePainter extends BasePainter {
  final List<double> scales;
  final painter = Paint();
  final Color color;

  _ProgressLineWavePainter({
    super.padding,
    required this.color,
    required this.scales,
  }) {
    painter.color = color;
  }

  @override
  void draw(Canvas canvas, double width, double height) {
    double x = width / 11;
    double y = height / 2;
    for (int i = 0; i < 5; i++) {
      canvas.save();
      canvas.translate((2 + i * 2) * x - x / 2, y);
      canvas.scale(1, scales[i]);
      canvas.drawRRect(
          RRect.fromLTRBR(
              -x / 2, -height / 2.5, x / 2, height / 2.5, Radius.circular(5)),
          painter);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressLineWavePainter oldDelegate) {
    return color != oldDelegate.color ||
        scales != oldDelegate.scales ||
        super.shouldRepaint(oldDelegate);
  }
}
