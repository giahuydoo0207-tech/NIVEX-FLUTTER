import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/nivex_app.dart';
import 'package:nivex_flutter/app/theme/theme_controller.dart';
import 'package:nivex_flutter/shared/constants/app_environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = ThemeController();
  await controller.load();
  runApp(
    NivexApp(
      controller: controller,
      showAuthentication: true,
      environment: AppEnvironmentConfig.fromBuild(),
    ),
  );
}
