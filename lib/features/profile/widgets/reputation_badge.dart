import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/profile/domain/reputation_tier.dart';

enum ReputationBadgeSize { compact, regular, large }

class ReputationBadge extends StatelessWidget {
  const ReputationBadge({
    required this.tier,
    this.size = ReputationBadgeSize.regular,
    this.showLabel = true,
    super.key,
  });

  final ReputationTier tier;
  final ReputationBadgeSize size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final palette = _BadgePalette.forTier(tier, context.nivexTheme);
    final emblemSize = switch (size) {
      ReputationBadgeSize.compact => 30.0,
      ReputationBadgeSize.regular => 48.0,
      ReputationBadgeSize.large => 72.0,
    };
    final textSize = switch (size) {
      ReputationBadgeSize.compact => 11.0,
      ReputationBadgeSize.regular => 13.0,
      ReputationBadgeSize.large => 15.0,
    };

    return Semantics(
      label: 'Cấp bậc uy tín ${tier.label}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: emblemSize,
            height: emblemSize * 1.1,
            child: CustomPaint(
              painter: _ReputationEmblemPainter(tier: tier, palette: palette),
            ),
          ),
          if (showLabel) ...[
            SizedBox(width: size == ReputationBadgeSize.compact ? 7 : 10),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tier.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.foreground,
                      fontSize: textSize,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (size != ReputationBadgeSize.compact) ...[
                    const SizedBox(height: 2),
                    Text(
                      'REPUTATION TIER',
                      style: TextStyle(
                        color: palette.foreground.withValues(alpha: 0.72),
                        fontSize: textSize - 4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BadgePalette {
  const _BadgePalette({
    required this.foreground,
    required this.background,
    required this.detail,
    required this.leadingBand,
    required this.trailingBand,
    required this.bottomBand,
    required this.core,
  });

  final Color foreground;
  final Color background;
  final Color detail;
  final Color leadingBand;
  final Color trailingBand;
  final Color bottomBand;
  final Color core;

  factory _BadgePalette.forTier(
    ReputationTier tier,
    NivexThemeExtension theme,
  ) {
    return switch (tier) {
      ReputationTier.unranked => _BadgePalette(
        foreground: theme.textSecondary,
        background: theme.surfaceSubtle,
        detail: theme.border,
        leadingBand: const Color(0xFF64748B),
        trailingBand: const Color(0xFF475569),
        bottomBand: const Color(0xFF52627A),
        core: const Color(0xFF64748B),
      ),
      ReputationTier.bronze => const _BadgePalette(
        foreground: Color(0xFFD49765),
        background: Color(0xFF2B1D18),
        detail: Color(0xFF7A4930),
        leadingBand: Color(0xFFE0A271),
        trailingBand: Color(0xFF8B5134),
        bottomBand: Color(0xFFC77B4D),
        core: Color(0xFFD49765),
      ),
      ReputationTier.silver => const _BadgePalette(
        foreground: Color(0xFFC4CDDA),
        background: Color(0xFF18202D),
        detail: Color(0xFF66758B),
        leadingBand: Color(0xFFE2E8F0),
        trailingBand: Color(0xFF78879D),
        bottomBand: Color(0xFFB4C0CF),
        core: Color(0xFF38BDF8),
      ),
      ReputationTier.gold => const _BadgePalette(
        foreground: Color(0xFFF4C95D),
        background: Color(0xFF2A230F),
        detail: Color(0xFFA77B18),
        leadingBand: Color(0xFFFFE08A),
        trailingBand: Color(0xFFB8891D),
        bottomBand: Color(0xFFF4C95D),
        core: Color(0xFFF4C95D),
      ),
      ReputationTier.verifiedExpert => _BadgePalette(
        foreground: theme.primary,
        background: theme.primary.withValues(alpha: 0.12),
        detail: theme.secondary,
        leadingBand: const Color(0xFFF8FAFC),
        trailingBand: const Color(0xFF1E60D5),
        bottomBand: const Color(0xFF38BDF8),
        core: const Color(0xFF38BDF8),
      ),
    };
  }
}

class _ReputationEmblemPainter extends CustomPainter {
  const _ReputationEmblemPainter({required this.tier, required this.palette});

  final ReputationTier tier;
  final _BadgePalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = math.max(1.0, size.width * 0.035);
    final outer = Path()
      ..moveTo(size.width * 0.5, size.height * 0.03)
      ..lineTo(size.width * 0.91, size.height * 0.25)
      ..lineTo(size.width * 0.91, size.height * 0.73)
      ..lineTo(size.width * 0.5, size.height * 0.97)
      ..lineTo(size.width * 0.09, size.height * 0.73)
      ..lineTo(size.width * 0.09, size.height * 0.25)
      ..close();

    canvas.drawPath(outer, Paint()..color = palette.background);
    final framePaint = Paint()
      ..color = palette.foreground
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeJoin = StrokeJoin.miter;
    if (tier == ReputationTier.unranked) {
      _drawDashedPath(canvas, outer, framePaint, size.width * 0.08);
    } else {
      canvas.drawPath(outer, framePaint);
    }

    if (tier == ReputationTier.silver ||
        tier == ReputationTier.gold ||
        tier == ReputationTier.verifiedExpert) {
      final inset = Path()
        ..moveTo(size.width * 0.5, size.height * 0.09)
        ..lineTo(size.width * 0.85, size.height * 0.29)
        ..lineTo(size.width * 0.85, size.height * 0.69)
        ..lineTo(size.width * 0.5, size.height * 0.9)
        ..lineTo(size.width * 0.15, size.height * 0.69)
        ..lineTo(size.width * 0.15, size.height * 0.29)
        ..close();
      canvas.drawPath(
        inset,
        Paint()
          ..color = palette.detail
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke * 0.72,
      );
    }

    _drawReputationMark(canvas, size);
    _drawFrameTerminals(canvas, size);
    if (tier == ReputationTier.verifiedExpert) {
      _drawVerificationNode(canvas, size);
    }
  }

  void _drawReputationMark(Canvas canvas, Size size) {
    final leftBand = Path()
      ..moveTo(size.width * 0.23, size.height * 0.56)
      ..lineTo(size.width * 0.23, size.height * 0.38)
      ..quadraticBezierTo(
        size.width * 0.23,
        size.height * 0.31,
        size.width * 0.3,
        size.height * 0.27,
      )
      ..lineTo(size.width * 0.48, size.height * 0.17)
      ..lineTo(size.width * 0.48, size.height * 0.35)
      ..lineTo(size.width * 0.39, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.36,
        size.height * 0.42,
        size.width * 0.36,
        size.height * 0.47,
      )
      ..lineTo(size.width * 0.36, size.height * 0.49)
      ..close();

    final trailingBand = Path()
      ..moveTo(size.width * 0.52, size.height * 0.17)
      ..lineTo(size.width * 0.7, size.height * 0.27)
      ..quadraticBezierTo(
        size.width * 0.77,
        size.height * 0.31,
        size.width * 0.77,
        size.height * 0.38,
      )
      ..lineTo(size.width * 0.77, size.height * 0.56)
      ..lineTo(size.width * 0.64, size.height * 0.49)
      ..lineTo(size.width * 0.64, size.height * 0.47)
      ..quadraticBezierTo(
        size.width * 0.64,
        size.height * 0.42,
        size.width * 0.61,
        size.height * 0.4,
      )
      ..lineTo(size.width * 0.52, size.height * 0.35)
      ..close();

    final bottomBand = Path()
      ..moveTo(size.width * 0.25, size.height * 0.69)
      ..lineTo(size.width * 0.39, size.height * 0.61)
      ..lineTo(size.width * 0.5, size.height * 0.67)
      ..lineTo(size.width * 0.61, size.height * 0.61)
      ..lineTo(size.width * 0.75, size.height * 0.69)
      ..lineTo(size.width * 0.57, size.height * 0.79)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.84,
        size.width * 0.43,
        size.height * 0.79,
      )
      ..close();

    canvas.drawPath(leftBand, Paint()..color = palette.leadingBand);
    canvas.drawPath(trailingBand, Paint()..color = palette.trailingBand);
    canvas.drawPath(bottomBand, Paint()..color = palette.bottomBand);

    final center = Offset(size.width * 0.5, size.height * 0.5);
    final radius = size.width * 0.065;
    final core = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - radius, center.dy)
      ..close();
    if (tier == ReputationTier.unranked) {
      canvas.drawPath(
        core,
        Paint()
          ..color = palette.core
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, size.width * 0.025),
      );
    } else {
      canvas.drawPath(core, Paint()..color = palette.core);
    }
  }

  void _drawFrameTerminals(Canvas canvas, Size size) {
    final terminalSize = math.max(2.2, size.width * 0.055);
    final terminalPaint = Paint()..color = palette.foreground;
    for (final x in [size.width * 0.06, size.width * 0.94]) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, size.height * 0.49),
          width: terminalSize,
          height: terminalSize,
        ),
        terminalPaint,
      );
    }
  }

  void _drawVerificationNode(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.86, size.height * 0.16);
    final radius = size.width * 0.09;
    canvas.drawCircle(center, radius, Paint()..color = palette.core);
    final check = Path()
      ..moveTo(center.dx - radius * 0.45, center.dy)
      ..lineTo(center.dx - radius * 0.1, center.dy + radius * 0.32)
      ..lineTo(center.dx + radius * 0.5, center.dy - radius * 0.35);
    canvas.drawPath(
      check,
      Paint()
        ..color = const Color(0xFF07101F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.1, size.width * 0.025)
        ..strokeCap = StrokeCap.square
        ..strokeJoin = StrokeJoin.miter,
    );
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashLength,
  ) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength * 1.75;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ReputationEmblemPainter oldDelegate) {
    return oldDelegate.tier != tier ||
        oldDelegate.palette.foreground != palette.foreground ||
        oldDelegate.palette.background != palette.background ||
        oldDelegate.palette.detail != palette.detail;
  }
}
