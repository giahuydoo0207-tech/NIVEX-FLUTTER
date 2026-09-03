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
      ),
      body: SafeArea(top: false, child: child),
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
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.border),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
