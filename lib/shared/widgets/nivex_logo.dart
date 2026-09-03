import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';

class NivexLogo extends StatelessWidget {
  const NivexLogo({super.key, this.height = 24, this.isLight = false});

  final double height;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final markColor = isLight ? Colors.white : theme.primary;
    final textColor = isLight ? Colors.white : theme.textPrimary;
    return Semantics(
      label: 'NIVEX',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomPaint(
            size: Size(height * 0.95, height),
            painter: _NivexMarkPainter(color: markColor),
          ),
          SizedBox(width: height * 0.35),
          Text(
            'NIVEX',
            style: TextStyle(
              color: textColor,
              fontSize: height * 0.85,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _NivexMarkPainter extends CustomPainter {
  const _NivexMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final strokeWidth = w * 0.24;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(strokeWidth / 2, h - strokeWidth / 2)
      ..lineTo(strokeWidth / 2, strokeWidth / 2)
      ..lineTo(w - strokeWidth / 2, h - strokeWidth / 2)
      ..lineTo(w - strokeWidth / 2, strokeWidth / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NivexMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
