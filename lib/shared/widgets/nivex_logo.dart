import 'package:flutter/material.dart';

class NivexLogo extends StatelessWidget {
  const NivexLogo({
    super.key,
    this.height = 24,
    this.isLight = true,
    this.markOnly = false,
  });

  final double height;
  final bool isLight;
  final bool markOnly;

  @override
  Widget build(BuildContext context) {
    if (markOnly) {
      return Semantics(
        label: 'Nova',
        child: Image.asset(
          'assets/icons/nova-mark.png',
          height: height,
          width: height,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      );
    }

    final assetPath = isLight
        ? 'assets/icons/nova-logo-horizontal.png'
        : 'assets/icons/nova-logo-horizontal-dark.png';

    return Semantics(
      label: 'Nova',
      child: Image.asset(
        assetPath,
        height: height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
