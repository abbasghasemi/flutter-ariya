import 'dart:math';

import 'package:ariya/ariya.dart';
import 'package:flutter/material.dart';

/// Fireworks effect
class EffectFireworks extends StatefulWidget {
  /// Fireworks glory colors
  final List<Color> colors;

  /// Fireworks glory width
  final double width;

  /// Glory count per fireworks
  final double gloryCount;

  /// Fireworks count
  final double count;

  /// Widget size
  final Size size;

  /// The widget below this widget in the tree
  final Widget? child;

  /// If is true, the effect is displayed in child's background
  final bool showInBackground;

  /// Default constructor
  const EffectFireworks({
    super.key,
    this.colors = const [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.yellow,
      Colors.orange
    ],
    this.width = 1.5,
    this.gloryCount = 8,
    this.count = 38,
    this.size = Size.infinite,
    this.child,
    this.showInBackground = false,
  }) : assert(colors.length > 1 && width > 0 && gloryCount > 4 && count > 0);

  @override
  State<EffectFireworks> createState() => _EffectFireworksState();
}

class _EffectFireworksState extends State<EffectFireworks>
    with SingleTickerProviderStateMixin {
  final List<_Particle> particles = [];
  final List<_Particle> freeParticles = [];
  late final AnimationController controller;
  final double angleDiff = (pi / 180) * 60;
  final Paint paint = Paint()
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  int lastAnimationTime = DateTime.now().millisecondsSinceEpoch;
  bool requireUpdate = false;
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
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    controller.addListener(() {
      if (!context.mounted) return;
      resolveSize();
      if (size.width == 0 || size.height == 0) {
        return;
      }
      animate();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.repeat());
  }

  @override
  Widget build(BuildContext context) {
    final painter = _FireworksPainter(
      particles: particles,
      requireUpdate: requireUpdate,
      width: widget.width,
      painter: paint,
    );
    return CustomPaint(
      size: widget.size,
      painter: widget.showInBackground ? painter : null,
      foregroundPainter: widget.showInBackground ? null : painter,
      child: widget.child,
    );
  }

  // The Fireworks logic is a port of the logic in the following file:
  // https://github.com/DrKLO/Telegram/blob/master/TMessagesProj/src/main/java/org/telegram/ui/Components/FireworksEffect.java
  // As of September 2023.
  void animate() {
    int newTime = DateTime.now().millisecondsSinceEpoch;
    int dt = min(17, newTime - lastAnimationTime);
    updateParticles(dt);
    lastAnimationTime = newTime;
    if (AriyaUtils.random.nextBool() &&
        particles.length + widget.gloryCount <
            widget.count * widget.gloryCount) {
      final double cx = AriyaUtils.random.nextDouble() * size.width;
      final double cy = AriyaUtils.random.nextDouble() * (size.height - 20);
      final Color color =
          widget.colors[AriyaUtils.random.nextInt(widget.colors.length)];
      for (int a = 0; a < widget.gloryCount; a++) {
        int angle = AriyaUtils.random.nextInt(270) - 225;
        double vx = cos(pi / 180.0 * angle);
        double vy = sin(pi / 180.0 * angle);
        _Particle newParticle;

        if (freeParticles.isNotEmpty) {
          newParticle = freeParticles.removeAt(0);
        } else {
          newParticle = _Particle();
        }

        newParticle
          ..x = cx
          ..y = cy
          ..vx = vx * widget.width
          ..vy = vy
          ..color = color
          ..alpha = 1.0
          ..currentTime = 0
          ..scale = max(1.0, AriyaUtils.random.nextDouble() * widget.width)
          ..lifeTime = 1000 + AriyaUtils.random.nextInt(1000)
          ..velocity = 20.0 + AriyaUtils.random.nextDouble() * 4.0;

        particles.add(newParticle);
      }
    }
    setState(() {
      requireUpdate = !requireUpdate;
    });
  }

  void updateParticles(int dt) {
    for (int i = particles.length - 1; i >= 0; i--) {
      _Particle particle = particles[i];
      if (particle.currentTime >= particle.lifeTime) {
        freeParticles.add(particle);
        particles.removeAt(i);
        continue;
      }
      particle.alpha = 1.0 - (particle.currentTime / particle.lifeTime);
      final dSpeed = 1000;
      particle.x += particle.vx * particle.velocity * dt / dSpeed;
      particle.y += particle.vy * particle.velocity * dt / dSpeed;
      particle.vy += dt / 100.0;
      particle.currentTime += dt;
    }
  }
}

class _FireworksPainter extends BasePainter {
  final bool requireUpdate;
  final List<_Particle> particles;
  final double width;
  final Paint painter;

  const _FireworksPainter({
    required this.requireUpdate,
    required this.particles,
    required this.width,
    required this.painter,
  });

  @override
  void draw(Canvas canvas, double width, double height) {
    for (var particle in particles) {
      painter.color = particle.color.withAlpha((255 * particle.alpha).toInt());
      painter.strokeWidth = (this.width * particle.scale);
      canvas.drawCircle(
          Offset(particle.x, particle.y), painter.strokeWidth / 2, painter);
    }
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter oldDelegate) {
    return requireUpdate != oldDelegate.requireUpdate ||
        super.shouldRepaint(oldDelegate);
  }
}

class _Particle {
  late double x;
  late double y;
  late double vx;
  late double vy;
  late double velocity;
  late double alpha;

  late int lifeTime;

  late double currentTime;
  late double scale;

  late Color color;
}
