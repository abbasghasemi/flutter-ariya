import 'package:ariya/ariya.dart';
import 'package:flutter/material.dart';

/// Shimmer animation direction
enum ShimmerDirection {
  /// Direction of animation from left to right
  leftToRight,

  /// Direction of animation from right to left
  rightToLeft,

  /// Direction of animation from top to bottom
  topToBottom,

  /// Direction of animation from bottom to top
  bottomToTop,
}

/// Shimmer animation delay
enum ShimmerDelay {
  /// Begins immediately after completion
  short,

  /// 1/3 of the specified duration, delay occurs
  medium,

  /// 1/2 of the specified duration, delay occurs
  high,

  /// 3/5 of the specified duration, delay occurs
  veryHigh,
}

/// A widget to show shimmer
class Shimmer extends StatefulWidget {
  /// Run shimmer forever
  static const int infinity = -1;

  /// Shimmer without running
  static const int dismissed = 0;

  //

  /// The widget below this widget in the tree
  final Widget child;

  /// Animation duration
  final Duration duration;

  /// Shimmer gradient
  final Gradient gradient;

  /// See [Shimmer.infinity],[Shimmer.dismissed]
  /// The number of animation loop
  final int loopCount;

  /// See [ShimmerDirection]
  final ShimmerDirection direction;

  /// See [ShimmerDelay]
  final ShimmerDelay delay;

  /// If is true, the effect is displayed as a mask on the widget
  /// Otherwise, covers the entire widget surface
  final bool masked;

  /// If [masked] is false, can use this feature
  /// Adds the radius to the shimmer
  final Radius radius;

  /// Default constructor
  const Shimmer({
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.gradient = const LinearGradient(
      colors: [
        Colors.grey,
        Colors.grey,
        Color(0xFFF5F5F5),
        Colors.grey,
        Colors.grey,
      ],
      begin: Alignment.topLeft,
      stops: [0, 0.33, .5, .67, 1],
    ),
    this.loopCount = infinity,
    this.direction = ShimmerDirection.leftToRight,
    this.delay = ShimmerDelay.short,
    this.masked = true,
    this.radius = Radius.zero,
  }) : assert(radius == Radius.zero || !masked,
            "The `radius` feature is just for the `masked` to be false!");

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  int currentLoop = 0;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      lowerBound: -1,
      upperBound: widget.delay.index + 1,
      duration: widget.duration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (widget.loopCount == -1 || currentLoop < widget.loopCount - 1) {
            controller.reset();
            controller.forward();
            currentLoop++;
          }
        }
      });
    if (widget.loopCount != 0) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.masked ? buildShimmerMask() : buildShimmer();
  }

  Widget buildShimmerMask() {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            Rect rect;
            switch (widget.direction) {
              case ShimmerDirection.leftToRight:
                rect = Rect.fromLTWH(
                  controller.value * bounds.width,
                  0,
                  bounds.width,
                  bounds.height,
                );
                break;
              case ShimmerDirection.rightToLeft:
                rect = Rect.fromLTWH(
                  -controller.value * bounds.width,
                  0,
                  bounds.width,
                  bounds.height,
                );
                break;
              case ShimmerDirection.topToBottom:
                rect = Rect.fromLTWH(
                  0,
                  controller.value * bounds.height,
                  bounds.width,
                  bounds.height,
                );
                break;
              case ShimmerDirection.bottomToTop:
                rect = Rect.fromLTWH(
                  0,
                  -controller.value * bounds.height,
                  bounds.width,
                  bounds.height,
                );
                break;
            }

            return widget.gradient.createShader(rect);
          },
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }

  Widget buildShimmer() {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _ShimmerPainter(
                    value: controller.value,
                    shader: (width, height) {
                      Rect rect;
                      switch (widget.direction) {
                        case ShimmerDirection.leftToRight:
                          rect = Rect.fromLTWH(
                            controller.value * width,
                            0,
                            width / 3,
                            height,
                          );
                          break;
                        case ShimmerDirection.rightToLeft:
                          rect = Rect.fromLTWH(
                            (1 - controller.value) * width,
                            0,
                            width / 3,
                            height,
                          );
                          break;
                        case ShimmerDirection.topToBottom:
                          rect = Rect.fromLTWH(
                            0,
                            controller.value * height,
                            width,
                            height / 3,
                          );
                          break;
                        case ShimmerDirection.bottomToTop:
                          rect = Rect.fromLTWH(
                            0,
                            (1 - controller.value) * height,
                            width,
                            height / 3,
                          );
                          break;
                      }
                      return widget.gradient.createShader(rect);
                    },
                    radius: widget.radius),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ShimmerPainter extends BasePainter {
  final double value;
  final Shader Function(double width, double height) shader;
  final Radius radius;

  const _ShimmerPainter({
    required this.value,
    required this.shader,
    required this.radius,
  });

  @override
  void draw(Canvas canvas, double width, double height) {
    final paint = Paint()..shader = shader(width, height);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTRB(0, 0, width, height), radius),
        paint);
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) =>
      value != oldDelegate.value ||
      radius != oldDelegate.radius ||
      super.shouldRepaint(oldDelegate);
}
