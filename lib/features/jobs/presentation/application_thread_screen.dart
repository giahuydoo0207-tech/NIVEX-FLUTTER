import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/jobs/data/application_controller.dart';
import 'package:nivex_flutter/features/jobs/data/demo_application_controller.dart';
import 'package:nivex_flutter/features/jobs/data/remote_application_controller.dart';
import 'package:nivex_flutter/features/jobs/domain/job_application.dart';
import 'package:nivex_flutter/features/replyn_proposals/domain/replyn_proposal.dart';
import 'package:nivex_flutter/features/replyn_proposals/presentation/replyn_proposal_card.dart';
import 'package:nivex_flutter/features/replyn_proposals/presentation/replyn_proposal_screen.dart';

class ApplicationThreadScreen extends StatefulWidget {
  const ApplicationThreadScreen({
    required this.applicationId,
    this.controller,
    super.key,
  });

  final String applicationId;

  /// Source of the conversation; defaults to the offline demo fixtures.
  final ApplicationController? controller;

  @override
  State<ApplicationThreadScreen> createState() =>
      _ApplicationThreadScreenState();
}

class _ApplicationThreadScreenState extends State<ApplicationThreadScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late final ApplicationController _applications =
      widget.controller ?? DemoApplicationController.instance;
  Timer? _poll;
  Timer? _typingPoll;
  JobApplicationMessage? _replyingTo;
  JobApplication? _lastApplicationSnapshot;
  int _lastMessageCount = 0;
  bool _wasTyping = false;
  bool _forceFollowMessages = false;

  @override
  void initState() {
    super.initState();
    final application = _applications.byId(widget.applicationId);
    _lastApplicationSnapshot = application;
    _lastMessageCount = application?.messages.length ?? 0;
    _wasTyping = _applications.isBusinessTyping(widget.applicationId);
    _applications.addListener(_refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToEnd());
    if (_applications is RemoteApplicationController) {
      // Opening the thread is what marks business messages as seen; new
      // replies are fetched while the conversation stays open.
      unawaited(_syncRemote());
      _poll = Timer.periodic(
        const Duration(seconds: 8),
        (_) => unawaited(_syncRemote()),
      );
      // Short-lived typing state; there is no realtime channel to push it.
      _typingPoll = Timer.periodic(
        const Duration(milliseconds: 2500),
        (_) => unawaited(_applications.pollTyping(widget.applicationId)),
      );
      _messageController.addListener(_onDraftChanged);
    }
  }

  void _onDraftChanged() {
    if (_messageController.text.trim().isNotEmpty) {
      _applications.reportTyping(widget.applicationId);
    }
  }

  Future<void> _syncRemote() async {
    await _applications.refresh();
    if (!mounted) return;
    await _applications.markConversationRead(widget.applicationId);
  }

  @override
  void dispose() {
    _poll?.cancel();
    _typingPoll?.cancel();
    _messageController.removeListener(_onDraftChanged);
    _applications.cancelPendingActivity(widget.applicationId);
    _applications.removeListener(_refresh);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    final application = _applications.byId(widget.applicationId);
    if (application == null) {
      setState(() {});
      return;
    }
    final isTyping = _applications.isBusinessTyping(application.id);
    if (identical(application, _lastApplicationSnapshot) &&
        isTyping == _wasTyping) {
      return;
    }
    final hasNewMessage = application.messages.length > _lastMessageCount;
    final typingStarted = isTyping && !_wasTyping;
    final wasNearBottom =
        !_scrollController.hasClients ||
        _scrollController.position.extentAfter < 140;

    _lastApplicationSnapshot = application;
    _lastMessageCount = application.messages.length;
    _wasTyping = isTyping;
    setState(() {});
    if ((hasNewMessage || typingStarted) &&
        (wasNearBottom || _forceFollowMessages)) {
      _forceFollowMessages = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    }
  }

  void _jumpToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _scrollToEnd() {
    if (!_scrollController.hasClients) return;
    final distance = _scrollController.position.extentAfter;
    if (distance <= 1) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: distance > 420 ? 220 : 150),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final application = _applications.byId(widget.applicationId);
    if (application == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hồ sơ ứng tuyển')),
        body: const Center(child: Text('Không tìm thấy hồ sơ.')),
      );
    }
    final isTyping = _applications.isBusinessTyping(application.id);
    final messagesById = {
      for (final message in application.messages) message.id: message,
    };
    final items = _threadItems(application);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Row(
          children: [
            Hero(
              tag: 'conversation-avatar-${application.id}',
              child: _ThreadAvatar(name: application.organizationName),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.organizationName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      isTyping
                          ? 'đang nhập...'
                          : application.threadStatus == 'PENDING'
                          ? 'đang chờ chấp nhận tin nhắn'
                          : application.threadStatus == 'BLOCKED'
                          ? 'không thể gửi tin nhắn mới'
                          : _applications is RemoteApplicationController
                          ? application.jobTitle
                          : 'đang hoạt động',
                      key: ValueKey(isTyping),
                      style: TextStyle(
                        color: isTyping ? theme.primary : theme.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Thông tin hồ sơ',
            onPressed: () => _showApplicationInfo(application),
            icon: const Icon(Icons.info_outline_rounded),
          ),
          IconButton(
            tooltip: 'Tùy chọn',
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _ApplicationStrip(application: application),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _ChatBackgroundPainter(
                          color: theme.border.withValues(
                            alpha: theme.isDark ? 0.22 : 0.12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ListView.builder(
                    key: const Key('application-message-list'),
                    controller: _scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    scrollCacheExtent: const ScrollCacheExtent.pixels(420),
                    addAutomaticKeepAlives: false,
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 20),
                    itemCount: items.length + (isTyping ? 2 : 1),
                    itemBuilder: (context, index) {
                      if (index == 0) return const _DateDivider();
                      if (index > items.length) {
                        return const _TypingBubble();
                      }
                      final item = items[index - 1];
                      if (item is ReplynProposal) {
                        return ReplynProposalCard(
                          key: ValueKey('proposal-${item.id}'),
                          proposal: item,
                          organizationName: application.organizationName,
                          onOpen: () => _openProposal(application, item),
                        );
                      }
                      final message = item as JobApplicationMessage;
                      final repliedMessage = message.replyToId == null
                          ? null
                          : messagesById[message.replyToId];
                      return _MessageBubble(
                        key: ValueKey(message.id),
                        message: message,
                        repliedMessage: repliedMessage,
                        onReply: message.role == JobMessageRole.system
                            ? null
                            : () => setState(() => _replyingTo = message),
                      );
                    },
                  ),
                ],
              ),
            ),
            _MessageComposer(
              controller: _messageController,
              replyingTo: _replyingTo,
              onCancelReply: () => setState(() => _replyingTo = null),
              onSend: () => _send(application),
            ),
          ],
        ),
      ),
    );
  }

  /// Messages with each Replyn proposal card placed at the time it was sent.
  static List<Object> _threadItems(JobApplication application) {
    final proposals = [...application.replynProposals]
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    final items = <Object>[];
    var next = 0;
    for (final message in application.messages) {
      while (next < proposals.length &&
          proposals[next].sentAt.isBefore(message.sentAt)) {
        items.add(proposals[next++]);
      }
      items.add(message);
    }
    items.addAll(proposals.skip(next));
    return items;
  }

  void _openProposal(JobApplication application, ReplynProposal proposal) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReplynProposalScreen(
          controller: _applications,
          applicationId: application.id,
          proposalId: proposal.id,
        ),
      ),
    );
  }

  Future<void> _send(JobApplication application) async {
    final body = _messageController.text.trim();
    if (body.isEmpty) return;
    _forceFollowMessages = true;
    final replyToId = _replyingTo?.id;
    _messageController.clear();
    setState(() => _replyingTo = null);
    final sent = await _applications.sendTalentMessage(
      application.id,
      body,
      replyToId: replyToId,
    );
    if (sent || !mounted) return;
    // Keep the text so the user can retry after the failure is explained.
    if (_messageController.text.isEmpty) _messageController.text = body;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_applications.errorMessage ?? 'Không thể gửi tin nhắn.'),
      ),
    );
  }

  void _showApplicationInfo(JobApplication application) {
    final theme = context.nivexTheme;
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              application.jobTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              application.organizationName,
              style: TextStyle(color: theme.textSecondary),
            ),
            const SizedBox(height: 18),
            _InfoRow(
              icon: Icons.assignment_turned_in_outlined,
              label: 'Trạng thái',
              value: application.statusLabel,
            ),
            _InfoRow(
              icon: Icons.schedule_rounded,
              label: 'Bắt đầu',
              value: application.availability,
            ),
            _InfoRow(
              icon: Icons.shield_outlined,
              label: 'Quyền riêng tư',
              value: 'Chỉ bạn và ${application.organizationName}',
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationStrip extends StatelessWidget {
  const _ApplicationStrip({required this.application});

  final JobApplication application;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final color = switch (application.status) {
      JobApplicationStatus.submitted => theme.primary,
      JobApplicationStatus.viewed ||
      JobApplicationStatus.shortlisted ||
      JobApplicationStatus.interview => theme.warning,
      JobApplicationStatus.accepted => theme.success,
      JobApplicationStatus.rejected ||
      JobApplicationStatus.withdrawn => theme.danger,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 14, 10),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(bottom: BorderSide(color: theme.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.work_outline_rounded, color: color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application.jobTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  application.statusDescription,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.textSecondary, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(
              application.statusLabel,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatefulWidget {
  const _MessageBubble({
    required this.message,
    required this.repliedMessage,
    required this.onReply,
    super.key,
  });

  final JobApplicationMessage message;
  final JobApplicationMessage? repliedMessage;
  final VoidCallback? onReply;

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  double _drag = 0;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    if (widget.message.role == JobMessageRole.system) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 14,
              color: theme.success,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                widget.message.body,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.textSecondary, fontSize: 11),
              ),
            ),
          ],
        ),
      );
    }

    final isTalent = widget.message.role == JobMessageRole.talent;
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 230),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset((isTalent ? 12 : -12) * (1 - value), 4 * (1 - value)),
          child: child,
        ),
      ),
      child: GestureDetector(
        onHorizontalDragUpdate: widget.onReply == null
            ? null
            : (details) {
                if (details.delta.dx > 0 || _drag > 0) {
                  setState(
                    () => _drag = (_drag + details.delta.dx).clamp(0, 64),
                  );
                }
              },
        onHorizontalDragEnd: widget.onReply == null
            ? null
            : (_) {
                if (_drag > 46) widget.onReply?.call();
                setState(() => _drag = 0);
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(_drag, 0, 0),
          margin: const EdgeInsets.only(bottom: 8),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              if (_drag > 12)
                Positioned(
                  left: -1,
                  child: Opacity(
                    opacity: (_drag / 54).clamp(0, 1),
                    child: Icon(
                      Icons.reply_rounded,
                      size: 18,
                      color: theme.primary,
                    ),
                  ),
                ),
              Align(
                alignment: isTalent
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 326),
                  padding: const EdgeInsets.fromLTRB(12, 9, 10, 7),
                  decoration: BoxDecoration(
                    color: isTalent
                        ? theme.primary.withValues(
                            alpha: theme.isDark ? 0.24 : 0.12,
                          )
                        : theme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(15),
                      topRight: const Radius.circular(15),
                      bottomLeft: Radius.circular(isTalent ? 15 : 4),
                      bottomRight: Radius.circular(isTalent ? 4 : 15),
                    ),
                    border: Border.all(
                      color: isTalent
                          ? theme.primary.withValues(alpha: 0.48)
                          : theme.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.repliedMessage != null) ...[
                        _ReplyQuote(message: widget.repliedMessage!),
                        const SizedBox(height: 7),
                      ],
                      Text(
                        widget.message.body,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _time(widget.message.sentAt),
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 9,
                            ),
                          ),
                          if (isTalent) ...[
                            const SizedBox(width: 4),
                            _DeliveryIcon(
                              status: widget.message.deliveryStatus,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
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

class _ReplyQuote extends StatelessWidget {
  const _ReplyQuote({required this.message});

  final JobApplicationMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: theme.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: theme.primary, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.senderName,
            style: TextStyle(
              color: theme.primary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            message.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: theme.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _DeliveryIcon extends StatelessWidget {
  const _DeliveryIcon({required this.status});

  final JobMessageDeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Tooltip(
      message: switch (status) {
        JobMessageDeliveryStatus.sending => 'Đang gửi',
        JobMessageDeliveryStatus.sent => 'Đã gửi',
        JobMessageDeliveryStatus.delivered => 'Đã nhận',
        JobMessageDeliveryStatus.seen => 'Đã xem',
      },
      child: Icon(
        switch (status) {
          JobMessageDeliveryStatus.sending => Icons.schedule_rounded,
          JobMessageDeliveryStatus.sent => Icons.check_rounded,
          JobMessageDeliveryStatus.delivered ||
          JobMessageDeliveryStatus.seen => Icons.done_all_rounded,
        },
        size: 14,
        color: status == JobMessageDeliveryStatus.seen
            ? theme.primary
            : theme.textSecondary,
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: 36,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(15),
          ),
          border: Border.all(color: theme.border),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              final phase = (_controller.value - index * 0.16) % 1;
              final lift = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
              return Transform.translate(
                offset: Offset(0, -2.5 * lift),
                child: Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: theme.textSecondary.withValues(
                      alpha: 0.45 + lift * 0.5,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _MessageComposer extends StatefulWidget {
  const _MessageComposer({
    required this.controller,
    required this.replyingTo,
    required this.onCancelReply,
    required this.onSend,
  });

  final TextEditingController controller;
  final JobApplicationMessage? replyingTo;
  final VoidCallback onCancelReply;
  final VoidCallback onSend;

  @override
  State<_MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<_MessageComposer> {
  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Material(
      color: theme.surface,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: theme.border)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: widget.replyingTo == null
                    ? const SizedBox.shrink()
                    : Container(
                        margin: const EdgeInsets.fromLTRB(42, 0, 2, 8),
                        padding: const EdgeInsets.fromLTRB(9, 7, 4, 7),
                        decoration: BoxDecoration(
                          color: theme.surfaceSubtle,
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            left: BorderSide(color: theme.primary, width: 2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Trả lời ${widget.replyingTo!.senderName}',
                                    style: TextStyle(
                                      color: theme.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.replyingTo!.body,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: theme.textSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Hủy trả lời',
                              onPressed: widget.onCancelReply,
                              icon: const Icon(Icons.close_rounded, size: 18),
                            ),
                          ],
                        ),
                      ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Đính kèm',
                    onPressed: () {},
                    icon: const Icon(Icons.attach_file_rounded),
                  ),
                  Expanded(
                    child: TextField(
                      key: const Key('application-message-input'),
                      controller: widget.controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) {
                        if (widget.controller.text.trim().isNotEmpty) {
                          widget.onSend();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Tin nhắn',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 11,
                        ),
                        suffixIcon: IconButton(
                          tooltip: 'Biểu cảm',
                          onPressed: () {},
                          icon: const Icon(
                            Icons.sentiment_satisfied_alt_rounded,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide(color: theme.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide(color: theme.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: widget.controller,
                    builder: (context, value, _) => AnimatedScale(
                      scale: value.text.trim().isEmpty ? 0.94 : 1,
                      duration: const Duration(milliseconds: 150),
                      child: IconButton.filled(
                        key: const Key('application-message-send'),
                        tooltip: 'Gửi tin nhắn',
                        onPressed: value.text.trim().isEmpty
                            ? null
                            : widget.onSend,
                        icon: const Icon(Icons.send_rounded),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(46, 46),
                          backgroundColor: theme.primary,
                          foregroundColor: theme.isDark
                              ? const Color(0xFF07101F)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  const _DateDivider();

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(child: Divider(color: theme.divider)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Hôm nay',
              style: TextStyle(color: theme.textSecondary, fontSize: 10),
            ),
          ),
          Expanded(child: Divider(color: theme.divider)),
        ],
      ),
    );
  }
}

class _ThreadAvatar extends StatelessWidget {
  const _ThreadAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.primary.withValues(alpha: 0.13),
          shape: BoxShape.circle,
          border: Border.all(color: theme.primary.withValues(alpha: 0.42)),
        ),
        child: Text(
          name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: theme.primary,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(color: theme.textSecondary)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: theme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBackgroundPainter extends CustomPainter {
  const _ChatBackgroundPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 28.0;
    for (double y = 14; y < size.height; y += spacing) {
      for (double x = 14; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ChatBackgroundPainter oldDelegate) =>
      oldDelegate.color != color;
}
