import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ariya/ariya.dart';

/// Notify the click point [index]
typedef IndicatorClickCallback = void Function(int index);

/// A widget for displaying [PageView] indicator
class PageViewIndicator extends StatelessWidget {
  /// See [PageController]
  /// Automatically updates the indicator or can use [offset]
  final PageController? controller;

  /// If you do not use the [controller], set the current or new page offset
  final double offset;

  /// Count of pages
  final int count;

  /// Unselected indicator color
  final Color indicatorColor;

  /// Selected indicator color
  final Color indicatorSelectedColor;

  /// Space between each indicator
  final double indicatorSpace;

  /// Indicator size
  final double indicatorSize;

  /// Indicator radius
  final Radius indicatorRadius;

  /// Indicator style
  final PaintingStyle indicatorStyle;

  /// Indicator stroke width
  final double indicatorStrokeWidth;

  /// If true, to the smooth mode the state changes the indicator
  final bool indicatorSmooth;

  /// Widget size
  /// If the height is greater than the width, it changes to the vertical state or
  /// If the width is greater than the height, it changes to the horizontal state
  final Size size;

  /// See [IndicatorClickCallback]
  final IndicatorClickCallback? onClick;

  /// Default constructor
  const PageViewIndicator({
    super.key,
    this.controller,
    this.offset = 0,
    required this.count,
    this.indicatorColor = Colors.grey,
    this.indicatorSelectedColor = Colors.blue,
    this.indicatorSpace = 12,
    this.indicatorSize = 12,
    this.indicatorRadius = const Radius.circular(6),
    this.indicatorStyle = PaintingStyle.fill,
    this.indicatorStrokeWidth = 1,
    this.indicatorSmooth = true,
    this.size = Size.zero,
    this.onClick,
  }) : assert(count > 0 && count >= offset);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        final d = size.width >= size.height
            ? details.localPosition.dx
            : details.localPosition.dy;

        double indicatorWidth =
            (count - 1) * indicatorSpace + count * indicatorSize;
        double startX = (max(size.width, size.height) - indicatorWidth) / 2;

        for (int i = 0; i < count; i++) {
          double s =
              startX + i * (indicatorSize + indicatorSpace) + indicatorSize;
          if (d < s) {
            if (_pageOffset.toInt() != i) {
              onClick?.call(i);
            }
            break;
          }
        }
      },
      child: controller != null
          ? AnimatedBuilder(
              animation: controller!,
              builder: (context, w) {
                return CustomPaint(
                  size: size,
                  painter: _IndicatorPainter(
                    count: count,
                    color: indicatorColor,
                    selectedColor: indicatorSelectedColor,
                    spacing: indicatorSpace,
                    dotSize: indicatorSize,
                    radius: indicatorRadius,
                    style: indicatorStyle,
                    strokeWidth: indicatorStrokeWidth,
                    smooth: indicatorSmooth,
                    offset: _pageOffset,
                  ),
                );
              })
          : CustomPaint(
              size: size,
              painter: _IndicatorPainter(
                count: count,
                color: indicatorColor,
                selectedColor: indicatorSelectedColor,
                spacing: indicatorSpace,
                dotSize: indicatorSize,
                radius: indicatorRadius,
                style: indicatorStyle,
                strokeWidth: indicatorStrokeWidth,
                smooth: indicatorSmooth,
                offset: offset,
              ),
            ),
    );
  }

  double get _pageOffset {
    final controller = this.controller as PageController;
    if (controller.hasClients &&
        controller.position.hasPixels &&
        controller.position.hasContentDimensions) {
      return controller.page!;
    }
    return 0;
  }
}

class _IndicatorPainter extends BasePainter {
  final int count;
  final Color color;
  final Color selectedColor;
  final double spacing;
  final double dotSize;
  final Radius radius;
  final PaintingStyle style;
  final double strokeWidth;
  final bool smooth;
  final double offset;

  _IndicatorPainter({
    required this.count,
    required this.color,
    required this.selectedColor,
    required this.spacing,
    required this.dotSize,
    required this.radius,
    required this.style,
    required this.strokeWidth,
    required this.smooth,
    required this.offset,
  });

  @override
  void draw(Canvas canvas, double width, double height) {
    final horizontal = width >= height;

    double indicatorWidth = (count - 1) * spacing + count * dotSize;
    double startX = (max(width, height) - indicatorWidth) / 2;

    Paint paint = Paint()
      ..style = style
      ..strokeWidth = strokeWidth
      ..color = color;

    for (int i = 0; i < count; i++) {
      double x = startX + i * (dotSize + spacing);
      RRect rRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(horizontal ? x : 0, horizontal ? 0 : x, dotSize, dotSize),
        radius,
      );
      canvas.drawRRect(rRect, paint);
    }

    final currentPage = this.offset.floorToDouble();
    final double offset;
    final bool crossingMiddle;
    if (smooth) {
      final forward = this.offset - currentPage;
      crossingMiddle = forward >= 0.5;
      offset = crossingMiddle ? (1 - forward) * 2 : forward * 2;
    } else {
      crossingMiddle = false;
      offset = this.offset - currentPage;
    }

    paint.color = selectedColor;

    if (smooth) {
      double currentStart = startX +
          (crossingMiddle ? currentPage - 1 : currentPage) *
              (dotSize + spacing);
      final double currentEnd;
      if (crossingMiddle) {
        currentStart += 2 * dotSize + (1 - offset) * (dotSize + spacing);
        currentEnd = dotSize + offset * (dotSize + spacing);
      } else {
        currentEnd = dotSize + offset * (dotSize + spacing);
      }
      RRect currentRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          horizontal ? currentStart : 0,
          horizontal ? 0 : currentStart,
          horizontal ? currentEnd : dotSize,
          horizontal ? dotSize : currentEnd,
        ),
        radius,
      );
      canvas.drawRRect(currentRect, paint);
    } else {
      double currentX = startX + (currentPage + offset) * (dotSize + spacing);
      RRect currentRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(horizontal ? currentX : 0, horizontal ? 0 : currentX,
            dotSize, dotSize),
        radius,
      );
      canvas.drawRRect(currentRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _IndicatorPainter oldDelegate) {
    return count != oldDelegate.count ||
        color != oldDelegate.color ||
        selectedColor != oldDelegate.selectedColor ||
        spacing != oldDelegate.spacing ||
        dotSize != oldDelegate.dotSize ||
        radius != oldDelegate.radius ||
        style != oldDelegate.style ||
        strokeWidth != oldDelegate.strokeWidth ||
        smooth != oldDelegate.smooth ||
        offset != oldDelegate.offset ||
        super.shouldRepaint(oldDelegate);
  }
}
