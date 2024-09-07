import 'dart:math';

import 'package:flutter/animation.dart';

/// The value finally returns to begin value and delays between two elements
class CircleTween extends Tween<double> {
  /// [Tween]
  /// Default constructor
  CircleTween({super.begin, super.end, required this.offset});

  /// Specifies the delay
  final double offset;

  @override
  double lerp(double t) => super.lerp((sin((t - offset) * 2 * pi) + 1) / 2);

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}
