import 'package:flutter/material.dart';

/// A linear widget
class ProgressLinearIndicator extends StatefulWidget {
  /// If the value is set, it moves as an animation
  final double? fromProgress;

  /// Progress must be between 0 and 1
  final double progress;

  /// Linear radius
  final Radius radius;

  /// Linear width
  /// If the width is greater than the height, it changes to the horizontal state
  final double? width;

  /// Linear height
  /// If the height is greater than the width, it changes to the vertical state
  final double height;

  ///  Linear background color
  final Color background;

  ///  Linear progress color
  final Color color;

  ///  Linear background gradient
  final Gradient? backgroundGradient;

  ///  Linear progress gradient
  final Gradient? gradient;

  /// Default constructor
  const ProgressLinearIndicator({
    super.key,
    this.fromProgress,
    this.progress = .3,
    this.radius = Radius.zero,
    this.width,
    this.height = 10,
    this.background = Colors.grey,
    this.color = Colors.blue,
    this.backgroundGradient,
    this.gradient,
  })  : assert(fromProgress == null || progress >= fromProgress),
        assert(progress >= 0 && progress <= 1);

  @override
  State<ProgressLinearIndicator> createState() =>
      _ProgressLinearIndicatorState();
}

class _ProgressLinearIndicatorState extends State<ProgressLinearIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController? _controller;

  @override
  void initState() {
    if (widget.fromProgress != null && widget.fromProgress != widget.progress) {
      _controller = AnimationController(
        duration: Duration(milliseconds: 500),
        lowerBound: widget.fromProgress!,
        upperBound: widget.progress,
        vsync: this,
      );
      _controller!.addListener(() => setState(() {}));
      _controller!.forward();
    } else {
      _controller = null;
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.width ?? double.infinity, widget.height),
      painter: _ProgressLinearPainter(
        progress: _controller?.value ?? widget.progress,
        background: widget.background,
        color: widget.color,
        radius: widget.radius,
        backgroundGradient: widget.backgroundGradient,
        gradient: widget.gradient,
      ),
    );
  }
}

class _ProgressLinearPainter extends CustomPainter {
  final double progress;
  final Radius radius;
  final Color background;
  final Color color;
  final Gradient? backgroundGradient;
  final Gradient? gradient;
  final Paint backPaint = Paint()..style = PaintingStyle.fill;
  final Paint progressPaint = Paint()..style = PaintingStyle.fill;

  _ProgressLinearPainter({
    required this.progress,
    required this.radius,
    required this.background,
    required this.color,
    this.backgroundGradient,
    this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (radius != Radius.zero) {
      canvas.clipRRect(RRect.fromRectAndRadius(Offset.zero & size, radius));
    }
    if (backgroundGradient != null) {
      backPaint.shader = backgroundGradient!.createShader(
        Rect.fromLTRB(0, 0, size.width, size.height),
      );
    } else {
      backPaint.color = background;
    }
    canvas.drawRect(Offset.zero & size, backPaint);
    if (gradient != null) {
      progressPaint.shader = gradient!.createShader(
        Rect.fromLTRB(0, 0, size.width, size.height),
      );
    } else {
      progressPaint.color = color;
    }
    final horizontal = size.width >= size.height;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width * (horizontal ? progress : 1),
            size.height * (horizontal ? 1 : progress)),
        progressPaint);
  }

  @override
  bool shouldRepaint(_ProgressLinearPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        radius != oldDelegate.radius ||
        background != oldDelegate.background ||
        color != oldDelegate.color ||
        gradient != oldDelegate.gradient ||
        backgroundGradient != oldDelegate.backgroundGradient;
  }
}
