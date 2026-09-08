import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_auth_service.dart';
import 'package:nivex_flutter/features/session/presentation/session_unlock_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionGuard extends StatefulWidget {
  const SessionGuard({
    required this.child,
    required this.authService,
    required this.onSessionExpired,
    this.timeout = const Duration(minutes: 5),
    this.clock = DateTime.now,
    super.key,
  });

  final Widget child;
  final CashoutAuthService authService;
  final VoidCallback onSessionExpired;
  final Duration timeout;
  final Clock clock;

  @override
  State<SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends State<SessionGuard>
    with WidgetsBindingObserver {
  static const _lastActivityKey = 'nivex_last_activity_at';

  Timer? _timer;
  late DateTime _lastActivityAt;
  bool _unlockVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastActivityAt = widget.clock();
    _scheduleTimeout();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _checkSession();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _timer?.cancel();
        _persistLastActivity();
    }
  }

  void _recordActivity() {
    if (_unlockVisible) return;
    _lastActivityAt = widget.clock();
    _scheduleTimeout();
  }

  void _scheduleTimeout() {
    _timer?.cancel();
    final elapsed = widget.clock().difference(_lastActivityAt);
    final remaining = widget.timeout - elapsed;
    if (remaining <= Duration.zero) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showUnlock());
      return;
    }
    _timer = Timer(remaining, _showUnlock);
  }

  void _checkSession() {
    if (widget.clock().difference(_lastActivityAt) >= widget.timeout) {
      _showUnlock();
    } else {
      _scheduleTimeout();
    }
  }

  Future<void> _showUnlock() async {
    if (!mounted || _unlockVisible) return;
    _unlockVisible = true;
    _timer?.cancel();

    final unlocked = await SessionUnlockSheet.show(
      context: context,
      authService: widget.authService,
      clock: widget.clock,
    );
    if (!mounted) return;

    _unlockVisible = false;
    if (!unlocked) {
      widget.onSessionExpired();
      return;
    }

    _lastActivityAt = widget.clock();
    await _persistLastActivity();
    if (mounted) _scheduleTimeout();
  }

  Future<void> _persistLastActivity() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _lastActivityKey,
      _lastActivityAt.toUtc().toIso8601String(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _recordActivity(),
      child: widget.child,
    );
  }
}
