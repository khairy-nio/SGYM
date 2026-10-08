class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Gymio';
  static const String appTagline = 'Your Fitness. Your Community. Your Marketplace.';
  static const String appVersion = '1.0.0';

  // Mock User
  static const String mockUserName = 'Mohamed';
  static const String mockUserEmail = 'mohamed@gymio.app';
  static const String mockUserPhone = '+20 100 123 4567';
  static const String mockUserAvatar = 'https://i.pravatar.cc/300?img=68';

  // Image Placeholders (using Unsplash)
  static const String gymImageBase = 'https://images.unsplash.com/photo-';
  static const String productImageBase = 'https://images.unsplash.com/photo-';

  // Spacing
  static const double paddingXS = 4;
  static const double paddingS = 8;
  static const double paddingM = 16;
  static const double paddingL = 24;
  static const double paddingXL = 32;
  static const double paddingXXL = 48;

  // Border Radius
  static const double radiusXS = 4;
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 24;
  static const double radiusXXL = 32;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationVerySlow = Duration(milliseconds: 800);

  // Locations
  static const List<String> mockLocations = [
    'Cairo',
    'Nasr City',
    'New Cairo',
    'Maadi',
    'Heliopolis',
    '6th of October',
  ];

  // Currency
  static const String currency = 'EGP';
}
