import 'package:fluent_ui/fluent_ui.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0078D4);
  static const Color secondaryColor = Color(0xFF106EBE);
  static const Color accentColor = Color(0xFF005A9E);

  static const Color successColor = Color(0xFF107C10);
  static const Color warningColor = Color(0xFFFFB900);
  static const Color errorColor = Color(0xFFD13438);
  static const Color infoColor = Color(0xFF0078D4);

  // Light theme
  static FluentThemeData lightTheme = FluentThemeData.light().copyWith(
    brightness: Brightness.light,
    accentColor: AccentColor.swatch({
      'darkest': accentColor,
      'darker': const Color(0xFF106EBE),
      'dark': primaryColor,
      'normal': primaryColor,
      'light': const Color(0xFF40E0F0),
      'lighter': const Color(0xFF70F0FF),
      'lightest': const Color(0xFFA0F8FF),
    }),

    // Card theme
    cardColor: Colors.white,

    // Scaffold background
    scaffoldBackgroundColor: const Color(0xFFF3F2F1),

    // Navigation theme
    navigationPaneTheme: NavigationPaneThemeData(
      backgroundColor: Colors.white,
      highlightColor: primaryColor.withOpacity(0.1),
      selectedIconColor: WidgetStateProperty.all(primaryColor),
      unselectedIconColor: WidgetStateProperty.all(Colors.grey[160]),
      selectedTextStyle: WidgetStateProperty.all(
        const TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
      ),
      unselectedTextStyle: WidgetStateProperty.all(
        TextStyle(color: Colors.grey[160], fontWeight: FontWeight.normal),
      ),
    ),

    // Button theme
    buttonTheme: ButtonThemeData(
      defaultButtonStyle: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed))
            return const Color(0xFF005A9E);
          if (states.contains(WidgetState.hovered))
            return const Color(0xFF40E0F0);
          return primaryColor;
        }),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        elevation: WidgetStateProperty.all(2),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    ),

    // Typography
    typography: Typography.fromBrightness(
      brightness: Brightness.light,
      color: Colors.black,
    ),
  );

  // Dark theme
  static FluentThemeData darkTheme = FluentThemeData.dark().copyWith(
    brightness: Brightness.dark,
    accentColor: AccentColor.swatch({
      'darkest': const Color(0xFF001F3F),
      'darker': const Color(0xFF0047AB),
      'dark': const Color(0xFF0066CC),
      'normal': const Color(0xFF0078D4),
      'light': const Color(0xFF40E0F0),
      'lighter': const Color(0xFF70F0FF),
      'lightest': const Color(0xFFA0F8FF),
    }),

    // Card theme
    cardColor: const Color(0xFF2D2D30),

    // Scaffold background
    scaffoldBackgroundColor: const Color(0xFF1E1E1E),

    // Navigation theme
    navigationPaneTheme: NavigationPaneThemeData(
      backgroundColor: const Color(0xFF2D2D30),
      highlightColor: primaryColor.withOpacity(0.2),
      selectedIconColor: WidgetStateProperty.all(primaryColor),
      unselectedIconColor: WidgetStateProperty.all(Colors.grey[100]),
      selectedTextStyle: WidgetStateProperty.all(
        const TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
      ),
      unselectedTextStyle: WidgetStateProperty.all(
        TextStyle(color: Colors.grey[100], fontWeight: FontWeight.normal),
      ),
    ),

    // Typography
    typography: Typography.fromBrightness(
      brightness: Brightness.dark,
      color: Colors.white,
    ),
  );

  // Text styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: Color(0xFF323130),
  );

  static const TextStyle titleLargeStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Color(0xFF323130),
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Color(0xFF323130),
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Color(0xFF323130),
  );

  static const TextStyle bodyLargeStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Color(0xFF323130),
  );

  static const TextStyle bodyStrongStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF323130),
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Color(0xFF605E5C),
  );

  // Common styles
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets smallPadding = EdgeInsets.all(8.0);
  static const EdgeInsets largePadding = EdgeInsets.all(24.0);

  static const BorderRadius defaultBorderRadius = BorderRadius.all(
    Radius.circular(4.0),
  );
  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(8.0),
  );

  // Box shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
