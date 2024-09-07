import 'package:flutter/material.dart';
import 'package:ariya/ariya.dart';

/// Report the value changes
/// Ignore the first when interval is false
/// Tip:
/// Do not need to update the widget after receiving it
typedef SeekBarChangeListener = Function(double first, double last);

/// A widget to select the value in a limited interval
class SeekBar extends StatefulWidget {
  /// See [SeekBarController]
  final SeekBarController controller;

  /// See [SeekBarChangeListener]
  final SeekBarChangeListener? onChange;

  /// Seekbar background radius
  final Radius radius;

  /// Seekbar background width
  final double? width;

  /// Seekbar background height
  final double height;

  /// Seekbar background color
  final Color background;

  /// Seekbar color
  final Color color;

  /// If true, the user can change seekbar value
  final bool userFeedback;

  /// If true, the first and last value can be changed
  /// If false, only the last value can be changed
  final bool interval;

  /// Thump radius
  final Radius thumpRadius;

  /// Thump color
  final Color thumpColor;

  /// Thump size
  /// If 0, is not displayed
  final double thumpSize;

  /// Thump selected size
  final double thumpSelectedSize;

  /// Padding of the widget
  final EdgeInsets padding;

  /// Default constructor
  const SeekBar({
    super.key,
    required this.controller,
    this.onChange,
    this.radius = Radius.zero,
    this.width,
    this.height = 30,
    this.background = Colors.grey,
    this.color = Colors.blue,
    this.userFeedback = true,
    this.interval = false,
    this.thumpRadius = const Radius.circular(10),
    this.thumpColor = Colors.blue,
    this.thumpSize = 20,
    this.thumpSelectedSize = 25,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
  });

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> with TickerProviderStateMixin {
  AnimationController? _controller;
  late AnimationController _controller2;
  Animation<double>? anim;

  void _update() {
    widget.controller._interval = widget.interval;
    widget.controller._radius = widget.radius;
    widget.controller._background = widget.background;
    widget.controller._color = widget.color;
    widget.controller._thumpRadius = widget.thumpRadius;
    widget.controller._thumpColor = widget.thumpColor;
    widget.controller._thumpSize = widget.thumpSize;
    widget.controller._thumpSelectedSize = widget.thumpSelectedSize;
    widget.controller._intervalAnimateListener = (f, l) {
      _controller ??= AnimationController(vsync: this);
      _controller!.duration = widget.controller._animationDuration;
      if (f != widget.controller.first) {
        final anim = Tween<double>(begin: widget.controller.first, end: f)
            .animate(CurvedAnimation(
                parent: _controller!,
                curve: widget.controller._animationCurve!));
        anim.addListener(() {
          widget.controller.first = anim.value;
          widget.onChange
              ?.call(widget.controller.first, widget.controller.last);
        });
      }
      if (l != widget.controller.last) {
        final anim2 = Tween<double>(begin: widget.controller.last, end: l)
            .animate(CurvedAnimation(
                parent: _controller!,
                curve: widget.controller._animationCurve!));
        anim2.addListener(() {
          widget.controller.last = anim2.value;
          widget.onChange
              ?.call(widget.controller.first, widget.controller.last);
        });
      }
      _controller!.reset();
      _controller!.forward();
    };
  }

  @override
  void initState() {
    super.initState();

    _update();

    _controller2 = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant SeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _update();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller2.dispose();
    super.dispose();
  }

  void dragEnd() {
    if (!mounted) return;
    if (_controller2.isAnimating) {
      _controller2.stop();
    }
    anim = Tween<double>(begin: anim!.value, end: 0.0).animate(
      CurvedAnimation(
          parent: _controller2, curve: CubicInterpolator.easeOutBack),
    );
    anim!.addListener(() {
      if (!mounted) return;
      widget.controller._thumpProgress = anim!.value;
      widget.controller._update();
    });
    _controller2.reset();
    _controller2.forward();
  }

  @override
  Widget build(BuildContext context) {
    return widget.userFeedback
        ? MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onHorizontalDragDown: (details) {
                if (_controller?.status == AnimationStatus.forward) {
                  _controller?.stop();
                }
                if (!mounted) return;
                final value = widget.controller._progress2value(
                    widget.controller._dx2progress(details.localPosition.dx));
                widget.controller._lastSelected = !widget
                        .controller._interval ||
                    value >= widget.controller.last ||
                    value >=
                        widget.controller.last -
                            (widget.controller.last - widget.controller.first) /
                                2;
                widget.controller._lastSelected
                    ? widget.controller.last = value
                    : widget.controller.first = value;
                widget.onChange
                    ?.call(widget.controller.first, widget.controller.last);
                if (_controller2.isAnimating) {
                  _controller2.stop();
                }
                anim =
                    Tween<double>(begin: anim?.value ?? 0.0, end: 1.0).animate(
                  CurvedAnimation(
                      parent: _controller2,
                      curve: CubicInterpolator.easeOutBack),
                );
                anim!.addListener(() {
                  if (!mounted) return;
                  widget.controller._thumpProgress = anim!.value;
                  widget.controller._update();
                });
                _controller2.reset();
                _controller2.forward();
              },
              onHorizontalDragUpdate: (details) {
                if (!mounted) return;
                final value = widget.controller._progress2value(
                    widget.controller._dx2progress(details.localPosition.dx));
                final lastSelected = widget.controller._lastSelected;
                widget.controller._lastSelected =
                    !widget.controller._interval ||
                        lastSelected && value >= widget.controller.first ||
                        !(!lastSelected && value <= widget.controller.last) &&
                            value >= widget.controller.first;
                if (lastSelected != widget.controller._lastSelected) {
                  (tmp) {
                    widget.controller._last = widget.controller.first;
                    widget.controller._first = tmp;
                  }(widget.controller.last);
                }
                widget.controller._lastSelected
                    ? widget.controller.last = value
                    : widget.controller.first = value;
                widget.onChange
                    ?.call(widget.controller.first, widget.controller.last);
              },
              onHorizontalDragCancel: dragEnd,
              onHorizontalDragEnd: (details) {
                dragEnd();
              },
              child: CustomPaint(
                size: Size(widget.width ?? double.infinity, widget.height),
                painter: _SeekBarPainter(
                  padding: widget.padding,
                  controller: widget.controller,
                ),
              ),
            ),
          )
        : CustomPaint(
            size: Size(widget.width ?? double.infinity, widget.height),
            painter: _SeekBarPainter(
              padding: widget.padding,
              controller: widget.controller,
            ),
          );
  }
}

