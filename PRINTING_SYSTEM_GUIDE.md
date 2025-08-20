# نظام الطباعة المتطور - Gradia

## نظرة عامة
تم إنشاء نظام طباعة متطور وقابل للإعادة الاستخدام في تطبيق Gradia يدعم:

- 📄 طباعة قوائم الطلاب مع تصفية متقدمة
- 🖼️ معاينة قبل الطباعة مع إعدادات قابلة للتخصيص
- 🌐 دعم اللغة العربية مع خط Cairo
- 📊 تخطيط أفقي وعمودي للصفحات
- ⚙️ إعدادات مرنة لحجم الخط والعناوين

## هيكل النظام

```
lib/printing/
├── models/
│   └── print_config.dart          # نموذج إعدادات الطباعة
├── services/
│   ├── printing_service.dart      # خدمة الطباعة الرئيسية
│   └── student_printing_service.dart  # خدمة طباعة الطلاب
├── widgets/
│   └── print_preview_dialog.dart  # نافذة معاينة الطباعة
├── templates/                     # قوالب طباعة (مستقبلية)
└── printing_system.dart          # ملف التصدير الرئيسي
```

## المكتبات المستخدمة

```yaml
dependencies:
  pdf: ^3.10.8        # إنشاء ملفات PDF
  printing: ^5.12.0   # معاينة وطباعة PDF
```

## كيفية الاستخدام

### 1. طباعة قائمة الطلاب
```dart
import '../printing/printing_system.dart';

final printingService = StudentPrintingService();

// طباعة سريعة
await printingService.quickPrintStudents(students, schools);

// طباعة مع إعدادات مخصصة
await printingService.printStudentsList(
  students: filteredStudents,
  schools: schools,
  filters: {'grade': 'الأول الابتدائي'},
  showPreview: true,
);
```

### 2. طباعة تفاصيل طالب واحد
```dart
await printingService.printStudentDetails(
  student: selectedStudent,
  school: studentSchool,
  showPreview: true,
);
```

### 3. طباعة مخصصة لأي بيانات
```dart
final printingService = PrintingService();

await printingService.printTable(
  data: dataList,
  config: PrintConfig(
    title: 'عنوان التقرير',
    subtitle: 'عنوان فرعي',
    orientation: 'landscape',
    fontSize: 10.0,
  ),
);
```

## الميزات المتاحة

### ✅ تم تنفيذها
- [x] خدمة طباعة رئيسية عامة
- [x] خدمة طباعة متخصصة للطلاب
- [x] معاينة قبل الطباعة مع إعدادات
- [x] دعم اللغة العربية وخط Cairo
- [x] تخطيط أفقي وعمودي
- [x] رأس وتذييل الصفحة
- [x] ترقيم الصفحات
- [x] تصفية البيانات قبل الطباعة
- [x] إعدادات مرنة للخطوط والأحجام

### 🔄 في التطوير
- [ ] قوالب طباعة جاهزة
- [ ] طباعة الرسوم البيانية
- [ ] تصدير إلى Excel
- [ ] طباعة شهادات التخرج
- [ ] طباعة كشوف الدرجات

## إعدادات الطباعة المتاحة

### PrintConfig
```dart
PrintConfig(
  title: 'العنوان الرئيسي',           // العنوان الظاهر في رأس الصفحة
  subtitle: 'العنوان الفرعي',         // عنوان فرعي (اختياري)
  includeHeader: true,               // إظهار رأس الصفحة
  includeFooter: true,               // إظهار تذييل الصفحة
  includeDate: true,                 // إظهار تاريخ الطباعة
  includePageNumbers: true,          // إظهار أرقام الصفحات
  fontSize: 10.0,                   // حجم خط المحتوى
  headerFontSize: 14.0,             // حجم خط العنوان
  orientation: 'landscape',          // اتجاه الصفحة (portrait/landscape)
  columnsToShow: [...],             // الأعمدة المراد إظهارها
  columnHeaders: {...},             // رؤوس الأعمدة المخصصة
)
```

