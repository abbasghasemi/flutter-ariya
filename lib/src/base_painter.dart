import 'dart:math';

import 'package:flutter/cupertino.dart';

/// Base [CustomPainter] for this project
abstract class BasePainter extends CustomPainter {
  /// The padding of the widget
  final EdgeInsets? padding;

  /// Default constructor
  const BasePainter({
    this.padding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (padding != null && padding != EdgeInsets.zero) {
      canvas.translate(padding!.left, padding!.top);
      size = Size(
        max(0, size.width - padding!.horizontal),
        max(0, size.height - padding!.vertical),
      );
    }
    if (size != Size.zero) draw(canvas, size.width, size.height);
  }

  /// Like paint
  /// Possibly this method would make better use
  void draw(Canvas canvas, double width, double height);

  @override
  @mustCallSuper
  bool shouldRepaint(covariant BasePainter oldDelegate) {
    return padding != oldDelegate.padding;
  }

  /// Creates a [Shader] with gradient
  /// width of widget
  /// height of widget
  Shader createShader(Gradient gradient, double width, double height) {
    return gradient.createShader(
      Rect.fromCircle(
        center: Offset(width / 2, height / 2),
        radius: width / 2,
      ),
    );
  }
}