/// Seekbar controller
/// see [animateProgress], [first], [last]
class SeekBarController extends ChangeNotifier {
  final double _min;
  final double _max;
  double _first;
  double _last;

  late Radius _radius;
  late Color _background;
  late Color _color;
  late bool _interval;
  late Radius _thumpRadius;
  late Color _thumpColor;
  late double _thumpSize;
  late double _thumpSelectedSize;
  bool _lastSelected = true;
  double _thumpProgress = 0;

  SeekBarChangeListener? _intervalAnimateListener;
  Duration? _animationDuration;
  Curve? _animationCurve;

  late Size _size;

  /// [min] Minimum value
  /// [max] Maximum value
  /// [first] The initial first value
  /// [last] The initial last value
  SeekBarController({
    required double min,
    required double max,
    required double first,
    required double last,
  })  : _min = min,
        _max = max,
        _first = first,
        _last = last,
        assert(max > min && last >= first && first >= min && max >= last);

  /// Minimum value
  double get min => _min;

  /// Maximum value
  double get max => _max;

  /// Selected first value
  double get first => _first;

  /// Selected last value
  double get last => _last;

  /// change first value
  set first(double first) {
    assert(min <= first && max >= first,
        "min: $min, max: $max, but first is $first.");
    if (last < first) {
      _first = last;
      last = first;
    } else {
      _first = first;
      notifyListeners();
    }
  }

  /// change last value
  set last(double last) {
    assert(
        max >= last && min <= last, "min: $min, max: $max, but last is $last.");
    if (last < first) {
      _last = first;
      first = last;
    } else {
      _last = last;
      notifyListeners();
    }
  }

