# 🔤 دليل تطبيق خط Cairo في تطبيق Gradia

## 📋 نظرة عامة

تم تحديث تطبيق Gradia بالكامل لاستخدام خط **Cairo** كخط افتراضي في جميع أنحاء التطبيق. يوفر خط Cairo دعماً ممتازاً للغة العربية مع مظهر حديث وأنيق.

## 🚀 الميزات المطبقة

### ✅ تطبيق شامل للخط
- خط Cairo كخط افتراضي لكامل التطبيق
- دعم جميع أوزان الخط (Light, Regular, Medium, SemiBold, Bold)
- تطبيق موحد في الوضع الفاتح والمظلم

### ✅ نظام أنماط محدد مسبقاً
- `AppTextStyles` - مجموعة شاملة من أنماط النصوص
- `AppTextColors` - ألوان محددة ومتسقة
- `FontConfig` - إعدادات مركزية للخطوط

### ✅ أنماط متنوعة
- **العناوين**: 6 مستويات (headline1 إلى headline6)
- **النصوص الأساسية**: bodyLarge, bodyMedium, bodySmall
- **التسميات**: label, labelSmall, inputLabel
- **الأزرار**: button, buttonLarge
- **الرسائل**: error, success, warning
- **التنقل والجداول**: navigationTitle, tableHeader

## 📁 هيكل الملفات

```
lib/
├── utils/
│   ├── app_text_styles.dart    # أنماط النصوص المحددة مسبقاً
│   └── font_config.dart        # إعدادات الخطوط المركزية
├── pages/
│   ├── font_demo_page.dart     # صفحة عرض جميع الأنماط
│   ├── schools_page.dart       # محدث بالأنماط الجديدة
│   └── ...
├── main.dart                   # محدث بإعدادات الخط
└── ...

fonts/                          # مجلد الخطوط
├── Cairo-Regular.ttf
├── Cairo-Bold.ttf
├── Cairo-SemiBold.ttf
├── Cairo-Medium.ttf
├── Cairo-Light.ttf
└── README.md

pubspec.yaml                    # محدث بتكوين الخطوط
```

## 🛠️ خطوات الإعداد

### 1. تحميل خطوط Cairo
```bash
# من Google Fonts
https://fonts.google.com/specimen/Cairo

# أو من GitHub
https://github.com/Gue3bara/Cairo
```

### 2. وضع ملفات الخطوط
ضع الملفات التالية في مجلد `fonts/`:
- `Cairo-Regular.ttf`
- `Cairo-Bold.ttf`
- `Cairo-SemiBold.ttf`
- `Cairo-Medium.ttf`
- `Cairo-Light.ttf`

### 3. تشغيل التطبيق
```bash
flutter clean
flutter pub get
flutter run
```

## 💻 أمثلة الاستخدام

### الاستخدام الأساسي
```dart
import '../utils/app_text_styles.dart';

// عناوين
Text('عنوان رئيسي', style: AppTextStyles.headline1)
Text('عنوان فرعي', style: AppTextStyles.headline3)

// نصوص عادية
Text('نص عادي', style: AppTextStyles.bodyMedium)
Text('نص عريض', style: AppTextStyles.bodyBold)

// تسميات
Text('تسمية حقل', style: AppTextStyles.inputLabel)
Text('تعليق', style: AppTextStyles.caption)
```

### تخصيص الألوان
```dart
Text('نص ملون', 
  style: AppTextStyles.bodyMedium.copyWith(
    color: AppTextColors.accent,
  )
)

Text('رسالة خطأ', style: AppTextStyles.error)
Text('رسالة نجاح', style: AppTextStyles.success)
```

### إنشاء أنماط مخصصة
```dart
import '../utils/font_config.dart';

TextStyle customStyle = FontHelper.createCairoStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: Colors.blue,
);
```

## 🎨 صفحة عرض الخطوط

تم إضافة صفحة خاصة لعرض جميع أنماط الخطوط المتاحة:
- يمكن الوصول إليها من قائمة التنقل الجانبية
- تعرض جميع الأنماط مع أحجامها وأوزانها
- تعرض جميع الألوان المحددة مسبقاً
- مفيدة للمطورين والمصممين

## 📝 إرشادات التطوير

### عند إضافة نصوص جديدة:
1. استخدم `AppTextStyles` قدر الإمكان
2. تجنب تعريف TextStyle جديد إلا عند الضرورة
3. استخدم `AppTextColors` للألوان
4. حافظ على الاتساق في الأحجام والأوزان

### عند تحديث الأنماط:
1. عدل في `app_text_styles.dart` فقط
2. اختبر التغييرات في صفحة عرض الخطوط
3. تأكد من التطبيق في الوضع الفاتح والمظلم

## 🔧 استكشاف الأخطاء

### إذا لم تظهر الخطوط:
1. تأكد من وجود ملفات الخطوط في مجلد `fonts/`
2. تأكد من صحة أسماء الملفات في `pubspec.yaml`
3. شغل `flutter clean && flutter pub get`
4. أعد تشغيل التطبيق

### إذا ظهرت أخطاء في البناء:
1. تأكد من استيراد `app_text_styles.dart`
2. تأكد من وجود جميع الخطوط المطلوبة
3. راجع console للأخطاء المفصلة

## 🎯 النتائج المتوقعة

بعد التطبيق الصحيح:
- ✅ نص عربي واضح وجميل في كامل التطبيق
- ✅ تناسق في الأحجام والأوزان
- ✅ سهولة في الصيانة والتحديث
- ✅ دعم كامل للوضع الفاتح والمظلم
- ✅ أداء محسن وتحميل أسرع

## 📞 الدعم

في حالة وجود مشاكل أو أسئلة:
1. راجع صفحة عرض الخطوط في التطبيق
2. تحقق من ملف `FONT_SETUP.md`
3. راجع console للأخطاء
4. تأكد من تطبيق جميع الخطوات بالترتيب
