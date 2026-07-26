abstract final class AppConstants {
  static const String appName = 'Musix Player';
  static const String appVersion = '1.0.0';

  static const int maxHistoryEntries = 100;
  static const Duration historyMinPlayDuration = Duration(seconds: 5);
  static const Duration historyDedupeWindow = Duration(minutes: 2);

  static const Duration animationDuration = Duration(milliseconds: 300);

  static const double miniPlayerHeightValue = 64.0;
  static const double artworkBorderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double screenHorizontalPadding = 16.0;
}
