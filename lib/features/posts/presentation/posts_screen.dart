import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/profile/data/demo_freelancer_profile_controller.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

import 'public_profile_screen.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  static const _maxImages = 10;
  final _picker = ImagePicker();
  final _profileController = DemoFreelancerProfileController.instance;
  final _composerController = TextEditingController();
  final List<XFile> _selectedImages = [];
  final List<_DemoPost> _posts = [
    const _DemoPost(
      content:
          'Mình vừa hoàn thiện một flow thanh toán mới cho ứng dụng mobile. Rất vui được kết nối với các dự án fintech phù hợp.',
      images: [],
      timeLabel: 'Hôm nay, 09:24',
    ),
    const _DemoPost(
      content:
          'NIVEX Labs đang tìm thêm freelancer cho các dự án fintech và sản phẩm Web3. Xem hồ sơ để tìm hiểu cơ hội hợp tác.',
      images: [],
      timeLabel: 'Hôm qua, 18:40',
      isMine: false,
    ),
  ];
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _profileController.addListener(_refreshProfile);
  }

  @override
  void dispose() {
    _profileController.removeListener(_refreshProfile);
    _composerController.dispose();
    super.dispose();
  }

  void _refreshProfile() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return NivexPage(
      title: 'Cộng đồng',
      subtitle: 'Chia sẻ tiến độ, sản phẩm và cơ hội hợp tác',
      showBackButton: true,
      actions: [
        IconButton(
          tooltip: 'Bài đăng của tôi',
          onPressed: _openMyPosts,
          icon: const Icon(Icons.history_rounded),
        ),
        IconButton(
          tooltip: 'Khám phá hồ sơ',
          onPressed: _openExampleProfiles,
          icon: const Icon(Icons.people_outline_rounded),
        ),
        const SizedBox(width: 6),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _PostComposer(
            controller: _composerController,
            images: _selectedImages,
            avatarPath: _profileController.profile.avatarPath,
            isPublishing: _isPublishing,
            onPickImages: _pickImages,
            onRemoveImage: (index) =>
                setState(() => _selectedImages.removeAt(index)),
            onPublish: _publish,
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Icon(Icons.dynamic_feed_outlined,
                  size: 19, color: context.nivexTheme.primary),
              const SizedBox(width: 8),
              Text('Bài đăng mới nhất',
                  style: TextStyle(
                    color: context.nivexTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          for (final post in _posts) ...[
            _PostCard(
              post: post,
              ownAvatarPath: _profileController.profile.avatarPath,
              onOpenProfile: () => _openProfile(_postAuthor(post)),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    final remaining = _maxImages - _selectedImages.length;
    if (remaining <= 0) {
      _showMessage('Mỗi bài đăng được đính kèm tối đa $_maxImages ảnh.');
      return;
    }
    try {
      final images = await _picker.pickMultiImage(
        imageQuality: 88,
        maxWidth: 1800,
        limit: remaining,
      );
      if (!mounted || images.isEmpty) return;
      setState(() => _selectedImages.addAll(images.take(remaining)));
    } catch (_) {
      if (mounted) _showMessage('Không thể mở thư viện ảnh. Hãy kiểm tra quyền truy cập.');
    }
  }

  Future<void> _publish() async {
    final content = _composerController.text.trim();
    if (content.isEmpty && _selectedImages.isEmpty) {
      _showMessage('Hãy viết nội dung hoặc chọn ít nhất một ảnh.');
      return;
    }
    setState(() => _isPublishing = true);
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;
    setState(() {
      _posts.insert(
        0,
        _DemoPost(
          content: content,
          images: List<XFile>.from(_selectedImages),
          timeLabel: 'Vừa xong',
        ),
      );
      _composerController.clear();
      _selectedImages.clear();
      _isPublishing = false;
    });
    _showMessage('Đã đăng bài trong bản thử nghiệm.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  PublicProfileData _postAuthor(_DemoPost post) {
    if (!post.isMine) return post.author;
    final profile = _profileController.profile;
    return PublicProfileData(
      kind: PublicProfileKind.freelancer,
      displayName: profile.displayName,
      handle: profile.username,
      headline: profile.headline,
      location: profile.location,
      bio: profile.bio,
      tags: profile.skills,
      avatarPath: profile.avatarPath,
      stats: [
        (label: 'Năng lực mỗi tuần', value: '${profile.weeklyCapacityHours} giờ'),
        (label: 'Hình thức', value: profile.workPreference),
      ],
      status: profile.isAvailable ? 'Sẵn sàng' : 'Đang bận',
    );
  }

  void _openProfile(PublicProfileData profile) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => PublicProfileScreen(profile: profile)),
    );
  }

  void _openExampleProfiles() {
    final freelancer = PublicProfileData(
      kind: PublicProfileKind.freelancer,
      displayName: 'Nguyễn Minh Anh',
      handle: 'minhanh.product',
      headline: 'Product Designer · Remote Workflows',
      location: 'Hồ Chí Minh, Việt Nam',
      bio: 'Thiết kế sản phẩm số rõ ràng, dễ dùng và phù hợp với quy trình làm việc từ xa.',
      tags: ['Product Design', 'Figma', 'Research'],
      stats: [
        (label: 'Dự án hoàn thành', value: '18'),
        (label: 'Phản hồi tích cực', value: '98%'),
      ],
      status: 'Sẵn sàng nhận việc',
    );
    final business = PublicProfileData(
      kind: PublicProfileKind.business,
      displayName: 'NIVEX Labs',
      handle: 'nivex.labs',
      headline: 'Fintech · Web3 · Remote-first',
      location: 'Đà Nẵng, Việt Nam',
      bio: 'Đội ngũ xây dựng sản phẩm tài chính số minh bạch cho freelancer và doanh nghiệp.',
      tags: ['Fintech', 'Solana', 'Remote-first'],
      stats: [
        (label: 'Cơ hội đang mở', value: '3'),
        (label: 'Đã kết nối', value: '126'),
      ],
      status: 'Đang tuyển',
    );
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _ProfilePickerSheet(
        profiles: [freelancer, business],
        onSelected: (profile) {
          Navigator.pop(context);
          _openProfile(profile);
        },
      ),
    );
  }

  void _openMyPosts() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MyPostsScreen(
          posts: _posts.where((post) => post.isMine).toList(),
          avatarPath: _profileController.profile.avatarPath,
        ),
      ),
    );
  }
}

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({required this.posts, required this.avatarPath, super.key});

  final List<_DemoPost> posts;
  final String? avatarPath;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexPage(
      title: 'Bài đăng của tôi',
      subtitle: 'Tổng hợp và lịch sử chia sẻ',
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Row(
            children: [
              Expanded(child: _PostStat(label: 'Tổng bài đăng', value: '${posts.length}')),
              const SizedBox(width: 10),
              Expanded(
                child: _PostStat(
                  label: 'Ảnh đã chia sẻ',
                  value: '${posts.fold<int>(0, (sum, post) => sum + post.images.length)}',
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(child: _PostStat(label: 'Lượt tương tác', value: '12')),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Icon(Icons.history_rounded, size: 19, color: theme.primary),
              const SizedBox(width: 8),
              Text('Lịch sử bài đăng',
                  style: TextStyle(color: theme.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),
          if (posts.isEmpty)
            NivexCard(child: Text('Bạn chưa có bài đăng nào.', style: TextStyle(color: theme.textSecondary)))
          else
            for (final post in posts) ...[
              _PostCard(post: post, ownAvatarPath: avatarPath, onOpenProfile: () {}),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _PostStat extends StatelessWidget {
  const _PostStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(color: theme.primary, fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(label, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: theme.textSecondary, fontSize: 10.5)),
        ],
      ),
    );
  }
}

class _ProfilePickerSheet extends StatelessWidget {
  const _ProfilePickerSheet({required this.profiles, required this.onSelected});
  final List<PublicProfileData> profiles;
  final ValueChanged<PublicProfileData> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Khám phá hồ sơ', style: TextStyle(color: theme.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            for (final profile in profiles)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: theme.primary.withValues(alpha: 0.14),
                  child: Icon(profile.kind == PublicProfileKind.business ? Icons.business_outlined : Icons.person_outline_rounded, color: theme.primary),
                ),
                title: Text(profile.displayName),
                subtitle: Text(profile.headline, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => onSelected(profile),
              ),
          ],
        ),
      ),
    );
  }
}

