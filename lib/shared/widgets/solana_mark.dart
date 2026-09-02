import 'package:flutter/material.dart';

/// Official Solana mark widget with brand gradient and transparent background.
/// Proportions: width / height = 397.32 / 311.53 ≈ 1.2754.
class SolanaMark extends StatelessWidget {
  const SolanaMark({this.width = 19, this.height, super.key});

  /// The width in logical pixels. Default is 19.
  final double width;

  /// Optional explicit height in logical pixels. Defaults to [width] / 1.2754.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final h = height ?? (width / 1.27538);

    return Image.asset(
      'assets/icons/solana-mark.png',
      width: width,
      height: h,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
    );
  }
}
