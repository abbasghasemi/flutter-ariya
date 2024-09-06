import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ariya/ariya.dart';

/// A circular widget
class ProgressCircularIndicator extends StatefulWidget {
  /// Animation rotation duration
  final Duration rotationDuration;

  /// Animation rising duration
  final Duration risingDuration;

  /// Progress stroke width
  final double strokeWidth;

  /// Progress stroke cap
  final StrokeCap strokeCap;

  /// Progress color
  final Color color;

  /// Progress background color
  final Color? backgroundColor;

  /// Progress background width
  final double backgroundWidth;

  /// Progress value must be between 0 and 1
  /// If the value is set, animation was disabled
  final double? value;

  /// Widget size
  final Size size;

  /// Widget padding
  final EdgeInsets? padding;

  /// Default constructor
  const ProgressCircularIndicator({
    super.key,
    this.rotationDuration = const Duration(milliseconds: 2000),
    this.risingDuration = const Duration(milliseconds: 500),
    this.strokeWidth = 3.5,
    this.strokeCap = StrokeCap.round,
    this.size = const Size(40, 40),
    this.padding,
    required this.color,
    this.backgroundColor,
    this.backgroundWidth = 3.5,
    this.value,
  });

  @override
  State<ProgressCircularIndicator> createState() =>
      _ProgressCircularIndicatorState();
}

class _ProgressCircularIndicatorState extends State<ProgressCircularIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
  );

  int startAngle = 0;
  double angleLength = 0;
  bool risingCircleLength = false;
  int lastUpdateTime = 0;
  int currentProgressTime = 0;

  void update() {
    controller.duration = widget.rotationDuration;
  }

  double accelerate(double t) {
    return t * t;
  }

  void calculate() {
    if (mounted)
      setState(() {
        final newTime = SamplingClock().now().millisecondsSinceEpoch;
        int dt = newTime - lastUpdateTime;
        if (dt > 17) {
          dt = 17;
        }
        lastUpdateTime = newTime;
        startAngle += 360 * dt ~/ widget.rotationDuration.inMilliseconds;
        int count = startAngle ~/ 360;
        startAngle -= count * 360;
        currentProgressTime += dt;
        if (currentProgressTime >= widget.risingDuration.inMilliseconds) {
          currentProgressTime = widget.risingDuration.inMilliseconds;
        }
        if (risingCircleLength) {
          angleLength = 4 +
              266 *
                  accelerate(currentProgressTime /
                      widget.risingDuration.inMilliseconds);
        } else {
          angleLength = 4 -
              270 *
                  (1.0 -
                      Curves.decelerate.transform(currentProgressTime /
                          widget.risingDuration.inMilliseconds));
        }
        if (currentProgressTime == widget.risingDuration.inMilliseconds) {
          if (risingCircleLength) {
            startAngle += 270;
            angleLength = -266;
          }
          risingCircleLength = !risingCircleLength;
          currentProgressTime = 0;
        }
      });
  }

  @override
  void initState() {
    super.initState();
    update();
    if (widget.value == null) {
      controller.addListener(calculate);
      controller.repeat();
    } else {
      startAngle = -90;
      angleLength = widget.value!.clamp(0, 1) * 360;
    }
  }

  @override
  void didUpdateWidget(covariant ProgressCircularIndicator oldWidget) {
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
      painter: _ProgressCircularPainter(
        startAngle: startAngle,
        angleLength: angleLength,
        padding: widget.padding,
        color: widget.color,
        strokeWidth: widget.strokeWidth,
        strokeCap: widget.strokeCap,
        backgroundColor: widget.backgroundColor,
        backgroundWidth: widget.backgroundWidth,
      ),
    );
  }
}

class _ProgressCircularPainter extends BasePainter {
  final int startAngle;
  final double angleLength;
  final double strokeWidth;
  final StrokeCap strokeCap;
  final Color? backgroundColor;
  final double backgroundWidth;
  final painter = Paint();
  final Color color;

  _ProgressCircularPainter({
    super.padding,
    required this.color,
    required this.startAngle,
    required this.angleLength,
    required this.strokeWidth,
    required this.strokeCap,
    required this.backgroundColor,
    required this.backgroundWidth,
  }) {
    painter.style = PaintingStyle.stroke;
    painter.strokeCap = strokeCap;
    painter.color = color;
  }

  @override
  void draw(Canvas canvas, double width, double height) {
    final x = width / 2;
    final y = height / 2;
    canvas.translate(x, y);
    final rect = Rect.fromLTRB(-x, -y, x, y);
    final start = startAngle * 3.14 / 180;
    final length = angleLength * 3.14 / 180;
    if (backgroundColor != null) {
      painter.color = backgroundColor!;
      painter.strokeWidth = backgroundWidth;
      canvas.drawCircle(Offset.zero, x, painter);
    }
    painter.color = color;
    painter.strokeWidth = strokeWidth;
    canvas.drawArc(rect, start, length, false, painter);
  }

  @override
  bool shouldRepaint(covariant _ProgressCircularPainter oldDelegate) {
    return startAngle != oldDelegate.startAngle ||
        color != oldDelegate.color ||
        angleLength != oldDelegate.angleLength ||
        strokeWidth != oldDelegate.strokeWidth ||
        strokeCap != oldDelegate.strokeCap ||
        backgroundWidth != oldDelegate.backgroundWidth ||
        backgroundColor != oldDelegate.backgroundColor ||
        super.shouldRepaint(oldDelegate);
  }
}
