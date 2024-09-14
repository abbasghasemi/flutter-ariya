import 'package:ariya/ariya.dart';
import 'package:flutter/material.dart';

/// Notifies the completion of the effect
typedef ConfettiCallback = void Function();

/// Confetti effect
class EffectConfetti extends StatefulWidget {
  /// If the value is not set, the effect will be executed automatically
  /// see [ConfettiController]
  final ConfettiController? controller;

  /// see [ConfettiCallback]
  final ConfettiCallback? onStop;

  /// Confetti colors
  final List<Color> colors;

  /// Confetti count
  final double count;

  /// Confetti falling count
  /// The count of falls to the count is added to the form of falling
  final double fallingCount;

  /// Widget size
  final Size size;

  /// The widget below this widget in the tree
  final Widget? child;

  /// If is true, the effect is displayed in child's background
  final bool showInBackground;

  /// Default constructor
  const EffectConfetti({
    super.key,
    this.controller,
    this.onStop,
    this.colors = const [
      Colors.blueAccent,
      Colors.purple,
      Colors.yellow,
      Colors.red,
      Colors.green
    ],
    this.fallingCount = 20,
    this.count = 50,
    this.size = Size.infinite,
    this.child,
    this.showInBackground = false,
  }) : assert(colors.length > 1 && fallingCount >= 0 && count > 0);

  @override
  State<EffectConfetti> createState() => _EffectConfettiState();
}

/// Confetti controller
class ConfettiController {
  bool _running = false;

  /// Effect status
  bool get running => _running;

  /// Starting the effect
  /// return true if started
  bool start() {
    if (_running || _callback == null) return false;
    _running = true;
    _callback!.call();
    return true;
  }

  ConfettiCallback? _callback;
}

