import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ariya/ariya.dart';

/// A ball wave widget
class ProgressBallWaveIndicator extends StatefulWidget {
  /// Animation duration
  final Duration duration;

  /// Ball color
  final Color color;

  /// Space between each ball
  final double space;

  /// Widget size
  final Size size;

  /// Widget padding
  final EdgeInsets? padding;

  /// Default constructor
  const ProgressBallWaveIndicator({
    super.key,
    this.duration = const Duration(milliseconds: 1200),
    this.size = const Size(40, 20),
    this.padding,
    required this.color,
    this.space = 5,
  });

  @override
  State<ProgressBallWaveIndicator> createState() =>
      _ProgressBallWaveIndicatorState();
}

class _ProgressBallWaveIndicatorState extends State<ProgressBallWaveIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
  );
  final List<double> scales = [0, 0, 0];

  void update() {
    controller.duration = widget.duration;
  }

  @override
  void initState() {
    super.initState();
    update();
    for (int i = 0; i < 3; i++) {
      final anim = CircleTween(
        begin: 0,
        end: 1,
        offset: i * 0.1,
      ).animate(controller);
      anim.addListener(() {
        if (!mounted) return;
        scales[i] = anim.value.abs();
        if (i == 0) setState(() {});
      });
    }
    controller.repeat();
  }

  @override
  void didUpdateWidget(covariant ProgressBallWaveIndicator oldWidget) {
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
      painter: _ProgressBallWavePainter(
        scales: scales.toList(growable: false),
        padding: widget.padding,
        color: widget.color,
        space: widget.space,
      ),
    );
  }
}

class _ProgressBallWavePainter extends BasePainter {
  final List<double> scales;
  final double space;
  final painter = Paint();
  final Color color;

  _ProgressBallWavePainter({
    super.padding,
    required this.color,
    required this.scales,
    required this.space,
  }) {
    painter.color = color;
  }

  @override
  void draw(Canvas canvas, double width, double height) {
    // final progress = this.progress.abs();
    // final scale;
    // if (i == 0)
    //   scale = progress;
    // else if (i == 1) {
    //   if (this.progress >= 0) {
    //     if (progress > 0.5) {
    //       scale = progress - 0.5;
    //     } else {
    //       scale = (1 - progress) - 0.5;
    //     }
    //   } else {
    //     if (progress > 0.5) {
    //       scale = (1 - progress) + 0.5;
    //     } else {
    //       scale = progress + 0.5;
    //     }
    //   }
    // } else
    //   scale = 1 - progress;
    final radius = (width - (space * 2)) / 6;
    final x = (width / 2) - ((radius * 2) + space);
    for (int i = 0; i < 3; i++) {
      final scale = scales[i];
      if (scale < 0.01) continue;
      canvas.save();
      canvas.translate((radius * 2 * i) + x + (i * space), height / 2);
      canvas.scale(scale, scale);
      canvas.drawCircle(Offset.zero, radius, painter);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressBallWavePainter oldDelegate) {
    return color != oldDelegate.color ||
        scales != oldDelegate.scales ||
        super.shouldRepaint(oldDelegate) ||
        space != oldDelegate.space;
  }
}
