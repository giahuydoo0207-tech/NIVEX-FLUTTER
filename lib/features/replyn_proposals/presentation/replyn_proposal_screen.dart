import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/jobs/data/application_controller.dart';
import 'package:nivex_flutter/features/replyn_proposals/domain/replyn_proposal.dart';
import 'package:nivex_flutter/features/replyn_proposals/presentation/replyn_proposal_card.dart';

/// The full agreement a business proposed. The talent is the only party who
/// can accept or reject it; the screen follows the controller, so the status
/// updates as soon as the backend confirms.
class ReplynProposalScreen extends StatefulWidget {
  const ReplynProposalScreen({
    required this.controller,
    required this.applicationId,
    required this.proposalId,
    super.key,
  });

  final ApplicationController controller;
  final String applicationId;
  final String proposalId;

  @override
  State<ReplynProposalScreen> createState() => _ReplynProposalScreenState();
}

class _ReplynProposalScreenState extends State<ReplynProposalScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final conversation = widget.controller.byId(widget.applicationId);
        final proposal = conversation?.replynProposals
            .where((p) => p.id == widget.proposalId)
            .firstOrNull;
        if (conversation == null || proposal == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Đề xuất Replyn')),
            body: const Center(child: Text('Không tìm thấy đề xuất.')),
          );
        }
        return _buildProposal(context, conversation.organizationName, proposal);
      },
    );
  }

  Widget _buildProposal(
    BuildContext context,
    String organizationName,
    ReplynProposal proposal,
  ) {
    final theme = context.nivexTheme;
    final color = proposalStatusColor(context, proposal.status);
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Đề xuất Replyn'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          children: [
            Text(
              '$organizationName gửi bạn đề xuất',
              style: TextStyle(color: theme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              proposal.projectName,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  proposal.talentStatusLabel,
                  key: const Key('replyn-proposal-status'),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            if (proposal.status == ReplynProposalStatus.rejected &&
                (proposal.rejectionReason ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Lý do: ${proposal.rejectionReason}',
                style: TextStyle(color: theme.textSecondary, fontSize: 12),
              ),
            ],
            if (proposal.awaitingTalent && proposal.expiresAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Hãy phản hồi trước ${formatProposalDate(proposal.expiresAt)}.',
                style: TextStyle(color: theme.textSecondary, fontSize: 12),
              ),
            ],
            _Section(title: 'Phạm vi công việc', child: Text(proposal.scope)),
            _Section(
              title: 'Sản phẩm bàn giao',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in proposal.deliverables)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $item'),
                    ),
                ],
              ),
            ),
            _Section(
              title: 'Điều khoản',
              child: Column(
                children: [
                  _Row(
                    label: 'Ngân sách',
                    value: formatProposalAmount(
                      proposal.totalAmount,
                      proposal.currency,
                    ),
                  ),
                  _Row(
                    label: 'Bắt đầu',
                    value: formatProposalDate(proposal.startDate),
                  ),
                  _Row(
                    label: 'Deadline',
                    value: formatProposalDate(proposal.deadline),
                  ),
                  _Row(
                    label: 'Số lần chỉnh sửa',
                    value: proposal.revisionLimit?.toString() ?? '—',
                  ),
                  _Row(
                    label: 'Thời gian nghiệm thu',
                    value: proposal.reviewPeriodDays == null
                        ? '—'
                        : '${proposal.reviewPeriodDays} ngày',
                  ),
                ],
              ),
            ),
            _Section(
              title: 'Milestone',
              child: Column(
                children: [
                  for (final (index, milestone) in proposal.milestones.indexed)
                    _Row(
                      label: '${index + 1}. ${milestone.title}',
                      value:
                          '${formatProposalAmount(milestone.amount, proposal.currency)} · ${formatProposalDate(milestone.deadline)}',
                    ),
                ],
              ),
            ),
            if (proposal.notes.isNotEmpty)
              _Section(title: 'Ghi chú', child: Text(proposal.notes)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.surfaceSubtle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: theme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ReplynProposal.simulationNotice,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _actions(context, proposal),
    );
  }

  Widget? _actions(BuildContext context, ReplynProposal proposal) {
    if (proposal.status == ReplynProposalStatus.accepted &&
        proposal.workspaceId != null) {
      return _Bar(
        children: [
          Expanded(
            child: FilledButton.icon(
              key: const Key('replyn-proposal-open-replyn'),
              onPressed: () =>
                  showOpenReplynSheet(context, proposal.workspaceId!),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Mở Replyn'),
            ),
          ),
        ],
      );
    }
    if (!proposal.awaitingTalent) return null;
    return _Bar(
      children: [
        Expanded(
          child: OutlinedButton(
            key: const Key('replyn-proposal-reject'),
            onPressed: _busy ? null : () => _reject(proposal),
            child: const Text('Từ chối'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: FilledButton(
            key: const Key('replyn-proposal-accept'),
            onPressed: _busy ? null : () => _accept(proposal),
            child: Text(_busy ? 'Đang gửi…' : 'Chấp nhận đề xuất'),
          ),
        ),
      ],
    );
  }

  Future<void> _accept(ReplynProposal proposal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Chấp nhận đề xuất?'),
        content: Text(
          'Bạn đồng ý thực hiện “${proposal.projectName}” theo phạm vi, milestone và deadline trong đề xuất. '
          'Sau khi chấp nhận, bạn và doanh nghiệp sẽ mở cùng một workspace Replyn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            key: const Key('replyn-proposal-accept-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Chấp nhận'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _respond(proposal, accept: true);
  }

  Future<void> _reject(ReplynProposal proposal) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _RejectDialog(),
    );
    if (reason == null || !mounted) return;
    await _respond(proposal, accept: false, reason: reason);
  }

  Future<void> _respond(
    ReplynProposal proposal, {
    required bool accept,
    String? reason,
  }) async {
    setState(() => _busy = true);
    final error = await widget.controller.respondToProposal(
      widget.applicationId,
      proposal.id,
      accept: accept,
      reason: reason,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ??
              (accept
                  ? 'Đã chấp nhận đề xuất. Workspace Replyn đã sẵn sàng.'
                  : 'Đã từ chối đề xuất.'),
        ),
      ),
    );
  }
}

/// Returns the optional reason, or null when the talent backs out.
class _RejectDialog extends StatefulWidget {
  const _RejectDialog();

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Từ chối đề xuất?'),
      content: TextField(
        key: const Key('replyn-proposal-reject-reason'),
        controller: _reason,
        maxLength: 500,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Lý do (không bắt buộc)',
          hintText: 'Ví dụ: Deadline chưa phù hợp',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          key: const Key('replyn-proposal-reject-confirm'),
          onPressed: () => Navigator.pop(context, _reason.text),
          child: const Text('Từ chối'),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          DefaultTextStyle.merge(
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 13,
              height: 1.45,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: theme.textSecondary)),
          ),
          const SizedBox(width: 12),
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

class _Bar extends StatelessWidget {
  const _Bar({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Material(
      color: theme.surface,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: theme.border)),
          ),
          child: Row(children: children),
        ),
      ),
    );
  }
}