class _EffectConfettiState extends State<EffectConfetti>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final paint = Paint()..isAntiAlias = true;

  List<_Particle> particles = [];
  bool startedFall = false;
  int fallingDownCount = 0;
  double speedCoefficient = 1.0;
  bool requireUpdate = false;
  int lastAnimationTime = 0;
  Size size = Size.zero;

  void resolveSize() {
    try {
      size = context.size!;
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..addListener(updateParticles);
    if (widget.controller == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        start();
      });
    } else {
      widget.controller!._callback = start;
    }
  }

  @override
  void didUpdateWidget(covariant EffectConfetti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && widget.controller!._callback == null) {
      widget.controller!._callback = start;
    }
  }

  @override
  Widget build(BuildContext context) {
    final painter = _ConfettiPainter(
      requireUpdate: requireUpdate,
      particles: particles,
      painter: paint,
    );
    return CustomPaint(
      size: widget.size,
      painter: widget.showInBackground ? painter : null,
      foregroundPainter: widget.showInBackground ? null : painter,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool updateSize() {
    resolveSize();
    if (size.width < 11 || size.height == 0) {
      return false;
    }
    return true;
  }

  // The Confetti logic is a port of the logic in the following file:
  // https://github.com/DrKLO/Telegram/blob/master/TMessagesProj/src/main/java/org/telegram/ui/Components/FireworksOverlay.java
  // Sections of the original logic of edited
  // As of September 2023.
  void updateParticles() {
    if (!context.mounted) return;
    updateSize();
    setState(() {
      requireUpdate != requireUpdate;
      int newTime = DateTime.now().millisecondsSinceEpoch;
      int dt = newTime - lastAnimationTime;
      lastAnimationTime = newTime;
      if (dt > 16) dt = 16;
      for (int i = particles.length - 1; i > -1; i--) {
        if (particles[i].update(this, dt)) particles.removeAt(i);
      }
      if (fallingDownCount >= widget.count / 2 && speedCoefficient > 0.2) {
        startFall();
        speedCoefficient -= dt / 16.0 * 0.15;
        if (speedCoefficient < 0.2) {
          speedCoefficient = 0.2;
        }
      }
      if (particles.isEmpty) {
        controller.stop();
        widget.controller?._running = false;
        widget.onStop?.call();
      }
    });
  }

  void start() {
    if (updateSize()) {
      startedFall = false;
      particles.clear();
      fallingDownCount = 0;
      speedCoefficient = 1.0;
      for (int i = 0; i < widget.count; i++) {
        particles.add(createParticle(false));
      }
      controller.repeat();
    }
  }

  void startFall() {
    if (startedFall) return;
    startedFall = true;
    for (int i = 0; i < widget.fallingCount; i++) {
      particles.add(createParticle(true));
    }
  }

  _Particle createParticle(bool isFalling) {
    final particle = _Particle();
    particle.type = AriyaUtils.random.nextInt(2);
    particle.color =
        widget.colors[AriyaUtils.random.nextInt(widget.colors.length)];
    particle.side = AriyaUtils.random.nextBool();
    particle.finishedStart = 1 + AriyaUtils.random.nextInt(2);
    particle.velocity = (AriyaUtils.random.nextInt(40) + 50) / 100;
    if (particle.type == 0) {
      particle.size = (4 + AriyaUtils.random.nextDouble() * 2);
    } else {
      particle.size = (4 + AriyaUtils.random.nextDouble() * 4);
      particle.width = AriyaUtils.random.nextDouble() * 2 + 2;
      particle.radius =
          Radius.circular(AriyaUtils.random.nextDouble() * particle.width);
    }
    if (isFalling) {
      particle.y = -AriyaUtils.random.nextDouble() * size.height * 1.2;
      particle.x = 5.0 + AriyaUtils.random.nextInt(size.width.toInt() - 10);
      particle.xFinished = particle.finishedStart;
    } else {
      double xOffset = 4.0 + AriyaUtils.random.nextInt(10);
      double yOffset = size.height / 4;
      if (particle.side) {
        particle.x = -xOffset;
      } else {
        particle.x = size.width + xOffset;
      }
      particle.moveX =
          (particle.side ? 1 : -1) * (1.2 + AriyaUtils.random.nextDouble() * 4);
      particle.moveY = -(4 + AriyaUtils.random.nextDouble() * 4);
      particle.y = yOffset / 2 + AriyaUtils.random.nextInt(yOffset.toInt() * 2);
    }
    return particle;
  }
}

class _Particle {
  late int type;
  late Color color;
  late bool side;
  int xFinished = 0;
  late int finishedStart;

  late double velocity;
  late double width;
  late Radius radius;
  late double size;
  late double x;
  late double y;
  double rotation = 0;
  double moveX = 0;
  double moveY = 0;

  bool update(_EffectConfettiState state, int dt) {
    double move = dt / 16.0 * velocity;
    x += moveX * move;
    y += moveY * move;
    if (xFinished != 0) {
      double dp = 0.5;
      if (xFinished == 1) {
        moveX += dp * move * 0.05;
        if (moveX >= dp) {
          xFinished = 2;
        }
      } else {
        moveX -= dp * move * 0.05;
        if (moveX <= -dp) {
          xFinished = 1;
        }
      }
    } else {
      if (side) {
        if (moveX > 0) {
          moveX -= move * 0.05;
          if (moveX <= 0) {
            moveX = 0;
            xFinished = finishedStart;
          }
        }
      } else {
        if (moveX < 0) {
          moveX += move * 0.05;
          if (moveX >= 0) {
            moveX = 0;
            xFinished = finishedStart;
          }
        }
      }
    }
    double yEdge = -.5;
    bool wasNegative = moveY < yEdge;
    if (moveY > yEdge) {
      moveY += 1 / 3.0 * move * state.speedCoefficient;
    } else {
      moveY += 1 / 3.0 * move;
    }
    if (wasNegative && moveY > yEdge) {
      state.fallingDownCount++;
    }
    if (type == 1) {
      rotation += move * 0.6 * velocity;
      if (rotation > 360) {
        rotation -= 360;
      }
    }
    return y >= state.size.height;
  }

  void draw(Canvas canvas, Paint paint) {
    paint.color = color;
    if (type == 0) {
      canvas.drawCircle(Offset(x, y), size, paint);
    } else if (type == 1) {
      Rect rect = Rect.fromLTRB(x - size, y - width, x + size, y + width);
      final centerX = (rect.left + rect.right) * 0.5;
      final centerY = (rect.top + rect.bottom) * 0.5;
      canvas.save();
      canvas.translate(centerX, centerY);
      canvas.rotate(rotation);
      canvas.translate(-centerX, -centerY);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);
      canvas.restore();
    }
  }
}

class _ConfettiPainter extends BasePainter {
  final bool requireUpdate;
  final List<_Particle> particles;
  final Paint painter;

  const _ConfettiPainter({
    required this.requireUpdate,
    required this.particles,
    required this.painter,
  });

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return requireUpdate != oldDelegate.requireUpdate ||
        super.shouldRepaint(oldDelegate);
  }

  @override
  void draw(Canvas canvas, double width, double height) {
    for (var particle in particles) {
      particle.draw(canvas, painter);
    }
  }
}
