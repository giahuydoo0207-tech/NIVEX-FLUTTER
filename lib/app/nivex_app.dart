import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_theme.dart';
import 'package:nivex_flutter/features/shell/presentation/app_shell.dart';

class NivexApp extends StatelessWidget {
  const NivexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NIVEX',
      debugShowCheckedModeBanner: false,
      theme: NivexTheme.light,
      home: const AppShell(),
    );
  }
}
