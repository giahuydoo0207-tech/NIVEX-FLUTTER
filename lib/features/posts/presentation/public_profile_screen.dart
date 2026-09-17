import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/profile/presentation/reputation_badges_screen.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

// ---------------------------------------------------------------------------
// Enums & Data Models
// ---------------------------------------------------------------------------

enum PublicProfileKind { freelancer, business }

class ProfileExperience {
  const ProfileExperience({
    required this.title,
    required this.organization,
    required this.period,
    required this.summary,
  });
  final String title;
  final String organization;
  final String period;
  final String summary;
}

class ProfileEducation {
  const ProfileEducation({
    required this.program,
    required this.institution,
    required this.period,
  });
  final String program;
  final String institution;
  final String period;
}

class ProfilePortfolio {
  const ProfilePortfolio({
    required this.title,
    required this.role,
    required this.summary,
    required this.technologies,
    required this.status,
  });
  final String title;
  final String role;
  final String summary;
  final List<String> technologies;
  final String status;
}

class BusinessOpening {
  const BusinessOpening({
    required this.title,
    required this.type,
    required this.description,
  });
  final String title;
  final String type;
  final String description;
}

class ProfileActivity {
  const ProfileActivity({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String timeLabel;
}

// ---------------------------------------------------------------------------
// PublicProfileData
// ---------------------------------------------------------------------------

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
    this.coverPath,
    this.status = 'Đang hoạt động',
    this.isVerified = false,
    this.isSelf = false,
    this.followerCount = 0,
    this.followingCount = 0,
    this.postCount = 0,
    this.experiences = const [],
    this.education = const [],
    this.portfolio = const [],
    this.openings = const [],
    this.activities = const [],
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
  final String? coverPath;
  final String status;
  final bool isVerified;
  final bool isSelf;
  final int followerCount;
  final int followingCount;
  final int postCount;
  final List<ProfileExperience> experiences;
  final List<ProfileEducation> education;
  final List<ProfilePortfolio> portfolio;
  final List<BusinessOpening> openings;
  final List<ProfileActivity> activities;
}

// ---------------------------------------------------------------------------
// CompactPost  (lightweight model, no _DemoPost coupling)
// ---------------------------------------------------------------------------

class CompactPost {
  const CompactPost({
    required this.content,
    required this.timeLabel,
    required this.reactionCount,
    required this.commentCount,
    required this.imageCount,
    this.imagePreviewPath,
  });
  final String content;
  final String timeLabel;
  final int reactionCount;
  final int commentCount;
  final int imageCount;
  final String? imagePreviewPath;
}

// ---------------------------------------------------------------------------
// PublicProfileScreen
// ---------------------------------------------------------------------------

class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({
    required this.profile,
    this.profilePosts = const [],
    this.isFollowing = false,
    this.onToggleFollow,
    super.key,
  });

