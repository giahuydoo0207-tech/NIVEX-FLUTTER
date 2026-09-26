import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    _DemoPost(
      id: 'post-mine-001',
      content: 'Mình vừa hoàn thiện một flow thanh toán mới cho ứng dụng mobile. Rất vui được kết nối với các dự án fintech phù hợp.',
      images: const [],
      timeLabel: 'Hôm nay, 09:24',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      reactionCount: 12,
      reactionCounts: const {
        PostReaction.like: 7,
        PostReaction.love: 3,
        PostReaction.trust: 2,
      },
      comments: const [
        PostComment(
          id: 'c-mine-1',
          authorName: 'Trần Bảo Long',
          headline: 'Senior Product Manager @ Fintech VN',
          content: 'Flow thanh toán rất mượt, đặc biệt là phần xác thực hai lớp. Rất ấn tượng!',
          timeLabel: '1 giờ trước',
          likeCount: 4,
        ),
        PostComment(
          id: 'c-mine-2',
          authorName: 'Lê Thảo My',
          headline: 'UI/UX Designer',
          content:
              'Màu sắc và spacing trong flow nhìn rất gọn gàng và dễ theo dõi.',
          timeLabel: '45 phút trước',
          likeCount: 2,
        ),
      ],
    ),
    _DemoPost(
      id: 'post-nivex-002',
      content: 'Nova Labs đang tìm thêm freelancer cho các dự án fintech và sản phẩm Web3. Xem hồ sơ để tìm hiểu cơ hội hợp tác.',
      images: const [],
      timeLabel: 'Hôm qua, 18:40',
      isMine: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      reactionCount: 83,
      reactionCounts: const {
        PostReaction.like: 50,
        PostReaction.love: 20,
        PostReaction.deal: 13,
      },
      comments: const [
        PostComment(
          id: 'c-nivex-1',
          authorName: 'Phạm Hoàng Nam',
          headline: 'Web3 Developer · Solana ecosystem',
          content: 'Dự án đang tìm vị trí smart contract hay mobile vậy admin?',
          timeLabel: '2 giờ trước',
          likeCount: 5,
          replies: [
            PostCommentReply(
              id: 'r-nivex-1',
              authorName: 'Nova Labs',
              headline: 'Fintech · Web3 · Remote-first',
              content: 'Chào bạn, bên mình đang ưu tiên cả Flutter Dev và Solana Rust Dev nhé!',
              timeLabel: '1 giờ trước',
              replyingToName: 'Phạm Hoàng Nam',
              likeCount: 8,
            ),
          ],
        ),
      ],
      author: PublicProfileData(
        kind: PublicProfileKind.business,
        displayName: 'Nova Labs',
        handle: 'nova.labs',
        headline: 'Fintech · Web3 · Remote-first',
        location: 'Đà Nẵng, Việt Nam',
        bio: 'Đội ngũ xây dựng sản phẩm tài chính số minh bạch cho freelancer và doanh nghiệp.',
        tags: ['Fintech', 'Solana', 'Remote-first'],
        stats: [
          (label: 'Cơ hội đang mở', value: '3'),
          (label: 'Đã kết nối', value: '126'),
        ],
        status: 'Đang tuyển',
        isVerified: true,
        followerCount: 312,
        followingCount: 45,
        postCount: 18,
        openings: [
          BusinessOpening(
            title: 'Flutter Developer',
            type: 'Remote · Full-time',
            description: 'Xây dựng tính năng Wallet và Payment cho ứng dụng Nova Mobile.',
          ),
          BusinessOpening(
            title: 'Solana Rust Developer',
            type: 'Remote · Contract',
            description:
                'Phát triển smart contract cho hệ sinh thái DeFi của Nova.',
          ),
        ],
      ),
    ),
    _DemoPost(
      id: 'post-baolong-003',
      content: 'Sau 6 tháng dẫn dắt team product, mình nhận ra rằng clarity beats cleverness. Spec rõ ràng giúp cả team tiết kiệm hàng tuần làm lại.',
      images: const [],
      timeLabel: '3 ngày trước',
      isMine: false,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      reactionCount: 41,
      reactionCounts: const {
        PostReaction.like: 20,
        PostReaction.trust: 12,
        PostReaction.insightful: 9,
      },
      comments: const [
        PostComment(
          id: 'c-baolong-1',
          authorName: 'Lê Thảo My',
          headline: 'UI/UX Designer',
          content: 'Đồng ý! Spec mơ hồ là nguyên nhân 90% lần mình phải thiết kế lại.',
          timeLabel: '2 ngày trước',
          likeCount: 7,
        ),
      ],
      author: PublicProfileData(
        kind: PublicProfileKind.freelancer,
        displayName: 'Trần Bảo Long',
        handle: 'baolong.pm',
        headline: 'Senior Product Manager @ Fintech VN',
        location: 'Hà Nội, Việt Nam',
        bio: 'Product Manager với 5 năm kinh nghiệm trong lĩnh vực Fintech. Đam mê xây dựng sản phẩm rõ ràng và có tác động thực sự.',
        tags: [
          'Product Management',
          'Agile',
          'Fintech',
          'OKRs',
          'User Research',
        ],
        stats: [
          (label: 'Dự án đã dẫn dắt', value: '14'),
          (label: 'Tỷ lệ on-time', value: '91%'),
        ],
        status: 'Đang mở cơ hội',
        isVerified: false,
        followerCount: 183,
        followingCount: 67,
        postCount: 29,
        experiences: [
          ProfileExperience(
            title: 'Senior Product Manager',
            organization: 'Fintech VN',
            period: '2022 - nay',
            summary: 'Quản lý roadmap sản phẩm payment và lending. Dẫn dắt nhóm 8 người cross-functional.',
          ),
          ProfileExperience(
            title: 'Product Manager',
            organization: 'VNG Corporation',
            period: '2019 - 2022',
            summary: 'Xây dựng tính năng ZaloPay B2B từ 0 đến 50K merchants.',
          ),
        ],
        education: [
          ProfileEducation(
            program: 'Quản trị Kinh doanh',
            institution: 'Đại học Ngoại thương Hà Nội',
            period: '2015 - 2019',
          ),
        ],
      ),
    ),
  ];
  bool _isPublishing = false;
  final Set<String> _followedHandles = {};
  final Set<String> _blockedHandles = {};

  @override
  void initState() {
    super.initState();
    _sortPosts();
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
    final visiblePosts = _posts
        .where((p) => !p.isHidden && !_blockedHandles.contains(p.author.handle))
        .toList();
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
      child: RefreshIndicator(
        color: context.nivexTheme.primary,
        backgroundColor: context.nivexTheme.surface,
        onRefresh: _refreshFeed,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: _PostComposer(
                controller: _composerController,
                images: _selectedImages,
                displayName: _profileController.profile.displayName,
                avatarPath: _profileController.profile.avatarPath,
                isPublishing: _isPublishing,
                onPickImages: _pickImages,
                onRemoveImage: (index) =>
                    setState(() => _selectedImages.removeAt(index)),
                onPublish: _publish,
              ),
            ),
            const SizedBox(height: 10),
            Container(height: 7, color: context.nivexTheme.surfaceSubtle),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  Icon(
                    Icons.dynamic_feed_outlined,
                    size: 19,
                    color: context.nivexTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dành cho bạn',
                    style: TextStyle(
                      color: context.nivexTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (visiblePosts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: NivexCard(
                  child: Center(
                    child: Text(
                      'Hiện chưa có bài đăng nào trong bảng tin.',
                      style: TextStyle(color: context.nivexTheme.textSecondary),
                    ),
                  ),
                ),
              )
            else
              for (final post in visiblePosts) ...[
                _PostCard(
                  key: ValueKey(
                    post.id ??
                        post.createdAt?.millisecondsSinceEpoch ??
                        post.content,
                  ),
                  post: post,
                  ownAvatarPath: _profileController.profile.avatarPath,
                  ownDisplayName: _profileController.profile.displayName,
                  ownHeadline: _profileController.profile.headline,
                  onOpenProfile: () => _openProfile(_postAuthor(post)),
                  isFollowingAuthor:
                      !post.isMine &&
                      _followedHandles.contains(_postAuthor(post).handle),
                  onToggleFollowAuthor: !post.isMine
                      ? () => _toggleFollow(_postAuthor(post).handle)
                      : null,
                  onTogglePin: () => _togglePinPost(post),
                  onToggleSave: () => _toggleSavePost(post),
                  onHide: () => _hidePost(post),
                  onDeletePost: () => _deletePost(post),
                  onBlockUser: () => _blockUser(_postAuthor(post).handle),
                  onReact: (reaction) => _reactToPost(post, reaction),
                  onAddComment: (comment) => _addCommentToPost(post, comment),
                  onAddReply: (parentId, reply) =>
                      _addReplyToComment(post, parentId, reply),
                  onToggleCommentLike: (commentId) =>
                      _toggleCommentLike(post, commentId),
                ),
                Container(height: 7, color: context.nivexTheme.surfaceSubtle),
              ],
          ],
        ),
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
      if (mounted) {
        _showMessage('Không thể mở thư viện ảnh. Hãy kiểm tra quyền truy cập.');
      }
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
          id: 'post-${DateTime.now().millisecondsSinceEpoch}',
          content: content,
          images: List<XFile>.from(_selectedImages),
          timeLabel: 'Vừa xong',
          createdAt: DateTime.now(),
        ),
      );
      _sortPosts();
      _composerController.clear();
      _selectedImages.clear();
      _isPublishing = false;
    });
    _showMessage('Đã đăng bài trong bản thử nghiệm.');
  }

  void _sortPosts() {
    _posts.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      final timeA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final timeB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return timeB.compareTo(timeA);
    });
  }

  Future<void> _refreshFeed() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    setState(() {
      _sortPosts();
    });

    _showMessage('Đã làm mới bảng tin.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 2200),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  void _togglePinPost(_DemoPost targetPost) {
    setState(() {
      final index = _posts.indexWhere((p) => p.id == targetPost.id);
      if (index == -1) return;
      _posts[index] = _posts[index].copyWith(isPinned: !_posts[index].isPinned);
      _sortPosts();
    });
  }

  void _toggleSavePost(_DemoPost targetPost) {
    setState(() {
      final index = _posts.indexWhere((p) => p.id == targetPost.id);
      if (index == -1) return;
      _posts[index] = _posts[index].copyWith(isSaved: !_posts[index].isSaved);
    });
  }

  void _hidePost(_DemoPost targetPost) {
    setState(() {
      final index = _posts.indexWhere((p) => p.id == targetPost.id);
      if (index == -1) return;
      _posts[index] = _posts[index].copyWith(isHidden: true);
    });
  }

  void _deletePost(_DemoPost targetPost) {
    setState(() {
      _posts.removeWhere((p) => p.id == targetPost.id);
    });
  }

  void _blockUser(String authorHandle) {
    setState(() {
      _blockedHandles.add(authorHandle);
      _followedHandles.remove(authorHandle);
    });
  }

  void _restorePost(_DemoPost targetPost) {
    setState(() {
      final index = _posts.indexWhere((p) => p.id == targetPost.id);
      if (index == -1) return;
      _posts[index] = _posts[index].copyWith(isHidden: false);
    });
  }

  void _reactToPost(_DemoPost targetPost, PostReaction selectedReaction) {
    setState(() {
      final index = _posts.indexWhere((p) => p.id == targetPost.id);
      if (index == -1) return;
      final current = _posts[index];

      final reactionCounts = Map<PostReaction, int>.from(
        current.reactionCounts,
      );
      PostReaction? newReaction;
      bool clearMyReaction = false;

      if (current.myReaction == null) {
        reactionCounts.update(
          selectedReaction,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
        newReaction = selectedReaction;
      } else if (current.myReaction == selectedReaction) {
        reactionCounts.update(
          selectedReaction,
          (count) => (count - 1).clamp(0, 999999),
          ifAbsent: () => 0,
        );
        newReaction = null;
        clearMyReaction = true;
      } else {
        reactionCounts.update(
          current.myReaction!,
          (count) => (count - 1).clamp(0, 999999),
          ifAbsent: () => 0,
        );
        reactionCounts.update(
          selectedReaction,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
        newReaction = selectedReaction;
      }

      final newCount = reactionCounts.values.fold<int>(
        0,
        (sum, count) => sum + count,
      );

      _posts[index] = current.copyWith(
        reactionCount: newCount,
        reactionCounts: reactionCounts,
        myReaction: newReaction,
        clearMyReaction: clearMyReaction,
      );
    });
  }

  void _addCommentToPost(_DemoPost targetPost, PostComment comment) {
    setState(() {
      final index = _posts.indexWhere((p) => p.id == targetPost.id);
      if (index == -1) return;
      final current = _posts[index];
      final updatedComments = List<PostComment>.from(current.comments)
        ..insert(0, comment);
      _posts[index] = current.copyWith(comments: updatedComments);
    });
  }

  void _addReplyToComment(
    _DemoPost targetPost,
    String parentCommentId,
    PostCommentReply reply,
  ) {
    setState(() {
      final postIndex = _posts.indexWhere((p) => p.id == targetPost.id);
      if (postIndex == -1) return;
      final currentPost = _posts[postIndex];
      final updatedComments = currentPost.comments.map((c) {
        if (c.id == parentCommentId) {
          return c.copyWith(replies: [...c.replies, reply]);
        }
        return c;
      }).toList();
      _posts[postIndex] = currentPost.copyWith(comments: updatedComments);
    });
  }

  void _toggleCommentLike(_DemoPost targetPost, String commentOrReplyId) {
    setState(() {
      final postIndex = _posts.indexWhere((p) => p.id == targetPost.id);
      if (postIndex == -1) return;
      final currentPost = _posts[postIndex];
      final updatedComments = currentPost.comments.map((c) {
        if (c.id == commentOrReplyId) {
          final isLiked = !c.isLiked;
          final newLikes = isLiked
              ? c.likeCount + 1
              : (c.likeCount - 1).clamp(0, 999999);
          return c.copyWith(isLiked: isLiked, likeCount: newLikes);
        }
        final updatedReplies = c.replies.map((r) {
          if (r.id == commentOrReplyId) {
            final isLiked = !r.isLiked;
            final newLikes = isLiked
                ? r.likeCount + 1
                : (r.likeCount - 1).clamp(0, 999999);
            return r.copyWith(isLiked: isLiked, likeCount: newLikes);
          }
          return r;
        }).toList();
        return c.copyWith(replies: updatedReplies);
      }).toList();
      _posts[postIndex] = currentPost.copyWith(comments: updatedComments);
    });
  }

  PublicProfileData _postAuthor(_DemoPost post) {
    return _buildAuthorForPost(post);
  }

  void _toggleFollow(String handle) {
    final wasFollowing = _followedHandles.contains(handle);
    setState(() {
      if (wasFollowing) {
        _followedHandles.remove(handle);
      } else {
        _followedHandles.add(handle);
      }
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            wasFollowing ? 'Đã bỏ theo dõi @$handle' : 'Đã theo dõi @$handle',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 2000),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  void _openProfile(PublicProfileData profile) {
    final postsForProfile = profile.isSelf
        ? _posts
              .where((p) => p.isMine && !p.isHidden)
              .map(
                (p) => CompactPost(
                  content: p.content,
                  timeLabel: p.timeLabel,
                  reactionCount: p.reactionCount,
                  commentCount: p.comments.fold<int>(
                    0,
                    (sum, c) => sum + 1 + c.replies.length,
                  ),
                  imageCount: p.images.length,
                ),
              )
              .toList()
        : _posts
              .where(
                (p) =>
                    !p.isMine &&
                    p.author.handle == profile.handle &&
                    !p.isHidden,
              )
              .map(
                (p) => CompactPost(
                  content: p.content,
                  timeLabel: p.timeLabel,
                  reactionCount: p.reactionCount,
                  commentCount: p.comments.fold<int>(
                    0,
                    (sum, c) => sum + 1 + c.replies.length,
                  ),
                  imageCount: p.images.length,
                ),
              )
              .toList();

    Navigator.of(context)
        .push<void>(
          MaterialPageRoute(
            builder: (_) => PublicProfileScreen(
              profile: profile,
              profilePosts: postsForProfile,
              isFollowing: _followedHandles.contains(profile.handle),
              onToggleFollow: () => _toggleFollow(profile.handle),
            ),
          ),
        )
        .then((_) {
          if (mounted) setState(() {});
        });
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
      displayName: 'Nova Labs',
      handle: 'nova.labs',
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
    Navigator.of(context)
        .push<void>(
          MaterialPageRoute(
            builder: (_) => _MyPostsScreen(
              allPosts: _posts,
              avatarPath: _profileController.profile.avatarPath,
              displayName: _profileController.profile.displayName,
              headline: _profileController.profile.headline,
              onTogglePin: _togglePinPost,
              onToggleSave: _toggleSavePost,
              onHide: _hidePost,
              onDelete: _deletePost,
              onBlock: _blockUser,
              onRestore: _restorePost,
              onOpenProfile: _openProfile,
              onReact: _reactToPost,
              onAddComment: _addCommentToPost,
              onAddReply: _addReplyToComment,
              onToggleCommentLike: _toggleCommentLike,
            ),
          ),
        )
        .then((_) {
          if (mounted) setState(() {});
        });
  }
}

PublicProfileData _buildAuthorForPost(_DemoPost post) {
  if (!post.isMine) return post.author;
  final p = DemoFreelancerProfileController.instance.profile;
  return PublicProfileData(
    kind: PublicProfileKind.freelancer,
    displayName: p.displayName,
    handle: p.username,
    headline: p.headline,
    location: p.location,
    bio: p.bio,
    tags: p.skills,
    avatarPath: p.avatarPath,
    coverPath: p.coverPath,
    isSelf: true,
    isVerified: true,
    followerCount: 48,
    followingCount: 12,
    postCount: 5,
    stats: [
      (label: 'Năng lực mỗi tuần', value: '${p.weeklyCapacityHours} giờ'),
      (label: 'Hình thức', value: p.workPreference),
    ],
    status: p.isAvailable ? 'Sẵn sàng nhận việc' : 'Đang bận',
    experiences: [
      for (final e in p.experiences)
        ProfileExperience(
          title: e.title,
          organization: e.organization,
          period: e.period,
          summary: e.summary,
        ),
    ],
    education: [
      for (final e in p.education)
        ProfileEducation(
          program: e.program,
          institution: e.institution,
          period: e.period,
        ),
    ],
    portfolio: [
      for (final proj in p.projects)
        ProfilePortfolio(
          title: proj.title,
          role: proj.role,
          summary: proj.summary,
          technologies: proj.technologies,
          status: proj.status,
        ),
    ],
  );
}

class _MyPostsScreen extends StatefulWidget {
  const _MyPostsScreen({
    required this.allPosts,
    required this.avatarPath,
    required this.displayName,
    required this.headline,
    this.onTogglePin,
    this.onToggleSave,
    this.onHide,
    this.onDelete,
    this.onBlock,
    this.onRestore,
    this.onOpenProfile,
    this.onReact,
    this.onAddComment,
    this.onAddReply,
    this.onToggleCommentLike,
  });

  final List<_DemoPost> allPosts;
  final String? avatarPath;
  final String displayName;
  final String headline;
  final void Function(_DemoPost post)? onTogglePin;
  final void Function(_DemoPost post)? onToggleSave;
  final void Function(_DemoPost post)? onHide;
  final void Function(_DemoPost post)? onDelete;
  final void Function(String authorHandle)? onBlock;
  final void Function(_DemoPost post)? onRestore;
  final ValueChanged<PublicProfileData>? onOpenProfile;
  final void Function(_DemoPost post, PostReaction reaction)? onReact;
  final void Function(_DemoPost post, PostComment comment)? onAddComment;
  final void Function(_DemoPost post, String parentId, PostCommentReply reply)?
  onAddReply;
  final void Function(_DemoPost post, String commentId)? onToggleCommentLike;

  @override
  State<_MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<_MyPostsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;

    final publishedPosts = widget.allPosts
        .where((p) => p.isMine && !p.isHidden)
        .toList();
    publishedPosts.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      final timeA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final timeB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return timeB.compareTo(timeA);
    });

    final savedPosts = widget.allPosts.where((p) => p.isSaved).toList();
    savedPosts.sort((a, b) {
      final timeA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final timeB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return timeB.compareTo(timeA);
    });

    final hiddenPosts = widget.allPosts
        .where((p) => p.isHidden && p.isMine)
        .toList();
    hiddenPosts.sort((a, b) {
      final timeA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final timeB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return timeB.compareTo(timeA);
    });

    return DefaultTabController(
      length: 3,
      child: NivexPage(
        title: 'Bài đăng của tôi',
        subtitle: 'Quản lý lịch sử, bài đã lưu và bài ẩn',
        showBackButton: true,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _PostStat(
                      label: 'Đã đăng',
                      value: '${publishedPosts.length}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PostStat(
                      label: 'Đã lưu',
                      value: '${savedPosts.length}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PostStat(
                      label: 'Đã ẩn',
                      value: '${hiddenPosts.length}',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Đã đăng',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        if (publishedPosts.isNotEmpty) ...[
                          const SizedBox(width: 5),
                          _TabBadge(count: publishedPosts.length),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Đã lưu',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        if (savedPosts.isNotEmpty) ...[
                          const SizedBox(width: 5),
                          _TabBadge(count: savedPosts.length),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Đã ẩn',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        if (hiddenPosts.isNotEmpty) ...[
                          const SizedBox(width: 5),
                          _TabBadge(count: hiddenPosts.length),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Đã đăng
                  publishedPosts.isEmpty
                      ? const _EmptyTabState(
                          icon: Icons.article_outlined,
                          title: 'Chưa có bài đăng nào',
                          subtitle: 'Các bài đăng bạn chia sẻ với cộng đồng sẽ xuất hiện tại đây.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(top: 8, bottom: 32),
                          itemCount: publishedPosts.length,
                          separatorBuilder: (_, _) =>
                              Container(height: 7, color: theme.surfaceSubtle),
                          itemBuilder: (context, index) {
                            final post = publishedPosts[index];
                            return _PostCard(
                              key: ValueKey(
                                post.id ??
                                    post.createdAt?.millisecondsSinceEpoch ??
                                    post.content,
                              ),
                              post: post,
                              ownAvatarPath: widget.avatarPath,
                              ownDisplayName: widget.displayName,
                              ownHeadline: widget.headline,
                              onOpenProfile: () => widget.onOpenProfile?.call(
                                _buildAuthorForPost(post),
                              ),
                              onTogglePin: () {
                                widget.onTogglePin?.call(post);
                                setState(() {});
                              },
                              onToggleSave: () {
                                widget.onToggleSave?.call(post);
                                setState(() {});
                              },
                              onHide: () {
                                widget.onHide?.call(post);
                                setState(() {});
                              },
                              onDeletePost: () {
                                widget.onDelete?.call(post);
                                setState(() {});
                              },
                              onBlockUser: () {
                                widget.onBlock?.call(_buildAuthorForPost(post).handle);
                                setState(() {});
                              },
                              onReact: (reaction) {
                                widget.onReact?.call(post, reaction);
                                setState(() {});
                              },
                              onAddComment: (comment) {
                                widget.onAddComment?.call(post, comment);
                                setState(() {});
                              },
                              onAddReply: (parentId, reply) {
                                widget.onAddReply?.call(post, parentId, reply);
                                setState(() {});
                              },
                              onToggleCommentLike: (commentId) {
                                widget.onToggleCommentLike?.call(
                                  post,
                                  commentId,
                                );
                                setState(() {});
                              },
                            );
                          },
                        ),

                  // Tab 2: Đã lưu
                  savedPosts.isEmpty
                      ? const _EmptyTabState(
                          icon: Icons.bookmark_border_rounded,
                          title: 'Chưa có bài viết đã lưu',
                          subtitle: 'Lưu các bài viết quan trọng từ bảng tin để xem lại sau bất cứ lúc nào.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(top: 8, bottom: 32),
                          itemCount: savedPosts.length,
                          separatorBuilder: (_, _) =>
                              Container(height: 7, color: theme.surfaceSubtle),
                          itemBuilder: (context, index) {
                            final post = savedPosts[index];
                            return _PostCard(
                              key: ValueKey(
                                post.id ??
                                    post.createdAt?.millisecondsSinceEpoch ??
                                    post.content,
                              ),
                              post: post,
                              ownAvatarPath: widget.avatarPath,
                              ownDisplayName: widget.displayName,
                              ownHeadline: widget.headline,
                              onOpenProfile: () => widget.onOpenProfile?.call(
                                _buildAuthorForPost(post),
                              ),
                              onTogglePin: () {
                                widget.onTogglePin?.call(post);
                                setState(() {});
                              },
                              onToggleSave: () {
                                widget.onToggleSave?.call(post);
                                setState(() {});
                              },
                              onHide: () {
                                widget.onHide?.call(post);
                                setState(() {});
                              },
                              onDeletePost: () {
                                widget.onDelete?.call(post);
                                setState(() {});
                              },
                              onBlockUser: () {
                                widget.onBlock?.call(_buildAuthorForPost(post).handle);
                                setState(() {});
                              },
                              onReact: (reaction) {
                                widget.onReact?.call(post, reaction);
                                setState(() {});
                              },
                              onAddComment: (comment) {
                                widget.onAddComment?.call(post, comment);
                                setState(() {});
                              },
                              onAddReply: (parentId, reply) {
                                widget.onAddReply?.call(post, parentId, reply);
                                setState(() {});
                              },
                              onToggleCommentLike: (commentId) {
                                widget.onToggleCommentLike?.call(
                                  post,
                                  commentId,
                                );
                                setState(() {});
                              },
                            );
                          },
                        ),

                  // Tab 3: Đã ẩn
                  hiddenPosts.isEmpty
                      ? const _EmptyTabState(
                          icon: Icons.visibility_off_outlined,
                          title: 'Không có bài viết nào bị ẩn',
                          subtitle: 'Các bài viết bạn đã ẩn khỏi bảng tin và trang cá nhân sẽ hiển thị ở đây.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                          itemCount: hiddenPosts.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final post = hiddenPosts[index];
                            return _HiddenPostCard(
                              post: post,
                              ownAvatarPath: widget.avatarPath,
                              ownDisplayName: widget.displayName,
                              onRestore: () {
                                widget.onRestore?.call(post);
                                setState(() {});
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Đã khôi phục bài viết về bảng tin.',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(
                                        milliseconds: 2200,
                                      ),
                                      margin: const EdgeInsets.fromLTRB(
                                        16,
                                        0,
                                        16,
                                        24,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                              },
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBadge extends StatelessWidget {
  const _TabBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: theme.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyTabState extends StatelessWidget {
  const _EmptyTabState({
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

class _HiddenPostCard extends StatelessWidget {
  const _HiddenPostCard({
    required this.post,
    required this.ownAvatarPath,
    required this.ownDisplayName,
    required this.onRestore,
  });

  final _DemoPost post;
  final String? ownAvatarPath;
  final String ownDisplayName;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final authorName = post.isMine ? ownDisplayName : post.author.displayName;

    return NivexCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor:
                    (!post.isMine &&
                        post.author.kind == PublicProfileKind.business)
                    ? theme.warning.withValues(alpha: 0.14)
                    : theme.primary.withValues(alpha: 0.12),
                foregroundImage: (post.isMine && ownAvatarPath != null)
                    ? FileImage(File(ownAvatarPath!))
                    : null,
                child: (post.isMine && ownAvatarPath != null)
                    ? null
                    : Icon(
                        (!post.isMine &&
                                post.author.kind == PublicProfileKind.business)
                            ? Icons.business_outlined
                            : Icons.person_outline_rounded,
                        color:
                            (!post.isMine &&
                                post.author.kind == PublicProfileKind.business)
                            ? theme.warning
                            : theme.primary,
                        size: 20,
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      post.timeLabel,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.visibility_off_outlined,
                      size: 12,
                      color: Colors.amber.shade800,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Đã ẩn',
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
                height: 1.4,
              ),
            ),
          ],
          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.image_outlined,
                  size: 14,
                  color: theme.textSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  '${post.images.length} hình ảnh đính kèm',
                  style: TextStyle(color: theme.textSecondary, fontSize: 11.5),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.primary,
                side: BorderSide(color: theme.primary.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onRestore,
              icon: const Icon(Icons.restore_rounded, size: 16),
              label: const Text(
                'Khôi phục bài viết',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
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
          Text(
            value,
            style: TextStyle(
              color: theme.primary,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: theme.textSecondary, fontSize: 10.5),
          ),
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
            Text(
              'Khám phá hồ sơ',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            for (final profile in profiles)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: profile.kind == PublicProfileKind.business
                      ? theme.warning.withValues(alpha: 0.14)
                      : theme.primary.withValues(alpha: 0.12),
                  child: Icon(
                    profile.kind == PublicProfileKind.business
                        ? Icons.business_outlined
                        : Icons.person_outline_rounded,
                    color: profile.kind == PublicProfileKind.business
                        ? theme.warning
                        : theme.primary,
                    size: 20,
                  ),
                ),
                title: Text(profile.displayName),
                subtitle: Text(
                  profile.headline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
    required this.displayName,
    required this.avatarPath,
    required this.isPublishing,
    required this.onPickImages,
    required this.onRemoveImage,
    required this.onPublish,
  });

  final TextEditingController controller;
  final List<XFile> images;
  final String displayName;
  final String? avatarPath;
  final bool isPublishing;
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemoveImage;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return NivexCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Semantics(
                label: 'Ảnh đại diện của $displayName',
                child: CircleAvatar(
                  radius: 23,
                  backgroundColor: theme.primary.withValues(alpha: 0.12),
                  foregroundImage: avatarPath != null
                      ? FileImage(File(avatarPath!))
                      : null,
                  child: avatarPath == null
                      ? Icon(
                          Icons.person_outline_rounded,
                          color: theme.primary,
                          size: 24,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Bắt đầu một bài đăng',
                    filled: true,
                    fillColor: theme.surfaceSubtle,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: theme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: theme.border),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ImagePreviewStrip(images: images, onRemove: onRemoveImage),
          ],
          const SizedBox(height: 12),
          Divider(height: 1, color: theme.divider),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 2,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton.icon(
                onPressed: isPublishing ? null : onPickImages,
                icon: Icon(
                  Icons.image_outlined,
                  size: 20,
                  color: theme.success,
                ),
                label: Text(
                  images.isEmpty ? 'Ảnh' : 'Ảnh (${images.length}/10)',
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.tag_rounded, size: 19, color: theme.primary),
                label: const Text('Chủ đề'),
              ),
              const SizedBox(width: 4),
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  final hasContent =
                      controller.text.trim().isNotEmpty || images.isNotEmpty;
                  final canPublish = !isPublishing && hasContent;
                  return FilledButton(
                    onPressed: canPublish ? onPublish : null,
                    child: isPublishing
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Đăng'),
                  );
                },
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
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: context.nivexTheme.textSecondary,
                  ),
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

class _PostCard extends StatefulWidget {
  const _PostCard({
    super.key,
    required this.post,
    required this.ownAvatarPath,
    required this.ownDisplayName,
    required this.ownHeadline,
    required this.onOpenProfile,
    this.isFollowingAuthor = false,
    this.onToggleFollowAuthor,
    this.onTogglePin,
    this.onToggleSave,
    this.onHide,
    this.onDeletePost,
    this.onBlockUser,
    this.onReact,
    this.onAddComment,
    this.onAddReply,
    this.onToggleCommentLike,
  });

  final _DemoPost post;
  final String? ownAvatarPath;
  final String ownDisplayName;
  final String ownHeadline;
  final VoidCallback onOpenProfile;
  final bool isFollowingAuthor;
  final VoidCallback? onToggleFollowAuthor;
  final VoidCallback? onTogglePin;
  final VoidCallback? onToggleSave;
  final VoidCallback? onHide;
  final VoidCallback? onDeletePost;
  final VoidCallback? onBlockUser;
  final ValueChanged<PostReaction>? onReact;
  final ValueChanged<PostComment>? onAddComment;
  final void Function(String parentId, PostCommentReply reply)? onAddReply;
  final ValueChanged<String>? onToggleCommentLike;

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _showReactionPicker = false;
  int? _hoveredIndex;
  Timer? _longPressTimer;
  Offset? _pointerDownPosition;
  final GlobalKey _pickerKey = GlobalKey();

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  void _updateHoveredFromGlobal(Offset globalPos) {
    final renderBox =
        _pickerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;
    final localPos = renderBox.globalToLocal(globalPos);

    if (localPos.dy >= -70 && localPos.dy <= 100) {
      final itemWidth = renderBox.size.width / PostReaction.values.length;
      final rawIndex = (localPos.dx / itemWidth).floor();
      if (rawIndex >= 0 && rawIndex < PostReaction.values.length) {
        if (_hoveredIndex != rawIndex) {
          HapticFeedback.selectionClick();
          setState(() => _hoveredIndex = rawIndex);
        }
        return;
      }
    }
    if (_hoveredIndex != null) {
      setState(() => _hoveredIndex = null);
    }
  }

  void _openComments(BuildContext context) {
    if (_showReactionPicker) {
      setState(() => _showReactionPicker = false);
    }
    _showCommentSheet(
      context,
      post: widget.post,
      ownAvatarPath: widget.ownAvatarPath,
      ownDisplayName: widget.ownDisplayName,
      ownHeadline: widget.ownHeadline,
      onAddComment: (comment) => widget.onAddComment?.call(comment),
      onAddReply: (parentId, reply) => widget.onAddReply?.call(parentId, reply),
      onToggleCommentLike: (commentId) =>
          widget.onToggleCommentLike?.call(commentId),
    );
  }

  void _showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1800),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final post = widget.post;
    final authorName = post.isMine
        ? widget.ownDisplayName
        : post.author.displayName;
    final authorHeadline = post.isMine
        ? widget.ownHeadline
        : post.author.headline;

    return Material(
      color: theme.surface,
      clipBehavior: Clip.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.isPinned) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  Icon(Icons.push_pin_rounded, size: 14, color: theme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Bài viết đã ghim',
                    style: TextStyle(
                      color: theme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 10, 0),
            child: InkWell(
              onTap: widget.onOpenProfile,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        (!post.isMine &&
                            post.author.kind == PublicProfileKind.business)
                        ? theme.warning.withValues(alpha: 0.14)
                        : theme.primary.withValues(alpha: 0.12),
                    foregroundImage:
                        (post.isMine && widget.ownAvatarPath != null)
                        ? FileImage(File(widget.ownAvatarPath!))
                        : null,
                    child: (post.isMine && widget.ownAvatarPath != null)
                        ? null
                        : Icon(
                            (!post.isMine &&
                                    post.author.kind ==
                                        PublicProfileKind.business)
                                ? Icons.business_outlined
                                : Icons.person_outline_rounded,
                            color:
                                (!post.isMine &&
                                    post.author.kind ==
                                        PublicProfileKind.business)
                                ? theme.warning
                                : theme.primary,
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                Row(
                          children: [
                            Flexible(
                              child: Text(
                                authorName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              Icons.verified_rounded,
                              color: theme.primary,
                              size: 15,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          authorHeadline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              post.timeLabel,
                              style: TextStyle(
                                color: theme.textSecondary,
                                fontSize: 10.5,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              Icons.public_rounded,
                              color: theme.textSecondary,
                              size: 12,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                      tooltip: 'Tùy chọn bài đăng',
                      onPressed: () => _showPostOptionsSheet(
                        context,
                        post,
                        onTogglePin: widget.onTogglePin,
                        onToggleSave: widget.onToggleSave,
                        onHide: widget.onHide,
                        onDeletePost: widget.onDeletePost,
                        onBlockUser: widget.onBlockUser,
                        onToggleFollow: widget.onToggleFollowAuthor,
                        isFollowing: widget.isFollowingAuthor,
                      ),
                      icon: const Icon(Icons.more_horiz_rounded),
                    ),
                ],
              ),
            ),
          ),
          if (post.content.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ExpandablePostContent(text: post.content),
            ),
          ],
          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            _PostGallery(images: post.images),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _ReactionBadgesStack(
                  reactionCounts: post.reactionCounts,
                ),
                const Spacer(),
                InkWell(
                  onTap: () => _openComments(context),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 4,
                    ),
                    child: Text(
                      '${post.comments.fold<int>(0, (sum, c) => sum + 1 + c.replies.length)} bình luận',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.divider),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: (event) {
                          _pointerDownPosition = event.position;
                          _longPressTimer?.cancel();
                          _longPressTimer = Timer(
                            const Duration(milliseconds: 260),
                            () {
                              HapticFeedback.mediumImpact();
                              setState(() {
                                _showReactionPicker = true;
                                _hoveredIndex = null;
                              });
                            },
                          );
                        },
                        onPointerMove: (event) {
                          if (!_showReactionPicker) {
                            if (_pointerDownPosition != null &&
                                (event.position - _pointerDownPosition!)
                                        .distance >
                                    14) {
                              _longPressTimer?.cancel();
                            }
                          } else {
                            _updateHoveredFromGlobal(event.position);
                          }
                        },
                        onPointerUp: (event) {
                          final wasTimerActive =
                              _longPressTimer?.isActive ?? false;
                          _longPressTimer?.cancel();

                          if (_showReactionPicker) {
                            if (_hoveredIndex != null) {
                              HapticFeedback.lightImpact();
                              widget.onReact?.call(
                                PostReaction.values[_hoveredIndex!],
                              );
                              setState(() {
                                _showReactionPicker = false;
                                _hoveredIndex = null;
                              });
                            }
                            return;
                          }

                          if (wasTimerActive) {
                            HapticFeedback.selectionClick();
                            if (widget.post.myReaction == null) {
                              widget.onReact?.call(PostReaction.like);
                            } else {
                              widget.onReact?.call(widget.post.myReaction!);
                            }
                          }
                        },
                        onPointerCancel: (_) {
                          _longPressTimer?.cancel();
                        },
                        child: _ReactionButton(myReaction: post.myReaction),
                      ),
                    ),
                    Expanded(
                      child: _PostAction(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Bình luận',
                        onTap: () => _openComments(context),
                      ),
                    ),
                    Expanded(
                      child: _PostAction(
                        icon: Icons.repeat_rounded,
                        label: 'Đăng lại',
                        onTap: () => _showNotice(
                          context,
                          'Tính năng Đăng lại sẽ được kết nối sau.',
                        ),
                      ),
                    ),
                    Expanded(
                      child: _PostAction(
                        icon: Icons.send_outlined,
                        label: 'Gửi',
                        onTap: () => _showNotice(
                          context,
                          'Tính năng Gửi tin nhắn sẽ được kết nối sau.',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_showReactionPicker)
                Positioned(
                  left: 8,
                  bottom: 52,
                  child: TapRegion(
                    onTapOutside: (_) {
                      if (_showReactionPicker) {
                        setState(() {
                          _showReactionPicker = false;
                          _hoveredIndex = null;
                        });
                      }
                    },
                    child: _ReactionPickerPill(
                      key: _pickerKey,
                      hoveredIndex: _hoveredIndex,
                      onHoverChanged: (index) {
                        if (_hoveredIndex != index) {
                          if (index != null) HapticFeedback.selectionClick();
                          setState(() => _hoveredIndex = index);
                        }
                      },
                      onSelect: (reaction) {
                        HapticFeedback.lightImpact();
                        widget.onReact?.call(reaction);
                        setState(() {
                          _showReactionPicker = false;
                          _hoveredIndex = null;
                        });
                      },
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({required this.myReaction});

  final PostReaction? myReaction;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final isReacted = myReaction != null;
    final color = isReacted ? myReaction!.color : theme.textSecondary;
    final icon = isReacted ? myReaction!.icon : Icons.thumb_up_alt_outlined;
    final label = isReacted ? myReaction!.label : 'Thích';

    return SizedBox(
      height: 48,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 9.5,
              fontWeight: isReacted ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactionPickerPill extends StatefulWidget {
  const _ReactionPickerPill({
    required this.hoveredIndex,
    required this.onHoverChanged,
    required this.onSelect,
    super.key,
  });

  final int? hoveredIndex;
  final ValueChanged<int?> onHoverChanged;
  final ValueChanged<PostReaction> onSelect;

  @override
  State<_ReactionPickerPill> createState() => _ReactionPickerPillState();
}

class _ReactionPickerPillState extends State<_ReactionPickerPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handlePointerMove(Offset globalPos) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;
    final localPos = renderBox.globalToLocal(globalPos);
    if (localPos.dy >= -70 && localPos.dy <= 100) {
      final itemWidth = renderBox.size.width / PostReaction.values.length;
      final rawIndex = (localPos.dx / itemWidth).floor();
      if (rawIndex >= 0 && rawIndex < PostReaction.values.length) {
        widget.onHoverChanged(rawIndex);
        return;
      }
    }
    widget.onHoverChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1.0 - _scaleAnimation.value)),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            alignment: const Alignment(-0.75, 1.0),
            child: Opacity(
              opacity: _fadeAnimation.value.clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) => _handlePointerMove(event.position),
        onPointerMove: (event) => _handlePointerMove(event.position),
        onPointerUp: (event) {
          if (widget.hoveredIndex != null) {
            widget.onSelect(PostReaction.values[widget.hoveredIndex!]);
          }
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: theme.primary.withValues(alpha: 0.45),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: theme.primary.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(PostReaction.values.length, (index) {
                final reaction = PostReaction.values[index];
                final isHovered = widget.hoveredIndex == index;
                return _ReactionItem(reaction: reaction, isHovered: isHovered);
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReactionItem extends StatelessWidget {
  const _ReactionItem({required this.reaction, required this.isHovered});

  final PostReaction reaction;
  final bool isHovered;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Reaction Icon with Lift & Scale Animation
          AnimatedPositioned(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutBack,
            top: isHovered ? -24 : 4,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOutBack,
              scale: isHovered ? 1.85 : 1.0,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isHovered
                      ? reaction.color
                      : reaction.color.withValues(alpha: 0.12),
                  border: Border.all(
                    color: isHovered
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.transparent,
                    width: isHovered ? 1.5 : 0,
                  ),
                  boxShadow: isHovered
                      ? [
                          BoxShadow(
                            color: reaction.color.withValues(alpha: 0.65),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : const [],
                ),
                alignment: Alignment.center,
                child: Icon(
                  reaction.icon,
                  color: isHovered ? Colors.white : reaction.color,
                  size: isHovered ? 23 : 21,
                ),
              ),
            ),
          ),
          // Floating Label Tooltip on hover (placed AFTER icon so it renders in front, top: -72 to sit above the enlarged icon)
          if (isHovered)
            Positioned(
              top: -72,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: reaction.color.withValues(alpha: 0.6),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  reaction.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReactionBadgesStack extends StatelessWidget {
  const _ReactionBadgesStack({required this.reactionCounts});

  final Map<PostReaction, int> reactionCounts;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final count = reactionCounts.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    final badges = PostReaction.values
        .where((reaction) => (reactionCounts[reaction] ?? 0) > 0)
        .toList()
      ..sort(
        (left, right) => (reactionCounts[right] ?? 0).compareTo(
          reactionCounts[left] ?? 0,
        ),
      );
    final visibleBadges = badges.take(3).toList(growable: false);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: visibleBadges.length == 1
              ? 20
              : 20 + (visibleBadges.length - 1) * 13.0,
          height: 20,
          child: Stack(
            children: [
              for (int i = 0; i < visibleBadges.length; i++)
                Positioned(
                  left: i * 13.0,
                  child: Container(
                    width: 19,
                    height: 19,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: visibleBadges[i].color,
                      border: Border.all(color: theme.surface, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      visibleBadges[i].icon,
                      size: 10.5,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PostAction extends StatelessWidget {
  const _PostAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 19, color: theme.textSecondary),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showCommentSheet(
  BuildContext context, {
  required _DemoPost post,
  required String? ownAvatarPath,
  required String ownDisplayName,
  required String ownHeadline,
  required ValueChanged<PostComment> onAddComment,
  required void Function(String parentId, PostCommentReply reply) onAddReply,
  required ValueChanged<String> onToggleCommentLike,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    builder: (_) => _CommentSheetWidget(
      post: post,
      ownAvatarPath: ownAvatarPath,
      ownDisplayName: ownDisplayName,
      ownHeadline: ownHeadline,
      onAddComment: onAddComment,
      onAddReply: onAddReply,
      onToggleCommentLike: onToggleCommentLike,
    ),
  );
}

class _CommentSheetWidget extends StatefulWidget {
  const _CommentSheetWidget({
    required this.post,
    required this.ownAvatarPath,
    required this.ownDisplayName,
    required this.ownHeadline,
    required this.onAddComment,
    required this.onAddReply,
    required this.onToggleCommentLike,
  });

  final _DemoPost post;
  final String? ownAvatarPath;
  final String ownDisplayName;
  final String ownHeadline;
  final ValueChanged<PostComment> onAddComment;
  final void Function(String parentId, PostCommentReply reply) onAddReply;
  final ValueChanged<String> onToggleCommentLike;

  @override
  State<_CommentSheetWidget> createState() => _CommentSheetWidgetState();
}

class _CommentSheetWidgetState extends State<_CommentSheetWidget> {
  late final List<PostComment> _comments;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  String? _replyingToCommentId;
  String? _replyingToAuthorName;

  @override
  void initState() {
    super.initState();
    _comments = List<PostComment>.from(widget.post.comments);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendComment() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    if (_replyingToCommentId != null) {
      final parentId = _replyingToCommentId!;
      final newReply = PostCommentReply(
        id: 'reply-${DateTime.now().millisecondsSinceEpoch}',
        authorName: widget.ownDisplayName,
        headline: widget.ownHeadline,
        content: text,
        timeLabel: 'Vừa xong',
        replyingToName: _replyingToAuthorName,
        avatarPath: widget.ownAvatarPath,
        isMine: true,
      );

      widget.onAddReply(parentId, newReply);

      setState(() {
        final parentIndex = _comments.indexWhere((c) => c.id == parentId);
        if (parentIndex != -1) {
          final parent = _comments[parentIndex];
          _comments[parentIndex] = parent.copyWith(
            replies: [...parent.replies, newReply],
          );
        }
        _replyingToCommentId = null;
        _replyingToAuthorName = null;
        _textController.clear();
      });
    } else {
      final newComment = PostComment(
        id: 'comment-${DateTime.now().millisecondsSinceEpoch}',
        authorName: widget.ownDisplayName,
        headline: widget.ownHeadline,
        content: text,
        timeLabel: 'Vừa xong',
        avatarPath: widget.ownAvatarPath,
        isMine: true,
      );

      widget.onAddComment(newComment);

      setState(() {
        _comments.insert(0, newComment);
        _textController.clear();
      });

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _toggleLike(String commentOrReplyId) {
    widget.onToggleCommentLike(commentOrReplyId);
    setState(() {
      final index = _comments.indexWhere((c) => c.id == commentOrReplyId);
      if (index != -1) {
        final current = _comments[index];
        final isLiked = !current.isLiked;
        final count = isLiked
            ? current.likeCount + 1
            : (current.likeCount - 1).clamp(0, 999999);
        _comments[index] = current.copyWith(isLiked: isLiked, likeCount: count);
        return;
      }
      for (int i = 0; i < _comments.length; i++) {
        final parent = _comments[i];
        final replyIdx = parent.replies.indexWhere(
          (r) => r.id == commentOrReplyId,
        );
        if (replyIdx != -1) {
          final reply = parent.replies[replyIdx];
          final isLiked = !reply.isLiked;
          final count = isLiked
              ? reply.likeCount + 1
              : (reply.likeCount - 1).clamp(0, 999999);
          final updatedReplies = List<PostCommentReply>.from(parent.replies);
          updatedReplies[replyIdx] = reply.copyWith(
            isLiked: isLiked,
            likeCount: count,
          );
          _comments[i] = parent.copyWith(replies: updatedReplies);
          return;
        }
      }
    });
  }

  void _replyTo(PostComment comment) {
    setState(() {
      _replyingToCommentId = comment.id;
      _replyingToAuthorName = comment.authorName;
    });
    _focusNode.requestFocus();
  }

  void _replyToReply(PostComment parentComment, PostCommentReply reply) {
    setState(() {
      _replyingToCommentId = parentComment.id;
      _replyingToAuthorName = reply.authorName;
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToAuthorName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final postAuthorName = widget.post.isMine
        ? widget.ownDisplayName
        : widget.post.author.displayName;
    final totalCommentCount = _comments.fold<int>(
      0,
      (sum, c) => sum + 1 + c.replies.length,
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Text(
                    'Bình luận ($totalCommentCount)',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.divider),
            Expanded(
              child: _comments.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 40,
                              color: theme.textSecondary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Chưa có bình luận nào',
                              style: TextStyle(
                                color: theme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hãy là người đầu tiên để lại ý kiến của bạn!',
                              style: TextStyle(
                                color: theme.textSecondary,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      itemCount: _comments.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        final isAuthor = comment.authorName == postAuthorName;
                        return _CommentItem(
                          comment: comment,
                          isAuthor: isAuthor,
                          postAuthorName: postAuthorName,
                          ownAvatarPath: widget.ownAvatarPath,
                          onLike: () => _toggleLike(comment.id),
                          onReply: () => _replyTo(comment),
                          onLikeReply: (replyId) => _toggleLike(replyId),
                          onReplyToReply: (reply) =>
                              _replyToReply(comment, reply),
                        );
                      },
                    ),
            ),
            Divider(height: 1, color: theme.divider),
            if (_replyingToAuthorName != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                color: theme.surfaceSubtle.withValues(alpha: 0.7),
                child: Row(
                  children: [
                    Icon(Icons.reply_rounded, size: 16, color: theme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'Đang trả lời ',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: _replyingToAuthorName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: theme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: theme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: theme.primary.withValues(alpha: 0.16),
                      foregroundImage: widget.ownAvatarPath != null
                          ? FileImage(File(widget.ownAvatarPath!))
                          : null,
                      child: widget.ownAvatarPath != null
                          ? null
                          : Icon(
                              Icons.person_outline_rounded,
                              color: theme.primary,
                              size: 18,
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.surfaceSubtle,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendComment(),
                          decoration: InputDecoration(
                            hintText: _replyingToAuthorName != null
                                ? 'Trả lời $_replyingToAuthorName...'
                                : 'Viết bình luận...',
                            hintStyle: TextStyle(
                              color: theme.textSecondary.withValues(
                                alpha: 0.75,
                              ),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            isDense: true,
                            filled: false,
                            fillColor: Colors.transparent,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _textController,
                      builder: (context, value, _) {
                        final hasText = value.text.trim().isNotEmpty;
                        return GestureDetector(
                          onTap: hasText ? _sendComment : null,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.send_rounded,
                              color: hasText
                                  ? (theme.isDark
                                        ? const Color(0xFF38BDF8)
                                        : const Color(0xFF0064E0))
                                  : theme.textSecondary.withValues(alpha: 0.35),
                              size: 22,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  const _CommentItem({
    required this.comment,
    required this.isAuthor,
    required this.postAuthorName,
    required this.ownAvatarPath,
    required this.onLike,
    required this.onReply,
    required this.onLikeReply,
    required this.onReplyToReply,
  });

  final PostComment comment;
  final bool isAuthor;
  final String postAuthorName;
  final String? ownAvatarPath;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final ValueChanged<String> onLikeReply;
  final ValueChanged<PostCommentReply> onReplyToReply;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final avatar =
        comment.avatarPath ?? (comment.isMine ? ownAvatarPath : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: theme.primary.withValues(alpha: 0.14),
              foregroundImage: avatar != null ? FileImage(File(avatar)) : null,
              child: avatar != null
                  ? null
                  : Text(
                      comment.authorName.isNotEmpty
                          ? comment.authorName[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        color: theme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.surfaceSubtle,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                comment.authorName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (isAuthor) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Tác giả',
                                  style: TextStyle(
                                    color: theme.primary,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (comment.headline.isNotEmpty) ...[
                          const SizedBox(height: 1),
                          Text(
                            comment.headline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          comment.content,
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Row(
                      children: [
                        Text(
                          comment.timeLabel,
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: onLike,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                comment.isLiked
                                    ? Icons.thumb_up_alt_rounded
                                    : Icons.thumb_up_alt_outlined,
                                size: 13,
                                color: comment.isLiked
                                    ? theme.primary
                                    : theme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                comment.isLiked ? 'Đã thích' : 'Thích',
                                style: TextStyle(
                                  color: comment.isLiked
                                      ? theme.primary
                                      : theme.textSecondary,
                                  fontSize: 11,
                                  fontWeight: comment.isLiked
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                              ),
                              if (comment.likeCount > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '(${comment.likeCount})',
                                  style: TextStyle(
                                    color: comment.isLiked
                                        ? theme.primary
                                        : theme.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: onReply,
                          child: Text(
                            'Trả lời',
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (comment.replies.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final reply in comment.replies) ...[
                  _CommentReplyItem(
                    reply: reply,
                    postAuthorName: postAuthorName,
                    ownAvatarPath: ownAvatarPath,
                    onLike: () => onLikeReply(reply.id),
                    onReply: () => onReplyToReply(reply),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CommentReplyItem extends StatelessWidget {
  const _CommentReplyItem({
    required this.reply,
    required this.postAuthorName,
    required this.ownAvatarPath,
    required this.onLike,
    required this.onReply,
  });

  final PostCommentReply reply;
  final String postAuthorName;
  final String? ownAvatarPath;
  final VoidCallback onLike;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final avatar = reply.avatarPath ?? (reply.isMine ? ownAvatarPath : null);
    final isPostAuthor = reply.authorName == postAuthorName;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: theme.primary.withValues(alpha: 0.14),
          foregroundImage: avatar != null ? FileImage(File(avatar)) : null,
          child: avatar != null
              ? null
              : Text(
                  reply.authorName.isNotEmpty
                      ? reply.authorName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: theme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.surfaceSubtle,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            reply.authorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        if (isPostAuthor) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Tác giả',
                              style: TextStyle(
                                color: theme.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          if (reply.replyingToName != null &&
                              reply.replyingToName!.isNotEmpty) ...[
                            TextSpan(
                              text: '@${reply.replyingToName} ',
                              style: TextStyle(
                                color: theme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                          TextSpan(
                            text: reply.content,
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Row(
                  children: [
                    Text(
                      reply.timeLabel,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onLike,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            reply.isLiked
                                ? Icons.thumb_up_alt_rounded
                                : Icons.thumb_up_alt_outlined,
                            size: 12,
                            color: reply.isLiked
                                ? theme.primary
                                : theme.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            reply.isLiked ? 'Đã thích' : 'Thích',
                            style: TextStyle(
                              color: reply.isLiked
                                  ? theme.primary
                                  : theme.textSecondary,
                              fontSize: 10.5,
                              fontWeight: reply.isLiked
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                          if (reply.likeCount > 0) ...[
                            const SizedBox(width: 3),
                            Text(
                              '(${reply.likeCount})',
                              style: TextStyle(
                                color: reply.isLiked
                                    ? theme.primary
                                    : theme.textSecondary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    GestureDetector(
                      onTap: onReply,
                      child: Text(
                        'Trả lời',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpandablePostContent extends StatefulWidget {
  const _ExpandablePostContent({required this.text});

  final String text;

  @override
  State<_ExpandablePostContent> createState() => _ExpandablePostContentState();
}

class _ExpandablePostContentState extends State<_ExpandablePostContent> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final textStyle = TextStyle(
      color: theme.textPrimary,
      height: 1.45,
      fontSize: 14,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: textStyle);
        final tp = TextPainter(
          text: span,
          maxLines: 3,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflowing = tp.didExceedMaxLines;
        if (!isOverflowing) {
          return Text.rich(span);
        }

        if (_isExpanded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.text, style: textStyle),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = false),
                child: Text(
                  'Thu gọn',
                  style: TextStyle(
                    color: theme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => setState(() => _isExpanded = true),
              child: Text(
                '... xem thêm',
                style: TextStyle(
                  color: theme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PostGallery extends StatelessWidget {
  const _PostGallery({required this.images});
  final List<XFile> images;

  void _openViewer(BuildContext context, int initialIndex) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            _FullScreenImageViewer(images: images, initialIndex: initialIndex),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    int index, {
    bool showOverlay = false,
    int extraCount = 0,
  }) {
    return GestureDetector(
      onTap: () => _openViewer(context, index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(images[index].path),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => ColoredBox(
              color: context.nivexTheme.surfaceSubtle,
              child: Icon(
                Icons.broken_image_outlined,
                color: context.nivexTheme.textSecondary,
              ),
            ),
          ),
          if (showOverlay && extraCount > 0)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.55),
              child: Center(
                child: Text(
                  '+$extraCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = images.length;
    if (count == 0) return const SizedBox.shrink();

    // 1 ảnh: ảnh lớn full width, trần an toàn 460px trong feed, bấm mở xem toàn bộ
    if (count == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onTap: () => _openViewer(context, 0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 460),
            child: Image.file(
              File(images.first.path),
              width: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, _, _) => ColoredBox(
                color: context.nivexTheme.surfaceSubtle,
                child: SizedBox(
                  height: 200,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: context.nivexTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 2 ảnh: 2 cột ngang đều nhau (cao 220px)
    if (count == 2) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 220,
          child: Row(
            children: [
              Expanded(child: _buildTile(context, 0)),
              const SizedBox(width: 4),
              Expanded(child: _buildTile(context, 1)),
            ],
          ),
        ),
      );
    }

    // 3 ảnh: 1 ảnh lớn bên trái (flex 3), 2 ảnh nhỏ xếp dọc bên phải (flex 2, cao 290px)
    if (count == 3) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 290,
          child: Row(
            children: [
              Expanded(flex: 3, child: _buildTile(context, 0)),
              const SizedBox(width: 4),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(child: _buildTile(context, 1)),
                    const SizedBox(height: 4),
                    Expanded(child: _buildTile(context, 2)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4 ảnh hoặc > 4 ảnh: Grid 2x2 cao 320px
    // Nếu > 4 ảnh: ô thứ 4 có overlay "+(count - 4)", bấm vào mở viewer tại ảnh thứ 4
    final isMoreThanFour = count > 4;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 320,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildTile(context, 0)),
                  const SizedBox(width: 4),
                  Expanded(child: _buildTile(context, 1)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildTile(context, 2)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildTile(
                      context,
                      3,
                      showOverlay: isMoreThanFour,
                      extraCount: count - 4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  final List<XFile> images;
  final int initialIndex;

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.images.length;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Đóng',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1}/$total',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: total,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 3.5,
              clipBehavior: Clip.none,
              child: Image.file(
                File(widget.images[index].path),
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum PostReaction {
  like('Thích', Icons.thumb_up_alt_rounded, Color(0xFF38BDF8)),
  love('Yêu thích', Icons.favorite_rounded, Color(0xFFF43F5E)),
  trust('Tin cậy', Icons.verified_user_rounded, Color(0xFF22C55E)),
  build('Đang xây', Icons.construction_rounded, Color(0xFFF59E0B)),
  insightful('Hay', Icons.lightbulb_rounded, Color(0xFF06B6D4)),
  deal('Haha', Icons.sentiment_very_satisfied_rounded, Color(0xFFF59E0B)),
  launch('Bứt phá', Icons.rocket_launch_rounded, Color(0xFFEC4899));

  const PostReaction(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

class PostCommentReply {
  const PostCommentReply({
    required this.id,
    required this.authorName,
    required this.headline,
    required this.content,
    required this.timeLabel,
    this.replyingToName,
    this.avatarPath,
    this.isMine = false,
    this.likeCount = 0,
    this.isLiked = false,
  });

  final String id;
  final String authorName;
  final String headline;
  final String content;
  final String timeLabel;
  final String? replyingToName;
  final String? avatarPath;
  final bool isMine;
  final int likeCount;
  final bool isLiked;

  PostCommentReply copyWith({
    String? id,
    String? authorName,
    String? headline,
    String? content,
    String? timeLabel,
    String? replyingToName,
    String? avatarPath,
    bool? isMine,
    int? likeCount,
    bool? isLiked,
  }) {
    return PostCommentReply(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      headline: headline ?? this.headline,
      content: content ?? this.content,
      timeLabel: timeLabel ?? this.timeLabel,
      replyingToName: replyingToName ?? this.replyingToName,
      avatarPath: avatarPath ?? this.avatarPath,
      isMine: isMine ?? this.isMine,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

class PostComment {
  const PostComment({
    required this.id,
    required this.authorName,
    required this.headline,
    required this.content,
    required this.timeLabel,
    this.avatarPath,
    this.isMine = false,
    this.likeCount = 0,
    this.isLiked = false,
    this.replies = const [],
  });

  final String id;
  final String authorName;
  final String headline;
  final String content;
  final String timeLabel;
  final String? avatarPath;
  final bool isMine;
  final int likeCount;
  final bool isLiked;
  final List<PostCommentReply> replies;

  PostComment copyWith({
    String? id,
    String? authorName,
    String? headline,
    String? content,
    String? timeLabel,
    String? avatarPath,
    bool? isMine,
    int? likeCount,
    bool? isLiked,
    List<PostCommentReply>? replies,
  }) {
    return PostComment(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      headline: headline ?? this.headline,
      content: content ?? this.content,
      timeLabel: timeLabel ?? this.timeLabel,
      avatarPath: avatarPath ?? this.avatarPath,
      isMine: isMine ?? this.isMine,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      replies: replies ?? this.replies,
    );
  }
}

class _DemoPost {
  const _DemoPost({
    required this.content,
    required this.images,
    required this.timeLabel,
    this.id,
    this.isMine = true,
    this.isPinned = false,
    this.isSaved = false,
    this.isHidden = false,
    this.createdAt,
    this.reactionCount = 0,
    this.reactionCounts = const {},
    this.myReaction,
    this.comments = const [],
    this.author = const PublicProfileData(
      kind: PublicProfileKind.freelancer,
      displayName: 'Minh Anh',
      handle: 'minhanh.nova',
      headline: 'Flutter Developer | Fintech Mobile Applications',
      location: 'Đà Nẵng, Việt Nam',
      bio: '',
      tags: [],
      stats: [],
    ),
  });

  final String? id;
  final String content;
  final List<XFile> images;
  final String timeLabel;
  final bool isMine;
  final bool isPinned;
  final bool isSaved;
  final bool isHidden;
  final DateTime? createdAt;
  final int reactionCount;
  final Map<PostReaction, int> reactionCounts;
  final PostReaction? myReaction;
  final List<PostComment> comments;
  final PublicProfileData author;

  _DemoPost copyWith({
    String? id,
    String? content,
    List<XFile>? images,
    String? timeLabel,
    bool? isMine,
    bool? isPinned,
    bool? isSaved,
    bool? isHidden,
    DateTime? createdAt,
    int? reactionCount,
    Map<PostReaction, int>? reactionCounts,
    PostReaction? myReaction,
    bool clearMyReaction = false,
    List<PostComment>? comments,
    PublicProfileData? author,
  }) {
    return _DemoPost(
      id: id ?? this.id,
      content: content ?? this.content,
      images: images ?? this.images,
      timeLabel: timeLabel ?? this.timeLabel,
      isMine: isMine ?? this.isMine,
      isPinned: isPinned ?? this.isPinned,
      isSaved: isSaved ?? this.isSaved,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
      reactionCount: reactionCount ?? this.reactionCount,
      reactionCounts: reactionCounts ?? this.reactionCounts,
      myReaction: clearMyReaction ? null : (myReaction ?? this.myReaction),
      comments: comments ?? this.comments,
      author: author ?? this.author,
    );
  }
}

String _postPermalink(_DemoPost post) {
  // TODO: replace demo permalink with backend post id.
  final postId = post.id ?? 'demo-${post.hashCode.abs()}';
  return 'https://nova.app/posts/$postId';
}

void _showConfirmDeleteDialog(BuildContext context, VoidCallback? onDelete) {
  final theme = context.nivexTheme;
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: theme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.border),
      ),
      title: Text(
        'Xóa bài viết?',
        style: TextStyle(
          color: theme.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        'Bài viết sẽ bị xóa khỏi cộng đồng và không thể khôi phục.',
        style: TextStyle(
          color: theme.textSecondary,
          fontSize: 14,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(
            'Hủy',
            style: TextStyle(
              color: theme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.danger,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onDelete?.call();
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: const Text('Đã xóa bài viết.'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(milliseconds: 2200),
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
          },
          child: const Text('Xóa bài'),
        ),
      ],
    ),
  );
}

void _showConfirmBlockDialog(BuildContext context, VoidCallback? onBlock) {
  final theme = context.nivexTheme;
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: theme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.border),
      ),
      title: Text(
        'Chặn trang cá nhân này?',
        style: TextStyle(
          color: theme.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        'Bạn sẽ không còn thấy bài viết, bình luận và tin nhắn từ người dùng này. Người này cũng không thể tương tác với bạn trong Nova.',
        style: TextStyle(
          color: theme.textSecondary,
          fontSize: 14,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(
            'Hủy',
            style: TextStyle(
              color: theme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.danger,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onBlock?.call();
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: const Text('Đã chặn người dùng.'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(milliseconds: 2200),
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
          },
          child: const Text('Chặn'),
        ),
      ],
    ),
  );
}

void _showReportDialog(BuildContext context) {
  final theme = context.nivexTheme;
  final reasons = [
    'Spam',
    'Lừa đảo',
    'Nội dung không phù hợp',
    'Quấy rối',
    'Khác',
  ];
  String selectedReason = reasons.first;

  showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        backgroundColor: theme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.border),
        ),
        title: Text(
          'Báo cáo bài viết',
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons
              .map(
                (reason) => RadioListTile<String>(
                  value: reason,
                  groupValue: selectedReason,
                  title: Text(
                    reason,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  activeColor: theme.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedReason = val);
                    }
                  },
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: theme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Cảm ơn bạn. Báo cáo đã được gửi đến ban quản trị.',
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(milliseconds: 2200),
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
            },
            child: const Text('Gửi báo cáo'),
          ),
        ],
      ),
    ),
  );
}

void _showPrivacyDialog(BuildContext context) {
  final theme = context.nivexTheme;
  final options = [
    {
      'title': 'Công khai',
      'desc': 'Bất kỳ ai trong cộng đồng đều có thể xem',
      'icon': Icons.public_rounded,
    },
    {
      'title': 'Người theo dõi',
      'desc': 'Chỉ người theo dõi bạn mới có thể xem',
      'icon': Icons.people_outline_rounded,
    },
    {
      'title': 'Chỉ mình tôi',
      'desc': 'Chỉ bạn mới có thể xem bài viết này',
      'icon': Icons.lock_outline_rounded,
    },
  ];
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: theme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    showDragHandle: true,
    builder: (bottomSheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                'Chỉnh sửa quyền riêng tư',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final opt in options)
              ListTile(
                leading: Icon(opt['icon'] as IconData, color: theme.primary),
                title: Text(
                  opt['title'] as String,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  opt['desc'] as String,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          'Đã đổi quyền riêng tư: ${opt['title']}',
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(milliseconds: 2200),
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                },
              ),
          ],
        ),
      ),
    ),
  );
}

void _showPostOptionsSheet(
  BuildContext context,
  _DemoPost post, {
  VoidCallback? onTogglePin,
  VoidCallback? onToggleSave,
  VoidCallback? onHide,
  VoidCallback? onDeletePost,
  VoidCallback? onBlockUser,
  VoidCallback? onToggleFollow,
  bool isFollowing = false,
  VoidCallback? onEditPost,
  VoidCallback? onEditPrivacy,
  VoidCallback? onReportPost,
}) {
  final theme = context.nivexTheme;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: theme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    showDragHandle: true,
    builder: (sheetContext) {
      void handleAction(String message, [VoidCallback? action]) {
        Navigator.of(sheetContext).pop();
        action?.call();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(milliseconds: 2200),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
      }

      if (post.isMine) {
        return _OwnerPostOptionsSheet(
          post: post,
          onAction: handleAction,
          onTogglePin: onTogglePin,
          onToggleSave: onToggleSave,
          onHide: onHide,
          onDelete: () => _showConfirmDeleteDialog(context, onDeletePost),
          onEdit: onEditPost,
          onEditPrivacy: onEditPrivacy,
        );
      } else {
        return _ViewerPostOptionsSheet(
          post: post,
          onAction: handleAction,
          onToggleSave: onToggleSave,
          onHide: onHide,
          onReport: onReportPost,
          onBlock: () => _showConfirmBlockDialog(context, onBlockUser),
          onToggleFollow: onToggleFollow,
          isFollowing: isFollowing,
        );
      }
    },
  );
}

class _OwnerPostOptionsSheet extends StatelessWidget {
  const _OwnerPostOptionsSheet({
    required this.post,
    required this.onAction,
    this.onTogglePin,
    this.onToggleSave,
    this.onHide,
    this.onDelete,
    this.onEdit,
    this.onEditPrivacy,
  });

  final _DemoPost post;
  final void Function(String message, [VoidCallback? action]) onAction;
  final VoidCallback? onTogglePin;
  final VoidCallback? onToggleSave;
  final VoidCallback? onHide;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onEditPrivacy;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final isPinned = post.isPinned;
    final isSaved = post.isSaved;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PostOptionTile(
              icon: isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              title: isPinned ? 'Bỏ ghim bài viết' : 'Ghim bài viết',
              onTap: () => onAction(
                isPinned
                    ? 'Đã bỏ ghim bài viết'
                    : 'Đã ghim bài viết lên đầu trang cá nhân',
                onTogglePin,
              ),
            ),
            _PostOptionTile(
              icon: isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              title: isSaved ? 'Bỏ lưu bài viết' : 'Lưu bài viết',
              subtitle: isSaved
                  ? 'Xóa khỏi danh sách các mục đã lưu.'
                  : 'Thêm vào danh sách các mục đã lưu.',
              onTap: () => onAction(
                isSaved
                    ? 'Đã bỏ lưu bài viết'
                    : 'Đã lưu bài viết vào mục Đã lưu',
                onToggleSave,
              ),
            ),
            _PostOptionTile(
              icon: Icons.edit_outlined,
              title: 'Chỉnh sửa bài viết',
              onTap: () {
                Navigator.of(context).pop();
                if (onEdit != null) {
                  onEdit!();
                } else {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Tính năng chỉnh sửa bài viết sẽ được kết nối sau',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                }
              },
            ),
            _PostOptionTile(
              icon: Icons.lock_outline_rounded,
              title: 'Chỉnh sửa quyền riêng tư',
              onTap: () {
                Navigator.of(context).pop();
                if (onEditPrivacy != null) {
                  onEditPrivacy!();
                } else {
                  _showPrivacyDialog(context);
                }
              },
            ),
            _PostOptionTile(
              icon: Icons.copy_rounded,
              title: 'Sao chép liên kết',
              onTap: () {
                Clipboard.setData(ClipboardData(text: _postPermalink(post)));
                onAction('Đã sao chép liên kết bài viết');
              },
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: theme.surfaceSubtle,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _PostOptionTile(
                icon: Icons.disabled_by_default_outlined,
                title: 'Ẩn khỏi trang cá nhân',
                subtitle: 'Bài viết này có thể vẫn xuất hiện ở các nơi khác.',
                onTap: () =>
                    onAction('Đã ẩn bài viết khỏi trang cá nhân', onHide),
              ),
            ),
            const SizedBox(height: 8),
            _PostOptionTile(
              icon: Icons.delete_outline_rounded,
              iconColor: theme.danger,
              textColor: theme.danger,
              title: 'Xóa bài viết',
              subtitle: 'Xóa vĩnh viễn bài viết khỏi cộng đồng.',
              onTap: () {
                Navigator.of(context).pop();
                onDelete?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewerPostOptionsSheet extends StatelessWidget {
  const _ViewerPostOptionsSheet({
    required this.post,
    required this.onAction,
    this.onToggleSave,
    this.onHide,
    this.onReport,
    this.onBlock,
    this.onToggleFollow,
    this.isFollowing = false,
  });

  final _DemoPost post;
  final void Function(String message, [VoidCallback? action]) onAction;
  final VoidCallback? onToggleSave;
  final VoidCallback? onHide;
  final VoidCallback? onReport;
  final VoidCallback? onBlock;
  final VoidCallback? onToggleFollow;
  final bool isFollowing;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final isSaved = post.isSaved;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PostOptionTile(
              icon: isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              title: isSaved ? 'Bỏ lưu bài viết' : 'Lưu bài viết',
              subtitle: isSaved
                  ? 'Xóa khỏi danh sách bài viết đã lưu.'
                  : 'Thêm vào danh sách bài viết đã lưu.',
              onTap: () => onAction(
                isSaved
                    ? 'Đã bỏ lưu bài viết'
                    : 'Đã lưu bài viết vào mục Đã lưu',
                onToggleSave,
              ),
            ),
            _PostOptionTile(
              icon: Icons.copy_rounded,
              title: 'Sao chép liên kết',
              onTap: () {
                Clipboard.setData(ClipboardData(text: _postPermalink(post)));
                onAction('Đã sao chép liên kết bài viết');
              },
            ),
            _PostOptionTile(
              icon: Icons.visibility_off_outlined,
              title: 'Ẩn bài viết này',
              subtitle: 'Không hiển thị bài viết này trên bảng tin.',
              onTap: () => onAction('Đã ẩn bài viết khỏi bảng tin', onHide),
            ),
            if (onToggleFollow != null)
              _PostOptionTile(
                icon: isFollowing
                    ? Icons.person_remove_outlined
                    : Icons.person_add_outlined,
                title: isFollowing ? 'Bỏ theo dõi tác giả' : 'Theo dõi tác giả',
                subtitle: isFollowing
                    ? 'Ngừng nhận cập nhật từ người này.'
                    : 'Nhận thông báo khi có bài viết mới.',
                onTap: () => onAction(
                  isFollowing
                      ? 'Đã bỏ theo dõi tác giả'
                      : 'Đang theo dõi tác giả',
                  onToggleFollow,
                ),
              ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: theme.surfaceSubtle,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _PostOptionTile(
                icon: Icons.flag_outlined,
                title: 'Báo cáo bài viết',
                subtitle: 'Báo cáo vi phạm tiêu chuẩn cộng đồng.',
                onTap: () {
                  Navigator.of(context).pop();
                  if (onReport != null) {
                    onReport!();
                  } else {
                    _showReportDialog(context);
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            _PostOptionTile(
              icon: Icons.block_rounded,
              iconColor: theme.danger,
              textColor: theme.danger,
              title: 'Chặn trang cá nhân này',
              subtitle: 'Bạn sẽ không còn thấy bài viết hoặc tin nhắn từ người này.',
              onTap: () {
                Navigator.of(context).pop();
                onBlock?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PostOptionTile extends StatelessWidget {
  const _PostOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.iconColor,
    this.textColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final primaryColor = textColor ?? theme.textPrimary;
    final icColor = iconColor ?? primaryColor;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Icon(icon, color: icColor, size: 23),
      title: Text(
        title,
        style: TextStyle(
          color: primaryColor,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: TextStyle(color: theme.textSecondary, fontSize: 12),
            ),
      onTap: onTap,
    );
  }
}
