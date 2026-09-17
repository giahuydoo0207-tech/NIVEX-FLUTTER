import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/profile/domain/reputation_tier.dart';

class ReputationAvatar extends StatelessWidget {
  const ReputationAvatar({
    this.avatarPath,
    this.initials,
    this.fallbackIcon,
    this.tier = ReputationTier.unranked,
    this.size = 64,
    this.showOnlineDot = false,
    this.isBusiness = false,
    this.onTap,
    super.key,
  });

  final String? avatarPath;
  final String? initials;
  final IconData? fallbackIcon;
  final ReputationTier tier;
  final double size;
  final bool showOnlineDot;
  final bool isBusiness;
  final VoidCallback? onTap;

  static List<Color> ringGradient(ReputationTier tier) => switch (tier) {
    ReputationTier.unranked => [
      const Color(0xFF64748B).withValues(alpha: 0.5),
      const Color(0xFF475569).withValues(alpha: 0.5),
    ],
    ReputationTier.bronze => const [
      Color(0xFFE59866),
      Color(0xFFC47A4A),
      Color(0xFFA0522D),
    ],
    ReputationTier.silver => const [
      Color(0xFFF1F5F9),
      Color(0xFFCBD5E1),
      Color(0xFF94A3B8),
    ],
    ReputationTier.gold => const [
      Color(0xFFFEF08A),
      Color(0xFFFACC15),
      Color(0xFFEAB308),
    ],
    ReputationTier.platinum => const [
      Color(0xFFA5F3FC),
      Color(0xFF67E8F9),
      Color(0xFF22D3EE),
    ],
    ReputationTier.verifiedExpert => const [
      Color(0xFF7DD3FC),
      Color(0xFF38BDF8),
      Color(0xFF0284C7),
    ],
  };

  static List<BoxShadow> ringGlow(ReputationTier tier) => switch (tier) {
    ReputationTier.unranked => const [],
    ReputationTier.bronze => [
      BoxShadow(
        color: const Color(0xFFC47A4A).withValues(alpha: 0.25),
        blurRadius: 8,
        spreadRadius: 1,
      ),
    ],
    ReputationTier.silver => [
      BoxShadow(
        color: const Color(0xFFCBD5E1).withValues(alpha: 0.20),
        blurRadius: 8,
        spreadRadius: 1,
      ),
    ],
    ReputationTier.gold => [
      BoxShadow(
        color: const Color(0xFFFACC15).withValues(alpha: 0.35),
        blurRadius: 10,
        spreadRadius: 1.5,
      ),
    ],
    ReputationTier.platinum => [
      BoxShadow(
        color: const Color(0xFF67E8F9).withValues(alpha: 0.40),
        blurRadius: 12,
        spreadRadius: 2,
      ),
    ],
    ReputationTier.verifiedExpert => [
      BoxShadow(
        color: const Color(0xFF38BDF8).withValues(alpha: 0.38),
        blurRadius: 10,
        spreadRadius: 1.5,
      ),
    ],
  };

  static double ringWidth(ReputationTier tier, double size) {
    final scale = size / 64.0;
    return switch (tier) {
      ReputationTier.unranked => (2.0 * scale).clamp(1.5, 2.5),
      ReputationTier.bronze => (2.5 * scale).clamp(1.8, 3.0),
      ReputationTier.silver => (2.5 * scale).clamp(1.8, 3.0),
      ReputationTier.gold => (3.0 * scale).clamp(2.0, 3.5),
      ReputationTier.platinum => (3.0 * scale).clamp(2.0, 3.5),
      ReputationTier.verifiedExpert => (3.0 * scale).clamp(2.0, 3.5),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final rWidth = ringWidth(tier, size);
    final gapWidth = (size > 40) ? 2.5 : 1.5;

    final avatarCore = CircleAvatar(
      radius: (size - (rWidth + gapWidth) * 2) / 2,
      backgroundColor: isBusiness
          ? theme.warning.withValues(alpha: 0.16)
          : theme.primary.withValues(alpha: 0.16),
      foregroundImage: avatarPath != null ? FileImage(File(avatarPath!)) : null,
      child: avatarPath != null
          ? null
          : (initials != null
                ? Text(
                    initials!,
                    style: TextStyle(
                      fontSize: (size * 0.32).clamp(11.0, 24.0),
                      fontWeight: FontWeight.w700,
                      color: isBusiness ? theme.warning : theme.primary,
                    ),
                  )
                : Icon(
                    fallbackIcon ??
                        (isBusiness
                            ? Icons.business_outlined
                            : Icons.person_outline_rounded),
                    color: isBusiness ? theme.warning : theme.primary,
                    size: size * 0.48,
                  )),
    );

    Widget ringWidget;
    if (tier == ReputationTier.unranked) {
      ringWidget = Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(rWidth),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF64748B).withValues(alpha: 0.38),
            width: rWidth,
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(gapWidth),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.surface,
          ),
          child: avatarCore,
        ),
      );
    } else {
      ringWidget = Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(rWidth),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: ringGradient(tier),
          ),
          boxShadow: ringGlow(tier),
        ),
        child: Container(
          padding: EdgeInsets.all(gapWidth),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.surface,
          ),
          child: avatarCore,
        ),
      );
    }

    if (onTap != null) {
      ringWidget = GestureDetector(onTap: onTap, child: ringWidget);
    }

    if (!showOnlineDot) {
      return ringWidget;
    }

    final dotSize = (size * 0.22).clamp(10.0, 16.0);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ringWidget,
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: theme.success,
              shape: BoxShape.circle,
              border: Border.all(color: theme.surface, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