  /// change first and last value by animation
  /// [first] new first value
  /// [last] new last value
  /// [duration] animation duration
  /// [curve] animation curve
  /// see [Curves]
  void animateProgress({
    double? first,
    double? last,
    required Duration duration,
    Curve curve = Curves.easeInOut,
  }) {
    first ??= _first;
    last ??= _last;
    if (first == _first && last == _last) return;
    assert(first >= min && max >= last,
        "min: $min, max: $max, but first is $first and last is $last.");
    if (last < first) {
      (t) {
        first = last;
        last = t;
      }(first);
    }
    _animationDuration = duration;
    _animationCurve = curve;
    _intervalAnimateListener?.call(first!, last!);
  }

  /// convert [progress] to value
  double _progress2value(double progress) {
    return progress * (max - min) + min;
  }

  /// convert [value] to progress
  /// value must be between [min] and [max]
  double _value2progress(double value) {
    return (value - min) / (max - min);
  }

  /// convert [px] to progress
  /// progress between 0 and 1
  double _dx2progress(double dx) {
    dx = dx.clamp(0, _size.width);
    return dx / _size.width;
  }

  /// update seekbar
  void _update() {
    notifyListeners();
  }

  @override
  String toString() {
    return "SeekBarController(min: $min, max: $max, first: $first, last: $last)";
  }
}

class _SeekBarPainter extends BasePainter {
  final SeekBarController controller;
  final Paint painter = Paint()..style = PaintingStyle.fill;

  _SeekBarPainter({
    super.padding,
    required this.controller,
  });

  @override
  void draw(Canvas canvas, double width, double height) {
    controller._size = Size(width, height);
    painter.color = controller._background;

    canvas.save();
    if (controller._radius != Radius.zero) {
      canvas.clipRRect(RRect.fromRectAndRadius(
          Offset.zero & controller._size, controller._radius));
    }
    canvas.drawRect(Offset.zero & controller._size, painter);

    painter.color = controller._color;
    final begin = controller._interval
        ? width * controller._value2progress(controller._first)
        : 0.0;
    canvas.drawRect(
        Rect.fromLTWH(
            begin,
            0,
            width * controller._value2progress(controller._last) - begin,
            height),
        painter);
    canvas.restore();

    if (controller._thumpSize > 0) {
      for (int i = 0; i < 2; i++) {
        if (i == 1 && !controller._interval) break;
        final progress = controller
            ._value2progress(i == 0 ? controller.last : controller.first);
        final selected = controller._lastSelected && i == 0 ||
            !controller._lastSelected && i == 1;
        final start = width * progress;
        if (selected && controller._thumpProgress != 0) {
          final thumpSelectedWidth = controller._thumpSize +
              ((controller._thumpSelectedSize - controller._thumpSize) *
                  controller._thumpProgress);
          final p = 1 +
              (thumpSelectedWidth - controller._thumpSize) /
                  controller._thumpSize;
          final thumpRadius = controller._thumpRadius * p;
          if (controller._thumpProgress > 0) {
            painter.color = controller._thumpColor
                .withOpacity(0.1 * controller._thumpProgress);
            final thump2Width = thumpSelectedWidth * 1.5;
            final rect = Rect.fromLTWH(start - thump2Width / 2,
                height / 2 - thump2Width / 2, thump2Width, thump2Width);
            canvas.drawRRect(
                RRect.fromRectAndRadius(rect, thumpRadius * 1.5), painter);
          }
          painter.color = controller._thumpColor;
          final rect = Rect.fromLTWH(
              start - thumpSelectedWidth / 2,
              height / 2 - thumpSelectedWidth / 2,
              thumpSelectedWidth,
              thumpSelectedWidth);
          canvas.drawRRect(RRect.fromRectAndRadius(rect, thumpRadius), painter);
        } else {
          painter.color = controller._thumpColor;
          final rect = Rect.fromLTWH(
              start - controller._thumpSize / 2,
              height / 2 - controller._thumpSize / 2,
              controller._thumpSize,
              controller._thumpSize);
          canvas.drawRRect(
              RRect.fromRectAndRadius(rect, controller._thumpRadius), painter);
        }
      }
    }
  }
}
