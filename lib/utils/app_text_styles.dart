import 'package:fluent_ui/fluent_ui.dart';

/// فئة الأنماط المخصصة للخطوط والنصوص
class AppTextStyles {
  static const String _fontFamily = 'Cairo';

  // أنماط العناوين
  static const TextStyle headline1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700, // Cairo Bold
    height: 1.2,
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700, // Cairo Bold
    height: 1.3,
  );

  static const TextStyle headline3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600, // Cairo SemiBold
    height: 1.3,
  );

  static const TextStyle headline4 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600, // Cairo SemiBold
    height: 1.4,
  );

  static const TextStyle headline5 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600, // Cairo SemiBold
    height: 1.4,
  );

  static const TextStyle headline6 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600, // Cairo SemiBold
    height: 1.4,
  );

  // أنماط النصوص الأساسية
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400, // Cairo Regular
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400, // Cairo Regular
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400, // Cairo Regular
    height: 1.4,
  );

  // أنماط النصوص المميزة
  static const TextStyle bodyBold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700, // Cairo Bold
    height: 1.5,
  );

  static const TextStyle bodyMediumBold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700, // Cairo Bold
    height: 1.5,
  );

  // أنماط النصوص الفرعية
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400, // Cairo Regular
    height: 1.3,
  );

  static const TextStyle captionBold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600, // Cairo SemiBold
    height: 1.3,
  );

  // أنماط التسميات
  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600, // Cairo SemiBold
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600, // Cairo SemiBold
    height: 1.3,
  );

  // أنماط الأزرار
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600, // Cairo SemiBold
    height: 1.2,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600, // Cairo SemiBold
    height: 1.2,
  );

  // أنماط حقول الإدخال
  static const TextStyle input = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400, // Cairo Regular
    height: 1.4,
  );

  static const TextStyle inputLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600, // Cairo SemiBold
    height: 1.4,
  );

  // أنماط الرسائل
  static const TextStyle error = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500, // Cairo Medium
    color: Color(0xFFD13438),
    height: 1.3,
  );

  static const TextStyle success = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500, // Cairo Medium
    color: Color(0xFF107C10),
    height: 1.3,
  );

  static const TextStyle warning = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500, // Cairo Medium
    color: Color(0xFFFF8C00),
    height: 1.3,
  );

  // أنماط التنقل
  static const TextStyle navigationTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700, // Cairo Bold
    height: 1.2,
  );

  static const TextStyle navigationItem = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500, // Cairo Medium
    height: 1.3,
  );

  // أنماط الجداول
  static const TextStyle tableHeader = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700, // Cairo Bold
    height: 1.3,
  );

  static const TextStyle tableCell = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400, // Cairo Regular
    height: 1.4,
  );
}

/// ثوابت الألوان المتعلقة بالخطوط
class AppTextColors {
  static const Color primary = Color(0xFF323130);
  static const Color secondary = Color(0xFF605E5C);
  static const Color disabled = Color(0xFFA19F9D);
  static const Color inverse = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF0078D4);
  static const Color error = Color(0xFFD13438);
  static const Color success = Color(0xFF107C10);
  static const Color warning = Color(0xFFFF8C00);
}