  final PublicProfileData profile;
  final List<CompactPost> profilePosts;
  final bool isFollowing;
  final VoidCallback? onToggleFollow;

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  late bool _isFollowing;
  late int _followerCount;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.isFollowing;
    _followerCount = widget.profile.followerCount;
  }

  void _handleFollow() {
    final wasFollowing = _isFollowing;
    setState(() {
      _isFollowing = !_isFollowing;
      _followerCount = _isFollowing
          ? _followerCount + 1
          : (_followerCount - 1).clamp(0, 999999);
    });
    widget.onToggleFollow?.call();
    _showSnack(
      wasFollowing
          ? 'Đã bỏ theo dõi ${widget.profile.displayName}'
          : 'Đã theo dõi ${widget.profile.displayName}',
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 2000),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  void _openFollowerSheet({required bool showFollowing}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.nivexTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FollowerListSheet(
        title: showFollowing ? 'Đang theo dõi' : 'Người theo dõi',
        count: showFollowing ? widget.profile.followingCount : _followerCount,
        isFollowingList: showFollowing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final profile = widget.profile;
    final isBusiness = profile.kind == PublicProfileKind.business;

    return DefaultTabController(
      length: 3,
      child: NivexPage(
        title: profile.displayName,
        subtitle: isBusiness ? 'Hồ sơ doanh nghiệp' : 'Hồ sơ freelancer',
        showBackButton: true,
        actions: [
          if (!profile.isSelf)
            IconButton(
              tooltip: 'Nhắn tin',
              onPressed: () =>
                  _showSnack('Khung chat sẽ kết nối sau khi có backend.'),
              icon: const Icon(Icons.chat_bubble_outline_rounded),
            ),
          const SizedBox(width: 6),
        ],
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(
              child: _ProfileHero(
                profile: profile,
                isFollowing: _isFollowing,
                followerCount: _followerCount,
                onFollow: profile.isSelf ? null : _handleFollow,
                onOpenFollowers: () => _openFollowerSheet(showFollowing: false),
                onOpenFollowing: () => _openFollowerSheet(showFollowing: true),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                height: 64.0,
                child: Container(
                  color: theme.surface,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(height: 1, color: theme.divider),
                      const SizedBox(height: 5),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.surfaceSubtle,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.border),
                        ),
                        child: TabBar(
                          labelColor: theme.primary,
                          unselectedLabelColor: theme.textSecondary,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: theme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          dividerColor: Colors.transparent,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          tabs: const [
                            Tab(text: 'Bài đăng'),
                            Tab(text: 'Giới thiệu'),
                            Tab(text: 'Hoạt động'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _ProfilePostsTab(posts: widget.profilePosts, profile: profile),
              _ProfileAboutTab(profile: profile),
              _ProfileActivityTab(profile: profile),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _TabBarDelegate
// ---------------------------------------------------------------------------

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate({required this.child, this.height = 64.0});
  final Widget child;
  final double height;

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox(height: height, child: child);
  @override
  bool shouldRebuild(_TabBarDelegate old) =>
      old.child != child || old.height != height;
}

// ---------------------------------------------------------------------------
// _ProfileHero
// ---------------------------------------------------------------------------

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.profile,
    required this.isFollowing,
    required this.followerCount,
    required this.onOpenFollowers,
    required this.onOpenFollowing,
    this.onFollow,
  });
  final PublicProfileData profile;
  final bool isFollowing;
  final int followerCount;
  final VoidCallback onOpenFollowers;
  final VoidCallback onOpenFollowing;
  final VoidCallback? onFollow;

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final isBusiness = profile.kind == PublicProfileKind.business;
    final accent = isBusiness ? theme.warning : theme.primary;
    final isSelf = profile.isSelf;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CoverBanner(accent: accent, coverPath: profile.coverPath),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(0, -36),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.surface, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: isBusiness
                            ? theme.warning.withValues(alpha: 0.14)
                            : theme.primary.withValues(alpha: 0.12),
                        foregroundImage: profile.avatarPath != null
                            ? FileImage(File(profile.avatarPath!))
                            : null,
                        child: profile.avatarPath == null
                            ? Icon(
                                isBusiness
                                    ? Icons.business_outlined
                                    : Icons.person_outline_rounded,
                                color: isBusiness
                                    ? theme.warning
                                    : theme.primary,
                                size: 40,
                              )
                            : null,
                      ),
                    ),
                    const Spacer(),
                    if (!isSelf) ...[
                      FilledButton.icon(
                        onPressed: onFollow,
                        icon: Icon(
                          isFollowing ? Icons.check_rounded : Icons.add_rounded,
                          size: 17,
                        ),
                        label: Text(isFollowing ? 'Đang theo dõi' : 'Theo dõi'),
                        style: FilledButton.styleFrom(
                          backgroundColor: isFollowing
                              ? theme.primary.withValues(alpha: 0.15)
                              : theme.primary,
                          foregroundColor: isFollowing
                              ? theme.primary
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (isBusiness) ...[
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => ScaffoldMessenger.of(context)
                              .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Xem cơ hội sẽ kết nối sau khi có backend.',
                                  ),
                                ),
                              ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.warning,
                            side: BorderSide(
                              color: theme.warning.withValues(alpha: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Cơ hội'),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      profile.displayName,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (profile.isVerified) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.verified_rounded,
                      color: theme.primary,
                      size: 18,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '@${profile.handle}',
                style: TextStyle(color: theme.textSecondary, fontSize: 12.5),
              ),
              const SizedBox(height: 8),
              _StatusPill(
                label: profile.status,
                color: isBusiness ? theme.warning : theme.success,
              ),
              const SizedBox(height: 10),
              Text(
                profile.headline,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: theme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    profile.location,
                    style: TextStyle(color: theme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _StatTapItem(
                    label: 'Bài đăng',
                    value: '${profile.postCount}',
                    onTap: null,
                  ),
                  const SizedBox(width: 20),
                  _StatTapItem(
                    label: 'Người theo dõi',
                    value: _fmt(followerCount),
                    onTap: onOpenFollowers,
                  ),
                  const SizedBox(width: 20),
                  _StatTapItem(
                    label: 'Đang theo dõi',
                    value: _fmt(profile.followingCount),
                    onTap: onOpenFollowing,
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverBanner extends StatelessWidget {
  const _CoverBanner({required this.accent, this.coverPath});
  final Color accent;
  final String? coverPath;

  @override
  Widget build(BuildContext context) {
    if (coverPath != null && File(coverPath!).existsSync()) {
      return SizedBox(
        height: 110,
        width: double.infinity,
        child: Image.file(File(coverPath!), fit: BoxFit.cover),
      );
    }
    return Container(
      height: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0D1B2A), accent.withValues(alpha: 0.55)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: CustomPaint(
        painter: _GridPainter(color: accent.withValues(alpha: 0.12)),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 0.8;
    const s = 22.0;
    for (double x = 0; x < size.width; x += s) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += s) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
}

class _StatTapItem extends StatelessWidget {
  const _StatTapItem({required this.label, required this.value, this.onTap});
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(label, style: TextStyle(color: theme.textSecondary, fontSize: 11)),
      ],
    );
    if (onTap == null) return col;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: col,
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1: Bai dang (compact)
// ---------------------------------------------------------------------------

class _ProfilePostsTab extends StatelessWidget {
  const _ProfilePostsTab({required this.posts, required this.profile});
  final List<CompactPost> posts;
  final PublicProfileData profile;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return _ProfileEmptyState(
        icon: Icons.article_outlined,
        title: 'Chưa có bài đăng nào',
        subtitle: profile.isSelf
            ? 'Các bài đăng bạn chia sẻ sẽ hiển thị ở đây.'
            : '${profile.displayName} chưa đăng bài nào.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: posts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) =>
          _ProfilePostCard(post: posts[i], profile: profile),
    );
  }
}

class _ProfilePostCard extends StatelessWidget {
  const _ProfilePostCard({required this.post, required this.profile});
  final CompactPost post;
  final PublicProfileData profile;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final isBusiness = profile.kind == PublicProfileKind.business;

    return NivexCard(
      padding: const EdgeInsets.all(14),
      child: InkWell(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chi tiết bài đăng sẽ kết nối sau.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(milliseconds: 1600),
            margin: EdgeInsets.fromLTRB(16, 0, 16, 24),
          ),
        ),
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: isBusiness
                      ? theme.warning.withValues(alpha: 0.14)
                      : theme.primary.withValues(alpha: 0.12),
                  foregroundImage: profile.avatarPath != null
                      ? FileImage(File(profile.avatarPath!))
                      : null,
                  child: profile.avatarPath == null
                      ? Icon(
                          isBusiness
                              ? Icons.business_outlined
                              : Icons.person_outline_rounded,
                          color: isBusiness ? theme.warning : theme.primary,
                          size: 18,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.displayName,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        post.timeLabel,
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (post.content.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ],
            if (post.imagePreviewPath != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(post.imagePreviewPath!),
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 80,
                    color: theme.surfaceSubtle,
                    child: Icon(
                      Icons.image_outlined,
                      color: theme.textSecondary,
                    ),
                  ),
                ),
              ),
            ] else if (post.imageCount > 0) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 13,
                    color: theme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.imageCount} hình ảnh',
                    style: TextStyle(color: theme.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                if (post.reactionCount > 0) ...[
                  Icon(
                    Icons.thumb_up_alt_rounded,
                    size: 13,
                    color: theme.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.reactionCount}',
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (post.commentCount > 0) ...[
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 13,
                    color: theme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.commentCount} bình luận',
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2: Gioi thieu
// ---------------------------------------------------------------------------

class _ProfileAboutTab extends StatelessWidget {
  const _ProfileAboutTab({required this.profile});
  final PublicProfileData profile;

  @override
  Widget build(BuildContext context) =>
      profile.kind == PublicProfileKind.freelancer
      ? _FreelancerAbout(profile: profile)
      : _BusinessAbout(profile: profile);
}

class _FreelancerAbout extends StatelessWidget {
  const _FreelancerAbout({required this.profile});
  final PublicProfileData profile;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        _AboutSection(
          title: 'Giới thiệu bản thân',
          icon: Icons.subject_rounded,
          child: Text(
            profile.bio.isEmpty ? 'Chưa có mô tả.' : profile.bio,
            style: TextStyle(
              color: theme.textSecondary,
              height: 1.5,
              fontSize: 13.5,
            ),
          ),
        ),
        const SizedBox(height: 14),
        _AboutSection(
          title: 'Cấp bậc uy tín',
          icon: Icons.shield_outlined,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ReputationBadgesScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: theme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chưa xếp hạng',
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Cấp bậc uy tín Nova',
                          style: TextStyle(
                            color: theme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tín hiệu tham khảo dựa trên dự án hoàn thành, review hợp lệ và mức độ xác thực.',
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 11.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: theme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (profile.stats.isNotEmpty) ...[
          const SizedBox(height: 14),
          _AboutSection(
            title: 'Trạng thái & Khả năng',
            icon: Icons.work_outline_rounded,
            child: Column(
              children: [
                for (var i = 0; i < profile.stats.length; i++) ...[
                  if (i > 0) Divider(height: 14, color: theme.divider),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        profile.stats[i].label,
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        profile.stats[i].value,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
        if (profile.tags.isNotEmpty) ...[
          const SizedBox(height: 14),
          _AboutSection(
            title: 'Kỹ năng chuyên môn',
            icon: Icons.code_rounded,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final tag in profile.tags) _Tag(label: tag)],
            ),
          ),
        ],
        if (profile.portfolio.isNotEmpty) ...[
          const SizedBox(height: 14),
          _AboutSection(
            title: 'Dự án & Portfolio',
            icon: Icons.folder_open_outlined,
            child: Column(
              children: [
                for (var i = 0; i < profile.portfolio.length; i++) ...[
                  if (i > 0) Divider(height: 16, color: theme.divider),
                  _PortfolioItem(item: profile.portfolio[i]),
                ],
              ],
            ),
          ),
        ],
        if (profile.experiences.isNotEmpty) ...[
          const SizedBox(height: 14),
          _AboutSection(
            title: 'Kinh nghiệm',
            icon: Icons.business_center_outlined,
            child: Column(
              children: [
                for (var i = 0; i < profile.experiences.length; i++) ...[
                  if (i > 0) Divider(height: 16, color: theme.divider),
                  _ExperienceItem(exp: profile.experiences[i]),
                ],
              ],
            ),
          ),
        ],
        if (profile.education.isNotEmpty) ...[
          const SizedBox(height: 14),
          _AboutSection(
            title: 'Học vấn',
            icon: Icons.school_outlined,
            child: Column(
              children: [
                for (var i = 0; i < profile.education.length; i++) ...[
                  if (i > 0) Divider(height: 16, color: theme.divider),
                  _EducationItem(edu: profile.education[i]),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _BusinessAbout extends StatelessWidget {
  const _BusinessAbout({required this.profile});
  final PublicProfileData profile;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        _AboutSection(
          title: 'Giới thiệu doanh nghiệp',
          icon: Icons.subject_rounded,
          child: Text(
            profile.bio.isEmpty ? 'Chưa có mô tả.' : profile.bio,
            style: TextStyle(
              color: theme.textSecondary,
              height: 1.5,
              fontSize: 13.5,
            ),
          ),
        ),
        if (profile.tags.isNotEmpty) ...[
          const SizedBox(height: 14),
          _AboutSection(
            title: 'Lĩnh vực hoạt động',
            icon: Icons.business_center_outlined,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in profile.tags)
                  _Tag(label: tag, isWarning: true),
              ],
            ),
          ),
        ],
        if (profile.stats.isNotEmpty) ...[
          const SizedBox(height: 14),
          _AboutSection(
            title: 'Thống kê',
            icon: Icons.insights_outlined,
            child: Column(
              children: [
                for (var i = 0; i < profile.stats.length; i++) ...[
                  if (i > 0) Divider(height: 14, color: theme.divider),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        profile.stats[i].label,
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        profile.stats[i].value,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
        if (profile.openings.isNotEmpty) ...[
          const SizedBox(height: 14),
          _AboutSection(
            title: 'Cơ hội đang mở',
            icon: Icons.work_outline_rounded,
            child: Column(
              children: [
                for (var i = 0; i < profile.openings.length; i++) ...[
                  if (i > 0) Divider(height: 14, color: theme.divider),
                  _OpeningItem(opening: profile.openings[i]),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        _AboutSection(
          title: 'Xác minh doanh nghiệp',
          icon: Icons.verified_outlined,
          child: Row(
            children: [
              Icon(
                profile.isVerified
                    ? Icons.verified_rounded
                    : Icons.pending_outlined,
                color: profile.isVerified ? theme.success : theme.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  profile.isVerified
                      ? 'Doanh nghiệp đã được Nova xác minh'
                      : 'Chưa xác minh — đang chờ xét duyệt',
                  style: TextStyle(
                    color: profile.isVerified
                        ? theme.success
                        : theme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 3: Hoat dong
// ---------------------------------------------------------------------------

class _ProfileActivityTab extends StatelessWidget {
  const _ProfileActivityTab({required this.profile});
  final PublicProfileData profile;

  List<ProfileActivity> _defaults() {
    final isBusiness = profile.kind == PublicProfileKind.business;
    if (isBusiness) {
      return const [
        ProfileActivity(
          icon: Icons.work_outline_rounded,
          color: Color(0xFFF59E0B),
          title: 'Đăng cơ hội mới',
          subtitle: 'Flutter Developer — Remote, full-time',
          timeLabel: '2 gio truoc',
        ),
        ProfileActivity(
          icon: Icons.article_outlined,
          color: Color(0xFF38BDF8),
          title: 'Đăng bài viết mới',
          subtitle: 'Chia sẻ về hướng phát triển sản phẩm Q4',
          timeLabel: 'Hom qua',
        ),
        ProfileActivity(
          icon: Icons.people_outline_rounded,
          color: Color(0xFFA855F7),
          title: 'Kết nối với 3 freelancer',
          subtitle: 'Mở rộng mạng lưới cộng tác viên',
          timeLabel: '3 ngay truoc',
        ),
        ProfileActivity(
          icon: Icons.star_outline_rounded,
          color: Color(0xFF06B6D4),
          title: 'Nhận đánh giá 5 sao',
          subtitle: 'Từ dự án hoàn thành tháng trước',
          timeLabel: '1 tuan truoc',
        ),
        ProfileActivity(
          icon: Icons.celebration_rounded,
          color: Color(0xFFF43F5E),
          title: 'Kỷ niệm 1 năm trên Nova',
          subtitle: 'Cột mốc đặc biệt của doanh nghiệp',
          timeLabel: '2 tuan truoc',
        ),
      ];
    }
    return const [
      ProfileActivity(
        icon: Icons.article_outlined,
        color: Color(0xFF38BDF8),
        title: 'Đăng bài viết mới',
        subtitle: 'Chia sẻ về flow thanh toán mới nhất',
        timeLabel: '2 gio truoc',
      ),
      ProfileActivity(
        icon: Icons.folder_open_outlined,
        color: Color(0xFFA855F7),
        title: 'Cập nhật portfolio',
        subtitle: 'Thêm dự án Nova Mobile Prototype',
        timeLabel: 'Hom qua',
      ),
      ProfileActivity(
        icon: Icons.chat_bubble_outline_rounded,
        color: Color(0xFF06B6D4),
        title: 'Bình luận bài viết',
        subtitle: 'Bình luận về bài của Nova Labs',
        timeLabel: '2 ngay truoc',
      ),
      ProfileActivity(
        icon: Icons.thumb_up_alt_rounded,
        color: Color(0xFF38BDF8),
        title: 'Nhận 12 lượt thích',
        subtitle: 'Bài viết về thanh toán mobile được quan tâm',
        timeLabel: '3 ngay truoc',
      ),
      ProfileActivity(
        icon: Icons.star_outline_rounded,
        color: Color(0xFFF59E0B),
        title: 'Đạt điểm uy tín 4.9',
        subtitle: 'Dựa trên phản hồi từ các dự án hoàn thành',
        timeLabel: '1 tuan truoc',
      ),
      ProfileActivity(
        icon: Icons.celebration_rounded,
        color: Color(0xFFF43F5E),
        title: 'Hoàn thành dự án',
        subtitle: 'Nova Wallet MVP — Flutter + Solana',
        timeLabel: '2 tuan truoc',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final activities = profile.activities.isEmpty
        ? _defaults()
        : profile.activities;
    if (activities.isEmpty) {
      return const _ProfileEmptyState(
        icon: Icons.timeline_outlined,
        title: 'Chưa có hoạt động',
        subtitle: 'Các hoạt động gần đây sẽ xuất hiện tại đây.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: activities.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _ActivityItem(activity: activities[i]),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({required this.activity});
  final ProfileActivity activity;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activity.color.withValues(alpha: 0.14),
            ),
            child: Icon(activity.icon, color: activity.color, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            activity.timeLabel,
            style: TextStyle(color: theme.textSecondary, fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Follower / Following Sheet
// ---------------------------------------------------------------------------

class _MockEntry {
  const _MockEntry({
    required this.name,
    required this.headline,
    required this.handle,
    this.kind = PublicProfileKind.freelancer,
  });
  final String name;
  final String headline;
  final String handle;
  final PublicProfileKind kind;
}

const _kFollowers = [
  _MockEntry(
    name: 'Tran Bao Long',
    headline: 'Senior Product Manager @ Fintech VN',
    handle: 'baolong.pm',
  ),
  _MockEntry(
    name: 'Le Thao My',
    headline: 'UI/UX Designer Mobile & Web',
    handle: 'thaomy.design',
  ),
  _MockEntry(
    name: 'Pham Hoang Nam',
    headline: 'Web3 Developer Solana Ecosystem',
    handle: 'hoangnam.web3',
  ),
  _MockEntry(
    name: 'Nova Labs',
    headline: 'Fintech Web3 Remote-first',
    handle: 'nova.labs',
    kind: PublicProfileKind.business,
  ),
  _MockEntry(
    name: 'Nguyen Thi Hang',
    headline: 'Backend Engineer Spring Boot PostgreSQL',
    handle: 'thihang.be',
  ),
];

const _kFollowing = [
  _MockEntry(
    name: 'Nova Labs',
    headline: 'Fintech Web3 Remote-first',
    handle: 'nova.labs',
    kind: PublicProfileKind.business,
  ),
  _MockEntry(
    name: 'Tran Bao Long',
    headline: 'Senior Product Manager @ Fintech VN',
    handle: 'baolong.pm',
  ),
  _MockEntry(
    name: 'Vu Duy Khang',
    headline: 'DevOps Engineer Docker K8s',
    handle: 'duykhang.ops',
  ),
];

class _FollowerListSheet extends StatefulWidget {
  const _FollowerListSheet({
    required this.title,
    required this.count,
    required this.isFollowingList,
  });
  final String title;
  final int count;
  final bool isFollowingList;
  @override
  State<_FollowerListSheet> createState() => _FollowerListSheetState();
}

class _FollowerListSheetState extends State<_FollowerListSheet> {
  final Set<String> _followed = {};

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final entries = widget.isFollowingList ? _kFollowing : _kFollowers;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (ctx, sc) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  '${widget.title} · ${widget.count}',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.separated(
                controller: sc,
                itemCount: entries.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: theme.divider),
                itemBuilder: (ctx, i) {
                  final e = entries[i];
                  final isBiz = e.kind == PublicProfileKind.business;
                  final isF = _followed.contains(e.handle);
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: isBiz
                          ? theme.warning.withValues(alpha: 0.14)
                          : theme.primary.withValues(alpha: 0.12),
                      child: Icon(
                        isBiz
                            ? Icons.business_outlined
                            : Icons.person_outline_rounded,
                        color: isBiz ? theme.warning : theme.primary,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      e.name,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      e.headline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: () => setState(() {
                        if (isF) {
                          _followed.remove(e.handle);
                        } else {
                          _followed.add(e.handle);
                        }
                      }),
                      style: TextButton.styleFrom(
                        foregroundColor: isF
                            ? theme.textSecondary
                            : theme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                      ),
                      child: Text(
                        isF ? 'Đang theo dõi' : 'Theo dõi',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helper widgets
// ---------------------------------------------------------------------------

class _ProfileEmptyState extends StatelessWidget {
  const _ProfileEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: theme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 12.5,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({
    required this.title,
    required this.icon,
    required this.child,
  });
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
            Icon(icon, size: 18, color: theme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        NivexCard(child: child),
      ],
    );
  }
}

class _ExperienceItem extends StatelessWidget {
  const _ExperienceItem({required this.exp});
  final ProfileExperience exp;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exp.title,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
              Text(
                exp.organization,
                style: TextStyle(color: theme.primary, fontSize: 12.5),
              ),
              Text(
                exp.period,
                style: TextStyle(color: theme.textSecondary, fontSize: 11.5),
              ),
              const SizedBox(height: 4),
              Text(
                exp.summary,
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EducationItem extends StatelessWidget {
  const _EducationItem({required this.edu});
  final ProfileEducation edu;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.school_outlined, size: 16, color: theme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                edu.program,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
              Text(
                edu.institution,
                style: TextStyle(color: theme.primary, fontSize: 12.5),
              ),
              Text(
                edu.period,
                style: TextStyle(color: theme.textSecondary, fontSize: 11.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PortfolioItem extends StatelessWidget {
  const _PortfolioItem({required this.item});
  final ProfilePortfolio item;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: theme.success.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.status,
                style: TextStyle(
                  color: theme.success,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(item.role, style: TextStyle(color: theme.primary, fontSize: 12.5)),
        const SizedBox(height: 4),
        Text(
          item.summary,
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [for (final t in item.technologies) _SmallTag(label: t)],
        ),
      ],
    );
  }
}

class _OpeningItem extends StatelessWidget {
  const _OpeningItem({required this.opening});
  final BusinessOpening opening;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                opening.title,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: theme.warning.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                opening.type,
                style: TextStyle(
                  color: theme.warning,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          opening.description,
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.isWarning = false});
  final String label;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final color = isWarning ? theme.warning : theme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: theme.surfaceSubtle,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: theme.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.textSecondary,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withValues(alpha: 0.45)),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