### PreviewOptions
```dart
PreviewOptions(
  showPreview: true,        // إظهار معاينة قبل الطباعة
  allowEdit: true,          // السماح بتعديل الإعدادات
  showPrintButton: true,    // إظهار زر الطباعة
  showSaveButton: false,    // إظهار زر الحفظ
)
```

## إضافة طباعة لصفحة جديدة

لإضافة نظام الطباعة لأي صفحة جديدة:

### 1. استيراد النظام
```dart
import '../printing/printing_system.dart';
```

### 2. إنشاء خدمة الطباعة
```dart
class _YourPageState extends State<YourPage> {
  final PrintingService _printingService = PrintingService();
  
  // ... باقي الكود
}
```

### 3. إضافة دالة الطباعة
```dart
Future<void> _printData() async {
  // تحويل البيانات إلى تنسيق قابل للطباعة
  final printData = _convertDataToTableFormat();
  
  // إعداد الطباعة
  final config = PrintConfig(
    title: 'عنوان تقريرك',
    subtitle: 'عنوان فرعي',
    orientation: 'portrait', // أو 'landscape'
  );
  
  // طباعة البيانات
  await _printingService.printTable(
    data: printData,
    config: config,
  );
}
```

### 4. إضافة زر الطباعة
```dart
Button(
  onPressed: _printData,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: const [
      Icon(FluentIcons.print),
      SizedBox(width: 4),
      Text('طباعة'),
    ],
  ),
),
```

## حل المشاكل الشائعة

### مشكلة Developer Mode في Windows
إذا ظهرت رسالة "Building with plugins requires symlink support":

1. افتح الإعدادات: `start ms-settings:developers`
2. فعّل "Developer Mode"
3. أعد تشغيل VS Code والتطبيق

### مشكلة الخط العربي
- تأكد من وجود ملفات خط Cairo في مجلد `fonts/`
- تحقق من إعداد الخطوط في `pubspec.yaml`

### مشكلة المعاينة لا تظهر
- تأكد من تثبيت مكتبات `pdf` و `printing`
- تحقق من تفعيل أذونات الطباعة في النظام

## أمثلة عملية

### طباعة قائمة طلاب صف معين
```dart
final studentsInGrade = await studentService.getFilteredStudents(
  grade: 'الأول الابتدائي',
);

await printingService.printStudentsList(
  students: studentsInGrade,
  schools: schools,
  filters: {'grade': 'الأول الابتدائي'},
);
```

### طباعة إحصائيات الطلاب
```dart
final genderCounts = await studentService.getStudentGenderCounts();
final statusCounts = await studentService.getStudentStatusCounts();
final gradeCounts = await studentService.getStudentGradeCounts();

await printingService.printStudentsStatistics(
  genderCounts: genderCounts,
  statusCounts: statusCounts,
  gradeCounts: gradeCounts,
);
```

## التطوير المستقبلي

### خطة التطوير
1. **إضافة قوالب جاهزة**: قوالب محددة مسبقاً لأنواع مختلفة من التقارير
2. **طباعة الرسوم البيانية**: دعم Charts والرسوم البيانية
3. **تصدير متعدد الصيغ**: Excel, Word, CSV
4. **طباعة الباركود**: لبطاقات الطلاب والموظفين
5. **قوالب شهادات**: شهادات التخرج والتقدير

### كيفية المساهمة
لإضافة ميزات جديدة لنظام الطباعة:

1. أضف الخدمة الجديدة في `services/`
2. إنشاء نموذج البيانات في `models/`
3. إضافة widget المعاينة في `widgets/` إذا لزم الأمر
4. تحديث `printing_system.dart` لتصدير الخدمات الجديدة
5. إضافة الوثائق والأمثلة

---

**ملاحظة**: نظام الطباعة مصمم ليكون مرناً وقابلاً للتوسع. يمكن بسهولة إضافة أنواع جديدة من التقارير دون تعديل الكود الأساسي.
