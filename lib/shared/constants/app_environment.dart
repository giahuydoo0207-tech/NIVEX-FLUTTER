import 'package:flutter/widgets.dart';

enum AppEnvironment { demo, staging, production }

extension AppEnvironmentConfig on AppEnvironment {
  static AppEnvironment fromBuild() {
    const value = String.fromEnvironment('APP_ENV', defaultValue: 'demo');
    return switch (value.toLowerCase()) {
      'production' || 'prod' => AppEnvironment.production,
      'staging' || 'stage' || 'testnet' => AppEnvironment.staging,
      _ => AppEnvironment.demo,
    };
  }

  bool get isProduction => this == AppEnvironment.production;
  bool get isSimulated => !isProduction;
}

class AppEnvironmentScope extends InheritedWidget {
  const AppEnvironmentScope({
    required this.environment,
    required super.child,
    super.key,
  });

  final AppEnvironment environment;

  static AppEnvironment of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppEnvironmentScope>();
    return scope?.environment ?? AppEnvironment.demo;
  }

  static bool isProduction(BuildContext context) =>
      of(context) == AppEnvironment.production;

  static bool isSimulated(BuildContext context) =>
      of(context) != AppEnvironment.production;

  @override
  bool updateShouldNotify(AppEnvironmentScope oldWidget) =>
      environment != oldWidget.environment;
}