class _PostComposer extends StatelessWidget {
  const _PostComposer({
    required this.controller,
    required this.images,
    required this.avatarPath,
    required this.isPublishing,
    required this.onPickImages,
    required this.onRemoveImage,
    required this.onPublish,
  });

  final TextEditingController controller;
  final List<XFile> images;
  final String? avatarPath;
  final bool isPublishing;
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemoveImage;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: theme.primary.withValues(alpha: 0.16),
                foregroundImage:
                    avatarPath == null ? null : FileImage(File(avatarPath!)),
                child: avatarPath == null
                    ? Icon(Icons.person_outline_rounded, color: theme.primary)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Minh Anh',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontWeight: FontWeight.w700,
                    )),
              ),
              Icon(Icons.public_rounded,
                  size: 16, color: theme.textSecondary),
              const SizedBox(width: 5),
              Text('Công khai',
                  style: TextStyle(color: theme.textSecondary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            minLines: 3,
            maxLines: 7,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Bạn đang làm gì, xây dựng gì hoặc muốn chia sẻ điều gì?',
              border: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ImagePreviewStrip(images: images, onRemove: onRemoveImage),
          ],
          const SizedBox(height: 12),
          Divider(height: 1, color: theme.divider),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isPublishing ? null : onPickImages,
                  icon: const Icon(Icons.photo_library_outlined, size: 19),
                  label: Text(images.isEmpty
                      ? 'Thêm ảnh'
                      : 'Thêm ảnh (${images.length}/10)'),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: isPublishing ? null : onPublish,
                icon: isPublishing
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, size: 17),
                label: const Text('Đăng bài'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImagePreviewStrip extends StatelessWidget {
  const _ImagePreviewStrip({required this.images, required this.onRemove});

  final List<XFile> images;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) => Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(images[index].path),
                width: 86,
                height: 86,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 86,
                  height: 86,
                  color: context.nivexTheme.surfaceSubtle,
                  child: Icon(Icons.broken_image_outlined,
                      color: context.nivexTheme.textSecondary),
                ),
              ),
            ),
            Positioned(
              top: -7,
              right: -7,
              child: IconButton(
                tooltip: 'Xóa ảnh',
                onPressed: () => onRemove(index),
                style: IconButton.styleFrom(
                  backgroundColor: context.nivexTheme.surface,
                  foregroundColor: context.nivexTheme.textPrimary,
                  side: BorderSide(color: context.nivexTheme.border),
                  minimumSize: const Size(26, 26),
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(Icons.close_rounded, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.ownAvatarPath,
    required this.onOpenProfile,
  });
  final _DemoPost post;
  final String? ownAvatarPath;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onOpenProfile,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.primary.withValues(alpha: 0.16),
                  foregroundImage: post.isMine && ownAvatarPath != null
                      ? FileImage(File(ownAvatarPath!))
                      : null,
                  child: post.isMine && ownAvatarPath != null
                      ? null
                      : Icon(
                          post.author.kind == PublicProfileKind.business
                              ? Icons.business_outlined
                              : Icons.person_outline_rounded,
                          color: theme.primary,
                        ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.isMine ? 'Minh Anh' : post.author.displayName,
                        style: TextStyle(
                            color: theme.textPrimary,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(post.timeLabel,
                        style: TextStyle(
                            color: theme.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              ],
            ),
          ),
          if (post.content.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(post.content,
                style: TextStyle(
                    color: theme.textPrimary, height: 1.45, fontSize: 14)),
          ],
          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            _PostGallery(images: post.images),
          ],
          const SizedBox(height: 12),
          Divider(height: 1, color: theme.divider),
          const SizedBox(height: 4),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border_rounded, size: 18),
                label: const Text('Thích'),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.mode_comment_outlined, size: 18),
                label: const Text('Bình luận'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostGallery extends StatelessWidget {
  const _PostGallery({required this.images});
  final List<XFile> images;

  @override
  Widget build(BuildContext context) {
    final count = images.length;
    final height = count == 1 ? 260.0 : 210.0;
    return SizedBox(
      height: height,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count == 1 ? 1 : 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: count > 4 ? 4 : count,
        itemBuilder: (context, index) => Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(images[index].path), fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                    color: context.nivexTheme.surfaceSubtle,
                    child: Icon(Icons.broken_image_outlined,
                        color: context.nivexTheme.textSecondary))),
            if (index == 3 && count > 4)
              ColoredBox(
                color: Colors.black54,
                child: Center(
                  child: Text('+${count - 4}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DemoPost {
  const _DemoPost({
    required this.content,
    required this.images,
    required this.timeLabel,
    this.isMine = true,
    this.author = const PublicProfileData(
      kind: PublicProfileKind.business,
      displayName: 'NIVEX Labs',
      handle: 'nivex.labs',
      headline: 'Fintech · Web3 · Remote-first',
      location: 'Đà Nẵng, Việt Nam',
      bio: 'Đội ngũ xây dựng sản phẩm tài chính số minh bạch cho freelancer và doanh nghiệp.',
      tags: ['Fintech', 'Solana', 'Remote-first'],
      stats: [],
    ),
  });
  final String content;
  final List<XFile> images;
  final String timeLabel;
  final bool isMine;
  final PublicProfileData author;
}
