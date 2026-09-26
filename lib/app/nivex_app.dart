import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme.dart';
import 'package:nivex_flutter/app/theme/theme_controller.dart';
import 'package:nivex_flutter/features/cashout/data/local_auth_biometric_client.dart';
import 'package:nivex_flutter/features/cashout/domain/cashout_auth_service.dart';
import 'package:nivex_flutter/features/auth/presentation/login_screen.dart';
import 'package:nivex_flutter/features/auth/data/nova_auth_session_manager.dart';
import 'package:nivex_flutter/features/shell/presentation/app_shell.dart';
import 'package:nivex_flutter/shared/api/nova_api_client.dart';
import 'package:nivex_flutter/shared/constants/app_environment.dart';

class NivexApp extends StatefulWidget {
  const NivexApp({
    super.key,
    this.controller,
    this.showAuthentication = false,
    this.environment = AppEnvironment.demo,
    this.cashoutAuthService,
    this.sessionAuthService,
    this.authSessionManager,
  });

  final ThemeController? controller;
  final bool showAuthentication;
  final AppEnvironment environment;
  final CashoutAuthService? cashoutAuthService;
  final CashoutAuthService? sessionAuthService;
  final NovaAuthSessionManager? authSessionManager;

  @override
  State<NivexApp> createState() => _NivexAppState();
}

class _NivexAppState extends State<NivexApp> {
  late final ThemeController _controller;
  bool _createdOwnController = false;
  bool _isAuthenticated = false;
  bool _isRestoringAuthentication = false;
  late final CashoutAuthService _cashoutAuthService;

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
    _restoreAuthentication();
  }

  Future<void> _restoreAuthentication() async {
    if (!widget.showAuthentication) return;

    NovaAuthSessionManager? manager = widget.authSessionManager;
    if (manager == null) {
      try {
        final config = NovaApiConfig.fromBuild();
        manager = NovaAuthSessionManager(
          config: config,
          store: SecureNovaAuthSessionStore(origin: config.baseUri.origin),
        );
      } on ArgumentError {
        return;
      }
    }

    _isRestoringAuthentication = true;
    final result = await manager.restore();
    if (!mounted) return;
    setState(() {
      _isRestoringAuthentication = false;
      _isAuthenticated = result == NovaSessionRestoreResult.authenticated;
    });
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
            title: 'Nova',
            debugShowCheckedModeBanner: false,
            theme: NivexTheme.forMode(_controller.mode),
            home: widget.showAuthentication && _isRestoringAuthentication
                ? const _AuthenticationRestoreScreen()
                : widget.showAuthentication && !_isAuthenticated
                ? LoginScreen(
                    onLoginSuccess: () =>
                        setState(() => _isAuthenticated = true),
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
    return shell;
  }
}

class _AuthenticationRestoreScreen extends StatelessWidget {
  const _AuthenticationRestoreScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
