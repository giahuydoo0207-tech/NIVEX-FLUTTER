import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';

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
    return Scaffold(
      backgroundColor: NivexColors.ivory,
      appBar: AppBar(
        automaticallyImplyLeading: showBackButton,
        backgroundColor: NivexColors.ivory,
        surfaceTintColor: Colors.transparent,
        titleSpacing: showBackButton ? 0 : 20,
        toolbarHeight: subtitle == null ? 64 : 76,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
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
    this.color = NivexColors.white,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: NivexColors.border),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
