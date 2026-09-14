import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

enum PublicProfileKind { freelancer, business }

class PublicProfileData {
  const PublicProfileData({
    required this.kind,
    required this.displayName,
    required this.handle,
    required this.headline,
    required this.location,
    required this.bio,
    required this.tags,
    required this.stats,
    this.avatarPath,
    this.status = 'Đang hoạt động',
  });

  final PublicProfileKind kind;
  final String displayName;
  final String handle;
  final String headline;
  final String location;
  final String bio;
  final List<String> tags;
  final List<({String label, String value})> stats;
  final String? avatarPath;
  final String status;
}

class PublicProfileScreen extends StatelessWidget {
  const PublicProfileScreen({required this.profile, super.key});

  final PublicProfileData profile;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final isBusiness = profile.kind == PublicProfileKind.business;
    return NivexPage(
      title: 'Hồ sơ công khai',
      subtitle: isBusiness ? 'Thông tin doanh nghiệp' : 'Thông tin freelancer',
      showBackButton: true,
      actions: [
        IconButton(
          tooltip: 'Nhắn tin',
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Khung chat sẽ kết nối sau khi có backend.')),
          ),
          icon: const Icon(Icons.chat_bubble_outline_rounded),
        ),
        const SizedBox(width: 6),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _ProfileIdentity(profile: profile),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Giới thiệu',
            icon: Icons.subject_rounded,
            child: Text(profile.bio,
                style: TextStyle(color: theme.textSecondary, height: 1.5)),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: isBusiness ? 'Lĩnh vực hoạt động' : 'Kỹ năng chuyên môn',
            icon: isBusiness ? Icons.business_center_outlined : Icons.code_rounded,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final tag in profile.tags) _Tag(label: tag)],
            ),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Tổng quan',
            icon: Icons.insights_outlined,
            child: Column(
              children: [
                for (var index = 0; index < profile.stats.length; index++) ...[
                  if (index > 0) Divider(height: 18, color: theme.divider),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(profile.stats[index].label,
                          style: TextStyle(color: theme.textSecondary)),
                      Text(profile.stats[index].value,
                          style: TextStyle(
                              color: theme.textPrimary,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã gửi lời mời kết nối trong bản thử nghiệm.')),
            ),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: Text(isBusiness ? 'Kết nối với doanh nghiệp' : 'Kết nối với freelancer'),
          ),
        ],
      ),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({required this.profile});
  final PublicProfileData profile;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final accent = profile.kind == PublicProfileKind.business
        ? theme.warning
        : theme.primary;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: accent.withValues(alpha: 0.14),
                foregroundImage: profile.avatarPath == null
                    ? null
                    : FileImage(File(profile.avatarPath!)),
                child: profile.avatarPath == null
                    ? Icon(
                        profile.kind == PublicProfileKind.business
                            ? Icons.business_outlined
                            : Icons.person_outline_rounded,
                        color: accent,
                        size: 31,
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.displayName,
                        style: TextStyle(
                            color: theme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text('@${profile.handle}',
                        style: TextStyle(color: theme.textSecondary)),
                    const SizedBox(height: 8),
                    _StatusPill(label: profile.status, color: theme.success),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(profile.headline,
              style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: theme.textSecondary),
              const SizedBox(width: 5),
              Text(profile.location,
                  style: TextStyle(color: theme.textSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.icon, required this.child});
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 19, color: theme.primary),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 9),
        NivexCard(child: child),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.primary.withValues(alpha: 0.45)),
      ),
      child: Text(label,
          style: TextStyle(
              color: theme.primary, fontSize: 11.5, fontWeight: FontWeight.w700)),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w700)),
      );
}
