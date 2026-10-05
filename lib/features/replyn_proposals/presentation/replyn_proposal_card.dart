import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/replyn_pairing/domain/replyn_qr_parser.dart';
import 'package:nivex_flutter/features/replyn_proposals/domain/replyn_proposal.dart';
import 'package:url_launcher/url_launcher.dart';

String formatProposalAmount(double? value, String currency) {
  if (value == null) return '—';
  final whole = value == value.roundToDouble();
  final text = whole ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  final grouped = text.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return '$grouped $currency';
}

String formatProposalDate(DateTime? value) {
  if (value == null) return '—';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(value.day)}/${two(value.month)}/${value.year}';
}

Color proposalStatusColor(BuildContext context, ReplynProposalStatus status) {
  final theme = context.nivexTheme;
  return switch (status) {
    ReplynProposalStatus.pending => theme.warning,
    ReplynProposalStatus.accepted => theme.success,
    ReplynProposalStatus.rejected => theme.danger,
    ReplynProposalStatus.cancelled ||
    ReplynProposalStatus.expired => theme.textSecondary,
  };
}

/// A proposal in the Nova conversation: its own card, not a chat message.
class ReplynProposalCard extends StatelessWidget {
  const ReplynProposalCard({
    required this.proposal,
    required this.organizationName,
    required this.onOpen,
    super.key,
  });

  final ReplynProposal proposal;
  final String organizationName;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final color = proposalStatusColor(context, proposal.status);
    return Align(
      child: Container(
        key: ValueKey('replyn-proposal-${proposal.id}'),
        constraints: const BoxConstraints(maxWidth: 360),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        // A rounded border must be one colour, so the status shows as a
        // gradient edge instead of a differently coloured left side.
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.border),
          gradient: LinearGradient(
            colors: [color, color, theme.surface, theme.surface],
            stops: const [0, 0.012, 0.012, 1],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 15,
                  color: theme.primary,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'ĐỀ XUẤT REPLYN',
                    style: TextStyle(
                      color: theme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                _StatusChip(label: proposal.talentStatusLabel, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$organizationName gửi đề xuất',
              style: TextStyle(color: theme.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 2),
            Text(
              proposal.projectName,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (proposal.scope.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                proposal.scope,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                _Fact(
                  icon: Icons.account_balance_wallet_outlined,
                  label: formatProposalAmount(
                    proposal.totalAmount,
                    proposal.currency,
                  ),
                ),
                _Fact(
                  icon: Icons.flag_outlined,
                  label: '${proposal.milestones.length} milestone',
                ),
                _Fact(
                  icon: Icons.event_outlined,
                  label: formatProposalDate(proposal.deadline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  key: Key('replyn-proposal-open-${proposal.id}'),
                  onPressed: onOpen,
                  child: const Text('Xem đề xuất'),
                ),
                if (proposal.status == ReplynProposalStatus.accepted &&
                    proposal.workspaceId != null)
                  FilledButton.icon(
                    onPressed: () =>
                        showOpenReplynSheet(context, proposal.workspaceId!),
                    icon: const Icon(Icons.open_in_new_rounded, size: 17),
                    label: const Text('Mở Replyn'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Opens the accepted workspace. Replyn signs a Talent in with a QR code shown
/// on another screen, so the sheet explains that path and offers the link.
Future<void> showOpenReplynSheet(BuildContext context, String workspaceId) {
  final uri = replynWorkspaceUri(
    ReplynQrConfig.defaultProductionHost,
    workspaceId,
  );
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final theme = sheetContext.nivexTheme;
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mở workspace Replyn',
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Mở liên kết dưới đây trên máy tính, chọn “Mã QR”, rồi quét bằng biểu tượng quét QR cạnh chuông trong Nova. '
              'Replyn sẽ mở đúng workspace của đề xuất này.',
              style: TextStyle(color: theme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.surfaceSubtle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.border),
              ),
              child: SelectableText(
                uri.toString(),
                style: TextStyle(color: theme.textPrimary, fontSize: 12),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: uri.toString()),
                    );
                    if (!sheetContext.mounted) return;
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      const SnackBar(
                        content: Text('Đã sao chép liên kết workspace.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 17),
                  label: const Text('Sao chép liên kết'),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      launchUrl(uri, mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.open_in_browser_rounded, size: 17),
                  label: const Text('Mở trên điện thoại'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
