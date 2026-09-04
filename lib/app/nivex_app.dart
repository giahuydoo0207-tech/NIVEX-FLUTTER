import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme.dart';
import 'package:nivex_flutter/app/theme/theme_controller.dart';
import 'package:nivex_flutter/features/auth/presentation/login_screen.dart';
import 'package:nivex_flutter/features/shell/presentation/app_shell.dart';

class NivexApp extends StatefulWidget {
  const NivexApp({super.key, this.controller, this.showAuthentication = false});

  final ThemeController? controller;
  final bool showAuthentication;

  @override
  State<NivexApp> createState() => _NivexAppState();
}

class _NivexAppState extends State<NivexApp> {
  late final ThemeController _controller;
  bool _createdOwnController = false;
  bool _isAuthenticated = false;

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
        return MaterialApp(
          title: 'NIVEX',
          debugShowCheckedModeBanner: false,
          theme: NivexTheme.forMode(_controller.mode),
          home: widget.showAuthentication && !_isAuthenticated
              ? LoginScreen(
                  onLoginSuccess: () => setState(() => _isAuthenticated = true),
                )
              : AppShell(themeController: _controller),
        );
      },
    );
  }
}
