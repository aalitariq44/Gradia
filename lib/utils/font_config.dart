import 'package:fluent_ui/fluent_ui.dart';

/// فئة إعدادات الخطوط العامة للتطبيق
class FontConfig {
  static const String primaryFont = 'Cairo';

  /// إنشاء FluentThemeData مخصص مع خط Cairo
  static FluentThemeData createLightTheme() {
    return FluentThemeData(
      fontFamily: primaryFont,
      brightness: Brightness.light,
    );
  }

  /// إنشاء FluentThemeData مخصص مع خط Cairo للوضع المظلم
  static FluentThemeData createDarkTheme() {
    return FluentThemeData(
      fontFamily: primaryFont,
      brightness: Brightness.dark,
    );
  }
}

/// فئة مساعدة لتطبيق خطوط مخصصة على عناصر معينة
class FontHelper {
  /// تطبيق خط Cairo على TextStyle موجود
  static TextStyle applyCairoFont(TextStyle originalStyle) {
    return originalStyle.copyWith(fontFamily: FontConfig.primaryFont);
  }

  /// إنشاء TextStyle جديد مع خط Cairo
  static TextStyle createCairoStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: FontConfig.primaryFont,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }
}
