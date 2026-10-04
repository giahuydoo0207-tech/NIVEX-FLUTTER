import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/replyn_pairing/data/nova_account_source.dart';
import 'package:nivex_flutter/features/replyn_pairing/domain/replyn_pairing_request.dart';
import 'package:nivex_flutter/features/replyn_pairing/domain/replyn_pairing_service.dart';

/// How the confirmation step was left. A system back (null) counts as cancel.
enum ReplynConfirmResult { cancelled, scanAnother, close }

const replynPrototypeMessage =
    'Đã đọc mã. Kết nối Replyn đang ở chế độ thử nghiệm.';

enum _Step { review, confirming, prototypeDone, expired }

class ReplynPairingConfirmScreen extends StatefulWidget {
  const ReplynPairingConfirmScreen({
    required this.request,
    required this.accountSource,
    required this.pairingService,
    this.now,
    super.key,
  });

  final ReplynPairingRequest request;
  final ReplynAccountSource accountSource;
  final ReplynPairingService pairingService;
  final DateTime Function()? now;

  @override
  State<ReplynPairingConfirmScreen> createState() =>
      _ReplynPairingConfirmScreenState();
}

class _ReplynPairingConfirmScreenState
    extends State<ReplynPairingConfirmScreen> {
  _Step _step = _Step.review;

  bool get _expired {
    final expiresAt = widget.request.expiresAt;
    return expiresAt != null &&
        (widget.now ?? DateTime.now)().toUtc().isAfter(expiresAt);
  }

  Future<void> _confirm(NovaTalentIdentity talent) async {
    if (_step != _Step.review) return;
    if (_expired) {
      setState(() => _step = _Step.expired);
      return;
    }
    setState(() => _step = _Step.confirming);
    final outcome = await widget.pairingService.confirm(widget.request, talent);
    if (!mounted) return;
    setState(() {
      _step = switch (outcome) {
        ReplynPairingOutcome.prototypeOnly => _Step.prototypeDone,
      };
    });
  }

  void _leave(ReplynConfirmResult result) => Navigator.of(context).pop(result);

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        foregroundColor: theme.textPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: theme.systemOverlayStyle,
        titleSpacing: 0,
        title: const Text(
          'Xác nhận đăng nhập Replyn',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: switch (_step) {
              _Step.prototypeDone => _Outcome(
                icon: Icons.info_outline_rounded,
                color: theme.primary,
                title: replynPrototypeMessage,
                body: 'Replyn chưa được đăng nhập. Điện thoại không lưu phiên hay mã nào từ lần quét này.',
                onScanAnother: () => _leave(ReplynConfirmResult.scanAnother),
                onClose: () => _leave(ReplynConfirmResult.close),
              ),
              _Step.expired => _Outcome(
                icon: Icons.timer_off_outlined,
                color: theme.warning,
                title: 'Mã đã hết hạn',
                body: 'Hãy tạo mã mới trên Replyn rồi quét lại.',
                onScanAnother: () => _leave(ReplynConfirmResult.scanAnother),
                onClose: () => _leave(ReplynConfirmResult.close),
              ),
              _ => ListenableBuilder(
                listenable: widget.accountSource,
                builder: (context, _) => _Review(
                  request: widget.request,
                  source: widget.accountSource,
                  busy: _step == _Step.confirming,
                  onConfirm: _confirm,
                  onCancel: () => _leave(ReplynConfirmResult.cancelled),
                ),
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _Review extends StatelessWidget {
  const _Review({
    required this.request,
    required this.source,
    required this.busy,
    required this.onConfirm,
    required this.onCancel,
  });

  final ReplynPairingRequest request;
  final ReplynAccountSource source;
  final bool busy;
  final ValueChanged<NovaTalentIdentity> onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final talent = source.identity;
    final label = TextStyle(
      color: theme.textSecondary,
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _Panel(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.laptop_mac_rounded, color: theme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Replyn',
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Đăng nhập Replyn trên trình duyệt',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.displayOrigin,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text('Tài khoản Nova', style: label),
        const SizedBox(height: 8),
        _Panel(
          child: _Account(talent: talent, source: source),
        ),
        const SizedBox(height: 16),
        Text(
          'Xác nhận để dùng tài khoản này đăng nhập Replyn trên thiết bị vừa hiển thị mã. '
          'Chỉ xác nhận nếu chính bạn vừa mở Replyn.',
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.science_outlined, size: 16, color: theme.warning),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Kết nối Replyn đang ở chế độ thử nghiệm.',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.primary,
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: talent == null || busy ? null : () => onConfirm(talent),
          child: busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : const Text('Xác nhận trên Nova'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.textPrimary,
            side: BorderSide(color: theme.border),
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: busy ? null : onCancel,
          child: const Text('Hủy'),
        ),
      ],
    );
  }
}

class _Account extends StatelessWidget {
  const _Account({required this.talent, required this.source});

  final NovaTalentIdentity? talent;
  final ReplynAccountSource source;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    final talent = this.talent;
    if (talent == null) {
      return Row(
        children: [
          if (!source.failed)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            )
          else
            Icon(Icons.error_outline_rounded, color: theme.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              source.failed
                  ? 'Không tải được tài khoản Nova. Hãy thử lại sau.'
                  : 'Đang tải tài khoản Nova…',
              style: TextStyle(color: theme.textSecondary, fontSize: 13.5),
            ),
          ),
        ],
      );
    }
    final avatar = source.avatar;
    final details = [
      'Talent · Freelancer',
      if (talent.profileId != null) 'Mã hồ sơ Nova ${talent.profileId}',
      if (talent.email != null) talent.email!,
    ];
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: theme.surfaceSubtle,
          foregroundImage: avatar,
          onForegroundImageError: avatar == null ? null : (_, _) {},
          child: Text(
            talent.initials,
            style: TextStyle(color: theme.primary, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                talent.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              for (final line in details)
                Text(
                  line,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.textSecondary, fontSize: 12.5),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Outcome extends StatelessWidget {
  const _Outcome({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.onScanAnother,
    required this.onClose,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final VoidCallback onScanAnother;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      children: [
        Icon(icon, size: 48, color: color),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.primary,
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: onScanAnother,
          child: const Text('Quét mã khác'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.textPrimary,
            side: BorderSide(color: theme.border),
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: onClose,
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.nivexTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border),
      ),
      child: child,
    );
  }
}
