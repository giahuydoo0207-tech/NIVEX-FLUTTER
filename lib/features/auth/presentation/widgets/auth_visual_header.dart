import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/shared/widgets/nivex_logo.dart';

class AuthVisualHeader extends StatelessWidget {
  const AuthVisualHeader({
    required this.subtitle,
    this.height = 200,
    super.key,
  });

  final String subtitle;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Container(
      width: double.infinity,
      height: height,
      color: theme.surfaceSubtle,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                key: const Key('auth-signal-pattern'),
                painter: AuthSignalPainter(
                  primary: theme.primary,
                  secondary: theme.secondary,
                  lineColor: theme.border,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.surface.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.border),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    child: NivexLogo(height: 40),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AuthSignalPainter extends CustomPainter {
  const AuthSignalPainter({
    required this.primary,
    required this.secondary,
    required this.lineColor,
  });

  final Color primary;
  final Color secondary;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.43);
    final railPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.85)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 4; i++) {
      final inset = 18.0 + i * 18.0;
      final rect = Rect.fromLTRB(
        inset,
        18 + i * 9,
        size.width - inset,
        size.height - 18 - i * 9,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        railPaint,
      );
    }

    final nodePaints = [
      Paint()..color = primary.withValues(alpha: 0.9),
      Paint()..color = secondary.withValues(alpha: 0.85),
    ];
    final nodeCenters = <Offset>[
      Offset(size.width * 0.12, size.height * 0.30),
      Offset(size.width * 0.20, size.height * 0.72),
      Offset(size.width * 0.82, size.height * 0.25),
      Offset(size.width * 0.90, size.height * 0.68),
    ];

    for (var i = 0; i < nodeCenters.length; i++) {
      final node = nodeCenters[i];
      final end = Offset.lerp(node, center, 0.62)!;
      canvas.drawLine(node, end, railPaint);
      final side = i.isEven ? 10.0 : 8.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: node, width: side, height: side),
          const Radius.circular(2),
        ),
        nodePaints[i % nodePaints.length],
      );
    }

    final pulsePaint = Paint()
      ..color = primary.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final maxRadius = math.min(size.width, size.height) * 0.22;
    canvas.drawCircle(center, maxRadius, pulsePaint);
    canvas.drawCircle(center, maxRadius * 0.68, pulsePaint);
  }

  @override
  bool shouldRepaint(covariant AuthSignalPainter oldDelegate) {
    return oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.lineColor != lineColor;
  }
}
