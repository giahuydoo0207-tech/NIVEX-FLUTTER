import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/jobs/data/demo_application_controller.dart';
import 'package:nivex_flutter/features/jobs/domain/job_application.dart';
import 'package:nivex_flutter/features/jobs/presentation/application_thread_screen.dart';
import 'package:nivex_flutter/shared/widgets/nivex_page.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _applications = DemoApplicationController.instance;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _applications.addListener(_refresh);
  }

  @override
  void dispose() {
    _applications.removeListener(_refresh);
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final conversations =
        _applications.applications.where((application) {
          final query = _query.trim().toLowerCase();
          return query.isEmpty ||
              '${application.organizationName} ${application.jobTitle}'
                  .toLowerCase()
                  .contains(query);
        }).toList()..sort(
          (a, b) => b.messages.last.sentAt.compareTo(a.messages.last.sentAt),
        );

    return NivexPage(
      title: 'Tin nhắn',
      subtitle: 'Trao đổi với doanh nghiệp về hồ sơ của bạn',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: IconButton(
            tooltip: 'Tin nhắn chưa đọc',
            onPressed: () {},
            icon: Badge(
              label: const Text('1'),
              child: const Icon(Icons.mark_chat_unread_outlined),
            ),
          ),
        ),
      ],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Tìm doanh nghiệp hoặc vị trí',
                  leading: const Icon(Icons.search_rounded),
                  trailing: _query.isEmpty
                      ? null
                      : [
                          IconButton(
                            tooltip: 'Xóa tìm kiếm',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  children: [
                    Text(
                      'HỘI THOẠI GẦN ĐÂY',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${conversations.length} hồ sơ',
                      style: TextStyle(
                        color: theme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: conversations.isEmpty
                    ? _EmptyInbox(hasQuery: _query.isNotEmpty)
                    : ListView.separated(
                        key: const PageStorageKey('messages-list'),
                        padding: const EdgeInsets.only(bottom: 96),
                        itemCount: conversations.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          indent: 82,
                          color: theme.divider,
                        ),
                        itemBuilder: (context, index) => _ConversationTile(
                          application: conversations[index],
                          unread: index == 0,
                          onTap: () => _openThread(conversations[index]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openThread(JobApplication application) {
    return Navigator.of(context, rootNavigator: true).push<void>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, animation, secondaryAnimation) =>
            ApplicationThreadScreen(applicationId: application.id),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final slide = Tween(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(slide),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.application,
    required this.unread,
    required this.onTap,
  });

  final JobApplication application;
  final bool unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final lastMessage = application.messages.last;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 16, 14),
          child: Row(
            children: [
              Hero(
                tag: 'conversation-avatar-${application.id}',
                child: _OrganizationAvatar(name: application.organizationName),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            application.organizationName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 15,
                              fontWeight: unread
                                  ? FontWeight.w800
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          _time(lastMessage.sentAt),
                          style: TextStyle(
                            color: unread ? theme.primary : theme.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      application.jobTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${lastMessage.role == JobMessageRole.talent ? 'Bạn: ' : ''}${lastMessage.body}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: unread
                                  ? theme.textPrimary
                                  : theme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 19,
                            height: 19,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: theme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '1',
                              style: TextStyle(
                                color: theme.isDark
                                    ? const Color(0xFF07101F)
                                    : Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _time(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

class _OrganizationAvatar extends StatelessWidget {
  const _OrganizationAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: theme.primary.withValues(alpha: 0.42)),
          ),
          child: Text(
            name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: theme.primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Positioned(
          right: 1,
          bottom: 1,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: theme.success,
              shape: BoxShape.circle,
              border: Border.all(color: theme.background, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox({required this.hasQuery});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined, size: 42, color: theme.primary),
            const SizedBox(height: 14),
            Text(
              hasQuery ? 'Không tìm thấy hội thoại' : 'Chưa có cuộc trò chuyện',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              hasQuery
                  ? 'Thử tìm bằng tên doanh nghiệp hoặc vị trí khác.'
                  : 'Hội thoại sẽ xuất hiện sau khi bạn gửi hồ sơ ứng tuyển.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textSecondary, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
