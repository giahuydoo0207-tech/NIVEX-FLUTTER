import 'package:flutter/material.dart';
import 'package:nivex_flutter/features/replyn_pairing/presentation/replyn_scanner_screen.dart';

/// Home header action next to the notification bell. Same 44dp target and
/// icon weight as the bell; it opens one scanner at a time.
class ReplynScanButton extends StatefulWidget {
  const ReplynScanButton({this.scannerBuilder, super.key});

  /// Builds the scanner route; tests replace the device camera here.
  final WidgetBuilder? scannerBuilder;

  @override
  State<ReplynScanButton> createState() => _ReplynScanButtonState();
}

class _ReplynScanButtonState extends State<ReplynScanButton> {
  bool _open = false;

  Future<void> _openScanner() async {
    if (_open) return;
    _open = true;
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: widget.scannerBuilder ?? (_) => const ReplynScannerScreen(),
        ),
      );
    } finally {
      _open = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: replynScannerTitle,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        label: replynScannerTitle,
        excludeSemantics: true,
        child: InkWell(
          onTap: _openScanner,
          borderRadius: BorderRadius.circular(20),
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
