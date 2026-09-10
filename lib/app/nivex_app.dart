import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme.dart';
import 'package:nivex_flutter/app/theme/theme_controller.dart';
import 'package:nivex_flutter/features/cashout/data/cashout_auth_state_store.dart';
import 'package:nivex_flutter/features/cashout/data/local_auth_biometric_client.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_auth_service.dart';
import 'package:nivex_flutter/features/auth/presentation/login_screen.dart';
import 'package:nivex_flutter/features/session/presentation/session_guard.dart';
import 'package:nivex_flutter/features/shell/presentation/app_shell.dart';
import 'package:nivex_flutter/shared/constants/app_environment.dart';

class NivexApp extends StatefulWidget {
  const NivexApp({
    super.key,
    this.controller,
    this.showAuthentication = false,
    this.environment = AppEnvironment.demo,
    this.cashoutAuthService,
    this.sessionAuthService,
  });

  final ThemeController? controller;
  final bool showAuthentication;
  final AppEnvironment environment;
  final CashoutAuthService? cashoutAuthService;
  final CashoutAuthService? sessionAuthService;

  @override
  State<NivexApp> createState() => _NivexAppState();
}

class _NivexAppState extends State<NivexApp> {
  late final ThemeController _controller;
  bool _createdOwnController = false;
  bool _isAuthenticated = false;
  late final CashoutAuthService _cashoutAuthService;
  late final CashoutAuthService _sessionAuthService;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = ThemeController();
      _createdOwnController = true;
      _controller.load();
    }
    _cashoutAuthService =
        widget.cashoutAuthService ??
        CashoutAuthService(biometricClient: LocalAuthBiometricClient());
    _sessionAuthService =
        widget.sessionAuthService ??
        CashoutAuthService(
          biometricClient: LocalAuthBiometricClient(),
          stateStore: SecureCashoutAuthStateStore(namespace: 'session'),
        );
  }

  @override
  void dispose() {
    if (_createdOwnController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return AppEnvironmentScope(
          environment: widget.environment,
          child: MaterialApp(
            title: 'NIVEX',
            debugShowCheckedModeBanner: false,
            theme: NivexTheme.forMode(_controller.mode),
            home: widget.showAuthentication && !_isAuthenticated
                ? LoginScreen(
                    onLoginSuccess: () =>
                        setState(() => _isAuthenticated = true),
                    biometricClient: _sessionAuthService.biometricClient,
                  )
                : _buildAuthenticatedHome(),
          ),
        );
      },
    );
  }

  Widget _buildAuthenticatedHome() {
    final shell = AppShell(
      themeController: _controller,
      cashoutAuthService: _cashoutAuthService,
    );
    if (!widget.showAuthentication) return shell;

    return SessionGuard(
      authService: _sessionAuthService,
      onSessionExpired: () {
        if (mounted) setState(() => _isAuthenticated = false);
      },
      child: shell,
    );
  }
}
