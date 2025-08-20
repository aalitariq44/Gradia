# تطبيق خط Cairo في التطبيق

تم تحديث التطبيق لاستخدام خط Cairo في جميع أنحاء التطبيق. إليك ما تم تنفيذه:

## 📂 التغييرات المطبقة:

### 1. تحديث pubspec.yaml
- إضافة تكوين خطوط Cairo مع جميع الأوزان (Regular, Bold, SemiBold, Medium, Light)

### 2. تحديث main.dart
- تطبيق خط Cairo كخط افتراضي للتطبيق كاملاً
- إنشاء موضوع مخصص للوضع الفاتح والمظلم

### 3. إنشاء ملفات مساعدة:
- `lib/utils/app_text_styles.dart`: أنماط نصوص محددة مسبقاً
- `lib/utils/font_config.dart`: إعدادات الخطوط العامة

### 4. تحديث صفحة المدارس
- استخدام أنماط النصوص الجديدة
- تطبيق خط Cairo Bold للعناوين والتسميات

## 📥 خطوات التحميل:

### 1. تحميل خطوط Cairo:
```
زيارة: https://fonts.google.com/specimen/Cairo
أو: https://github.com/Gue3bara/Cairo
```

### 2. تحميل الملفات التالية ووضعها في مجلد `fonts/`:
- `Cairo-Regular.ttf`
- `Cairo-Bold.ttf`  
- `Cairo-SemiBold.ttf`
- `Cairo-Medium.ttf`
- `Cairo-Light.ttf`

### 3. تشغيل التطبيق:
```bash
flutter clean
flutter pub get
flutter run
```

## 🎨 استخدام الأنماط:

### في الكود:
```dart
// استخدام الأنماط المحددة مسبقاً
Text('عنوان رئيسي', style: AppTextStyles.headline1),
Text('عنوان فرعي', style: AppTextStyles.headline6),
Text('نص عادي', style: AppTextStyles.bodyMedium),
Text('تسمية', style: AppTextStyles.inputLabel),

// استخدام الألوان المحددة مسبقاً
Text('نص ملون', style: AppTextStyles.bodyMedium.copyWith(
  color: AppTextColors.accent,
)),
```

### الأوزان المتاحة:
- `FontWeight.w300` → Cairo Light
- `FontWeight.w400` → Cairo Regular  
- `FontWeight.w500` → Cairo Medium
- `FontWeight.w600` → Cairo SemiBold
- `FontWeight.w700` → Cairo Bold

## 📋 الميزات:

✅ خط Cairo في كامل التطبيق  
✅ أنماط نصوص محددة مسبقاً  
✅ دعم الوضع الفاتح والمظلم  
✅ ألوان محددة للنصوص  
✅ سهولة التخصيص والصيانة  

## 🔧 التخصيص:

لتغيير الخط أو إضافة أنماط جديدة، قم بتعديل:
- `lib/utils/app_text_styles.dart` للأنماط
- `lib/utils/font_config.dart` للإعدادات العامة
- `pubspec.yaml` لإضافة خطوط جديدة
