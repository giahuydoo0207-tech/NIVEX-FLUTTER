import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';
import 'package:nivex_flutter/features/replyn_pairing/data/camera_permission_gateway.dart';
import 'package:nivex_flutter/features/replyn_pairing/data/nova_account_source.dart';
import 'package:nivex_flutter/features/replyn_pairing/data/qr_camera.dart';
import 'package:nivex_flutter/features/replyn_pairing/domain/replyn_pairing_request.dart';
import 'package:nivex_flutter/features/replyn_pairing/domain/replyn_pairing_service.dart';
import 'package:nivex_flutter/features/replyn_pairing/domain/replyn_qr_parser.dart';
import 'package:nivex_flutter/features/replyn_pairing/presentation/replyn_pairing_confirm_screen.dart';
import 'package:nivex_flutter/features/replyn_pairing/presentation/replyn_scanner_controller.dart';

const replynScannerTitle = 'Quét mã Replyn';

class ReplynScannerScreen extends StatefulWidget {
  const ReplynScannerScreen({
    this.cameraFactory,
    this.permissions,
    this.parser,
    this.accountSource,
    this.pairingService,
    this.now,
    super.key,
  });

  /// Defaults are the device camera, the system permission dialog, the
  /// configured Replyn hosts and the signed-in Nova profile. Without a
  /// [pairingService] there is no Nova session to approve with.
  final QrCamera Function()? cameraFactory;
  final CameraPermissionGateway? permissions;
  final ReplynQrParser? parser;
  final ReplynAccountSource? accountSource;
  final ReplynPairingService? pairingService;
  final DateTime Function()? now;

  @override
  State<ReplynScannerScreen> createState() => _ReplynScannerScreenState();
}

class _ReplynScannerScreenState extends State<ReplynScannerScreen>
    with WidgetsBindingObserver {
  late final QrCamera _camera;
  late final ReplynScannerController _controller;
  late final StreamSubscription<ReplynPairingRequest> _requests;

  @override
  void initState() {
    super.initState();
    _camera = (widget.cameraFactory ?? MobileScannerQrCamera.new)();
    _controller = ReplynScannerController(
      camera: _camera,
      permissions: widget.permissions ?? const PermissionHandlerCameraGateway(),
      parser:
          widget.parser ??
          ReplynQrParser(ReplynQrConfig.fromEnvironment(), now: widget.now),
      now: widget.now,
    );
    _requests = _controller.requests.listen(_confirm);
    WidgetsBinding.instance.addObserver(this);
    unawaited(_controller.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from system Settings may have granted the permission.
    if (state == AppLifecycleState.resumed) {
      unawaited(_controller.recheckPermission());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_requests.cancel());
    _controller.dispose();
    // Releases the camera when the user leaves the scanner.
    unawaited(_camera.dispose());
    super.dispose();
  }

  Future<void> _confirm(ReplynPairingRequest request) async {
    final result = await Navigator.of(context).push<ReplynConfirmResult>(
      MaterialPageRoute(
        builder: (_) => ReplynPairingConfirmScreen(
          request: request,
          accountSource: widget.accountSource ?? ProfileAccountSource(),
          pairingService:
              widget.pairingService ?? const ApiReplynPairingService(null),
          now: widget.now,
        ),
      ),
    );
    if (!mounted) return;
    if (result == ReplynConfirmResult.close) {
      Navigator.of(context).pop();
      return;
    }
    await _controller.resumeScanning();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleSpacing: 0,
          title: const Text(
            replynScannerTitle,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        body: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => _controller.showsCamera
              ? _CameraView(controller: _controller, camera: _camera)
              : _StatusView(controller: _controller),
        ),
      ),
    );
  }
}

class _CameraView extends StatelessWidget {
  const _CameraView({required this.controller, required this.camera});

  final ReplynScannerController controller;
  final QrCamera camera;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = (constraints.maxWidth * 0.68).clamp(200.0, 300.0);
        final window = Rect.fromCenter(
          center: Offset(constraints.maxWidth / 2, constraints.maxHeight * 0.4),
          width: side,
          height: side,
        );
        final phase = controller.phase;
        return Stack(
          fit: StackFit.expand,
          children: [
            camera.buildPreview(
              context,
              onFailure: controller.cameraFailed,
              onStarted: controller.cameraStarted,
            ),
            _ScanOverlay(
              window: window,
              animate:
                  phase == ReplynScanPhase.scanning &&
                  !MediaQuery.disableAnimationsOf(context),
            ),
            // One column under the window, so the result panel and the
            // torch never overlap on short screens.
            Positioned(
              left: 24,
              right: 24,
              top: window.bottom + 16,
              bottom: 16 + MediaQuery.paddingOf(context).bottom,
              child: phase == ReplynScanPhase.rejected
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: _RejectedPanel(controller: controller),
                    )
                  : Column(
                      children: [
                        Text(
                          switch (phase) {
                            ReplynScanPhase.startingCamera =>
                              'Đang khởi động camera…',
                            ReplynScanPhase.processing => 'Đang kiểm tra mã…',
                            _ => 'Đưa mã QR đăng nhập Replyn vào trong khung',
                          },
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                        const Spacer(),
                        if (phase == ReplynScanPhase.scanning)
                          _TorchButton(controller: controller),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _TorchButton extends StatelessWidget {
  const _TorchButton({required this.controller});

  final ReplynScannerController controller;

  @override
  Widget build(BuildContext context) {
    final camera = controller.camera;
    return ValueListenableBuilder<bool?>(
      valueListenable: camera.torchAvailable,
      builder: (context, available, _) {
        if (available != true) return const SizedBox.shrink();
        return ValueListenableBuilder<bool>(
          valueListenable: camera.torchOn,
          builder: (context, on, _) {
            final label = on ? 'Tắt đèn flash' : 'Bật đèn flash';
            return IconButton.filled(
              tooltip: label,
              onPressed: controller.toggleTorch,
              style: IconButton.styleFrom(
                backgroundColor: on ? Colors.white : const Color(0x66000000),
                foregroundColor: on ? Colors.black : Colors.white,
                fixedSize: const Size(52, 52),
              ),
              icon: Icon(
                on ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
                semanticLabel: label,
              ),
            );
          },
        );
      },
    );
  }
}

class _RejectedPanel extends StatelessWidget {
  const _RejectedPanel({required this.controller});

  final ReplynScannerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xE6111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFFCA5A5)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  rejectionMessage(controller.rejection),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: controller.resumeScanning,
              child: const Text('Quét lại'),
            ),
          ),
        ],
      ),
    );
  }
}

