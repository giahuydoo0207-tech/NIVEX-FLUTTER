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
import 'package:shared_preferences/shared_preferences.dart';

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
  final _navigatorKey = GlobalKey<NavigatorState>();
  NovaApiClient? _homeApi;
  NovaAuthSessionManager? _sessionManager;

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
    _createHomeApi();
    _restoreAuthentication();
  }

  void _createHomeApi() {
    try {
      final config = NovaApiConfig.fromBuild();
      final manager =
          widget.authSessionManager ??
          NovaAuthSessionManager(
            config: config,
            store: SecureNovaAuthSessionStore(origin: config.baseUri.origin),
          );
      manager.onSessionExpired = _handleSessionExpired;
      _sessionManager = manager;
      // Every screen shares this client so an expired access token is renewed
      // once with the refresh token instead of forcing a new login.
      _homeApi = NovaApiClient(
        config: config,
        readToken: () async => (await manager.store.read()).accessToken,
        refreshAccessToken: manager.refreshAccessToken,
      );
    } on ArgumentError {
      // A demo build can run entirely on local fixtures.
      _sessionManager = widget.authSessionManager;
    }
  }

  Future<void> _restoreAuthentication() async {
    if (!widget.showAuthentication) return;

    final manager = _sessionManager;
    if (manager == null) {
      // Without a configured backend there is no server session to restore;
      // keep the simulated login for this device.
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(
        () => _isAuthenticated =
            preferences.getBool('nova_device_has_account') == true,
      );
      return;
    }

    _isRestoringAuthentication = true;
    final result = await manager.restore();
    if (!mounted) return;
    setState(() {
      _isRestoringAuthentication = false;
      // A stored session stays usable while the backend is briefly
      // unreachable; a rejected refresh token always returns to login.
      // Wallet access remains independently protected in AppShell.
      _isAuthenticated = result != NovaSessionRestoreResult.signedOut;
    });
  }

  Future<void> _logout() async {
    await _sessionManager?.logout();
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('nova_device_has_account');
    _returnToLogin();
  }

  void _handleSessionExpired() {
    _returnToLogin();
    final context = _navigatorKey.currentContext;
    if (context != null && context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Phiên đăng nhập đã hết hạn.')),
      );
    }
  }

  void _returnToLogin() {
    if (!mounted || !widget.showAuthentication) return;
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    setState(() => _isAuthenticated = false);
  }

  @override
  void dispose() {
    _homeApi?.close();
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
            navigatorKey: _navigatorKey,
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
      homeApi: _isAuthenticated ? _homeApi : null,
      onLogout: widget.showAuthentication ? _logout : null,
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
