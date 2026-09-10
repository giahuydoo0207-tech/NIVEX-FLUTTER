import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';

class NivexPage extends StatelessWidget {
  const NivexPage({
    required this.title,
    required this.child,
    super.key,
    this.subtitle,
    this.actions,
    this.showBackButton = false,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        automaticallyImplyLeading: showBackButton,
        backgroundColor: theme.background,
        systemOverlayStyle: theme.systemOverlayStyle,
        iconTheme: IconThemeData(color: theme.textPrimary),
        surfaceTintColor: Colors.transparent,
        titleSpacing: showBackButton ? 0 : 20,
        toolbarHeight: subtitle == null ? 64 : 76,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: theme.textPrimary),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: theme.textSecondary),
              ),
            ],
          ],
        ),
        actions: actions,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Row(
            children: [
              Container(width: 72, height: 1, color: theme.primary),
              Expanded(child: Container(height: 1, color: theme.border)),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _TechGridPainter(
                    lineColor: theme.border.withValues(
                      alpha: theme.isDark ? 0.32 : 0.22,
                    ),
                    accentColor: theme.primary.withValues(
                      alpha: theme.isDark ? 0.12 : 0.07,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(top: false, child: child),
        ],
      ),
    );
  }
}

class NivexCard extends StatelessWidget {
  const NivexCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final cardColor = color ?? theme.surface;
    return Material(
      color: cardColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.border),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _TechGridPainter extends CustomPainter {
  const _TechGridPainter({required this.lineColor, required this.accentColor});

  final Color lineColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 32.0;
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.5;
    final accentPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final signalY = size.height * 0.3;
    final path = Path()
      ..moveTo(0, signalY)
      ..lineTo(size.width * 0.18, signalY)
      ..lineTo(size.width * 0.23, signalY + 22)
      ..lineTo(size.width * 0.42, signalY + 22);
    canvas.drawPath(path, accentPaint);
  }

  @override
  bool shouldRepaint(covariant _TechGridPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor ||
      oldDelegate.accentColor != accentColor;
}