/// What the user sees for a refused code. The exact reason stays internal.
String rejectionMessage(ReplynQrRejection? reason) => switch (reason) {
  ReplynQrRejection.expired => 'Mã đã hết hạn. Hãy tạo mã mới trên Replyn.',
  ReplynQrRejection.empty => 'Không đọc được mã. Hãy thử lại.',
  ReplynQrRejection.malformed ||
  ReplynQrRejection.unsupportedScheme ||
  ReplynQrRejection.insecureScheme ||
  ReplynQrRejection.hostNotAllowed ||
  ReplynQrRejection.userInfo ||
  ReplynQrRejection.unexpectedPort => 'Đây không phải mã đăng nhập Replyn.',
  _ => 'Mã Replyn không hợp lệ. Hãy làm mới mã trên Replyn rồi quét lại.',
};

class _StatusView extends StatelessWidget {
  const _StatusView({required this.controller});

  final ReplynScannerController controller;

  @override
  Widget build(BuildContext context) {
    final (icon, title, body, action) = switch (controller.phase) {
      ReplynScanPhase.checkingPermission ||
      ReplynScanPhase.requestingPermission => (
        null,
        'Đang chuẩn bị camera…',
        'Nova cần quyền camera để quét mã QR.',
        null,
      ),
      ReplynScanPhase.permissionDenied => (
        Icons.no_photography_outlined,
        'Chưa có quyền camera',
        'Nova chỉ dùng camera để quét mã QR đăng nhập Replyn.',
        ('Cấp quyền camera', controller.requestPermission),
      ),
      ReplynScanPhase.permissionPermanentlyDenied => (
        Icons.no_photography_outlined,
        'Quyền camera đang bị tắt',
        'Hãy bật quyền Camera cho Nova trong Cài đặt rồi quay lại.',
        ('Mở Cài đặt', controller.openSettings),
      ),
      ReplynScanPhase.unsupported => (
        Icons.videocam_off_outlined,
        'Không tìm thấy camera phù hợp',
        'Thiết bị này không hỗ trợ quét mã QR bằng camera.',
        null,
      ),
      ReplynScanPhase.cameraFailed => (
        Icons.videocam_off_outlined,
        'Không khởi động được camera',
        'Camera có thể đang được ứng dụng khác sử dụng.',
        ('Thử lại', controller.retry),
      ),
      _ => (null, 'Đang mở bước xác nhận…', null, null),
    };
    return SafeArea(
      top: false,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon == null)
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(icon, color: Colors.white70, size: 44),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (body != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (action != null)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: context.nivexTheme.primary,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () => action.$2(),
                      child: Text(action.$1),
                    ),
                  ),
                if (action != null || icon != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Đóng'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Darkens everything outside the scan window and marks its corners.
class _ScanOverlay extends StatefulWidget {
  const _ScanOverlay({required this.window, required this.animate});

  final Rect window;
  final bool animate;

  @override
  State<_ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<_ScanOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _line = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _ScanOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.animate && !_line.isAnimating) {
      _line.repeat(reverse: true);
    } else if (!widget.animate && _line.isAnimating) {
      _line.stop();
    }
  }

  @override
  void dispose() {
    _line.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _OverlayPainter(
          window: widget.window,
          accent: context.nivexTheme.primary,
          line: widget.animate ? _line : null,
        ),
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  _OverlayPainter({required this.window, required this.accent, this.line})
    : super(repaint: line);

  final Rect window;
  final Color accent;
  final Animation<double>? line;

  @override
  void paint(Canvas canvas, Size size) {
    final hole = RRect.fromRectAndRadius(window, const Radius.circular(20));
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(hole),
      ),
      Paint()..color = const Color(0x99000000),
    );

    final corner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const arm = 28.0;
    const r = 20.0;
    for (final (x, y, dx, dy) in [
      (window.left, window.top, 1.0, 1.0),
      (window.right, window.top, -1.0, 1.0),
      (window.left, window.bottom, 1.0, -1.0),
      (window.right, window.bottom, -1.0, -1.0),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(x, y + dy * (r + arm))
          ..lineTo(x, y + dy * r)
          ..quadraticBezierTo(x, y, x + dx * r, y)
          ..lineTo(x + dx * (r + arm), y),
        corner,
      );
    }

    final progress = line?.value;
    if (progress != null) {
      final y = window.top + 16 + (window.height - 32) * progress;
      canvas.drawLine(
        Offset(window.left + 18, y),
        Offset(window.right - 18, y),
        Paint()
          ..color = accent.withValues(alpha: 0.85)
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) =>
      oldDelegate.window != window ||
      oldDelegate.accent != accent ||
      oldDelegate.line != line;
}
