// مثال على كيفية استخدام نظام الطباعة في أي صفحة

import 'package:fluent_ui/fluent_ui.dart';
import '../printing_system.dart';

class ExamplePrintingPage extends StatefulWidget {
  const ExamplePrintingPage({Key? key}) : super(key: key);

  @override
  State<ExamplePrintingPage> createState() => _ExamplePrintingPageState();
}

class _ExamplePrintingPageState extends State<ExamplePrintingPage> {
  final PrintingService _printingService = PrintingService();
  // ignore: unused_field
  final StudentPrintingService _studentPrintingService =
      StudentPrintingService();

  // مثال على بيانات عامة
  final List<Map<String, dynamic>> _sampleData = [
    {'name': 'أحمد محمد', 'age': 15, 'grade': 'الأول المتوسط', 'score': 95.5},
    {'name': 'فاطمة علي', 'age': 14, 'grade': 'الأول المتوسط', 'score': 87.2},
    {'name': 'محمد أحمد', 'age': 16, 'grade': 'الثاني المتوسط', 'score': 92.8},
  ];

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(title: Text('أمثلة على نظام الطباعة')),
      content: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أمثلة على استخدام نظام الطباعة',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // طباعة سريعة
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1. طباعة سريعة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('طباعة سريعة بإعدادات افتراضية'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _quickPrint,
                      child: const Text('طباعة سريعة'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // طباعة مع إعدادات مخصصة
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '2. طباعة مع إعدادات مخصصة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('طباعة مع تخصيص العنوان والتخطيط'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _customPrint,
                      child: const Text('طباعة مخصصة'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // طباعة تفاصيل
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '3. طباعة تفاصيل',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('طباعة تقرير مفصل مع إحصائيات'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _detailedPrint,
                      child: const Text('طباعة تفاصيل'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // طباعة بدون معاينة
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '4. طباعة مباشرة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('طباعة مباشرة بدون معاينة'),
                    const SizedBox(height: 12),
                    Button(
                      onPressed: _directPrint,
                      child: const Text('طباعة مباشرة'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// طباعة سريعة بإعدادات افتراضية
  Future<void> _quickPrint() async {
    try {
      await _printingService.quickPrint(
        title: 'تقرير سريع',
        data: _sampleData,
        subtitle: 'مثال على الطباعة السريعة',
        showPreview: true,
      );
    } catch (e) {
      _showError('خطأ في الطباعة السريعة: $e');
    }
  }

  /// طباعة مع إعدادات مخصصة
  Future<void> _customPrint() async {
    try {
      final config = PrintConfig(
        title: 'تقرير الطلاب المتميزين',
        subtitle: 'قائمة بأفضل الطلاب للفصل الدراسي الأول',
        orientation: 'landscape', // اتجاه أفقي
        fontSize: 12.0,
        headerFontSize: 18.0,
        includeHeader: true,
        includeFooter: true,
        includeDate: true,
        includePageNumbers: true,
        columnHeaders: {
          'name': 'اسم الطالب',
          'age': 'العمر',
          'grade': 'الصف',
          'score': 'الدرجة',
        },
        columnsToShow: ['name', 'grade', 'score'], // إخفاء العمر
      );

      await _printingService.printTable(
        data: _sampleData,
        config: config,
        previewOptions: const PreviewOptions(
          showPreview: true,
          allowEdit: true,
        ),
      );
    } catch (e) {
      _showError('خطأ في الطباعة المخصصة: $e');
    }
  }

  /// طباعة تقرير مفصل
  Future<void> _detailedPrint() async {
    try {
      // إنشاء بيانات إحصائية
      final statisticsData = [
        {
          'category': 'الإحصائيات',
          'item': 'إجمالي الطلاب',
          'value': '${_sampleData.length}',
        },
        {
          'category': 'الإحصائيات',
          'item': 'متوسط الدرجات',
          'value': _calculateAverage().toStringAsFixed(2),
        },
        {
          'category': 'الإحصائيات',
          'item': 'أعلى درجة',
          'value': _getMaxScore().toStringAsFixed(2),
        },
        {
          'category': 'الإحصائيات',
          'item': 'أقل درجة',
          'value': _getMinScore().toStringAsFixed(2),
        },
      ];

      final config = PrintConfig(
        title: 'تقرير شامل عن أداء الطلاب',
        subtitle: 'إحصائيات مفصلة ومعلومات تحليلية - ${DateTime.now().year}',
        orientation: 'portrait',
        fontSize: 11.0,
        headerFontSize: 16.0,
        columnHeaders: {
          'category': 'التصنيف',
          'item': 'البيان',
          'value': 'القيمة',
        },
      );

      await _printingService.printTable(data: statisticsData, config: config);
    } catch (e) {
      _showError('خطأ في طباعة التفاصيل: $e');
    }
  }

  /// طباعة مباشرة بدون معاينة
  Future<void> _directPrint() async {
    try {
      final config = PrintConfig(
        title: 'طباعة مباشرة',
        subtitle: 'بدون معاينة',
        fontSize: 10.0,
      );

      await _printingService.printTable(
        data: _sampleData,
        config: config,
        previewOptions: const PreviewOptions(showPreview: false),
      );

      _showSuccess('تم إرسال المستند للطباعة مباشرة');
    } catch (e) {
      _showError('خطأ في الطباعة المباشرة: $e');
    }
  }

  /// حساب متوسط الدرجات
  double _calculateAverage() {
    final scores = _sampleData
        .map((student) => student['score'] as double)
        .toList();
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// الحصول على أعلى درجة
  double _getMaxScore() {
    return _sampleData
        .map((student) => student['score'] as double)
        .reduce((a, b) => a > b ? a : b);
  }

  /// الحصول على أقل درجة
  double _getMinScore() {
    return _sampleData
        .map((student) => student['score'] as double)
        .reduce((a, b) => a < b ? a : b);
  }

  /// عرض رسالة خطأ
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          FilledButton(
            child: const Text('موافق'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// عرض رسالة نجاح
  void _showSuccess(String message) {
    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: const Text('نجح'),
        content: Text(message),
        severity: InfoBarSeverity.success,
        onClose: close,
      ),
    );
  }
}

/// مثال على إضافة نظام الطباعة لصفحة موجودة
mixin PrintingMixin<T extends StatefulWidget> on State<T> {
  final PrintingService printingService = PrintingService();

  /// طباعة أي قائمة بيانات
  Future<void> printDataList({
    required String title,
    required List<Map<String, dynamic>> data,
    String subtitle = '',
    String orientation = 'portrait',
    Map<String, String>? columnHeaders,
    List<String>? columnsToShow,
  }) async {
    try {
      final config = PrintConfig(
        title: title,
        subtitle: subtitle,
        orientation: orientation,
        columnHeaders: columnHeaders ?? {},
        columnsToShow: columnsToShow ?? [],
      );

      await printingService.printTable(data: data, config: config);
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ContentDialog(
            title: const Text('خطأ في الطباعة'),
            content: Text(e.toString()),
            actions: [
              FilledButton(
                child: const Text('موافق'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  /// زر طباعة جاهز للاستخدام
  Widget buildPrintButton({
    required String title,
    required List<Map<String, dynamic>> data,
    String buttonText = 'طباعة',
    IconData icon = FluentIcons.print,
  }) {
    return Button(
      onPressed: data.isEmpty
          ? null
          : () => printDataList(title: title, data: data),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon), const SizedBox(width: 4), Text(buttonText)],
      ),
    );
  }
}
