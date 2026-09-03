enum AppThemeMode {
  defaultTheme,
  cyberNight,
  blockchainFlow,
  vietnamFuture;

  String get label {
    switch (this) {
      case AppThemeMode.defaultTheme:
        return 'Mặc định';
      case AppThemeMode.cyberNight:
        return 'Cyber Night';
      case AppThemeMode.blockchainFlow:
        return 'Blockchain Flow';
      case AppThemeMode.vietnamFuture:
        return 'Vietnam Future';
    }
  }

  String get description {
    switch (this) {
      case AppThemeMode.defaultTheme:
        return 'Giao diện ngân hàng tinh giản hiện đại';
      case AppThemeMode.cyberNight:
        return 'Chế độ nền tối huyền ảo';
      case AppThemeMode.blockchainFlow:
        return 'Sắc thái gradient Web3 động';
      case AppThemeMode.vietnamFuture:
        return 'Bản sắc Việt Nam, tông sáng & vàng hoàng kim';
    }
  }

  String toStorageString() => name;

  static AppThemeMode fromStorageString(String? value) {
    if (value == null) return AppThemeMode.defaultTheme;
    for (final mode in AppThemeMode.values) {
      if (mode.name == value) return mode;
    }
    return AppThemeMode.defaultTheme;
  }
}
