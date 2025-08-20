import 'package:fluent_ui/fluent_ui.dart';
import '../utils/app_text_styles.dart';

/// صفحة توضيحية لعرض جميع أنماط الخطوط المتاحة
class FontDemoPage extends StatelessWidget {
  const FontDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ScaffoldPage(
        header: PageHeader(
          title: Text('عرض خطوط Cairo', style: AppTextStyles.navigationTitle),
        ),
        content: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عرض العناوين
              _buildSection('العناوين', [
                _buildTextExample('عنوان رئيسي كبير', AppTextStyles.headline1),
                _buildTextExample('عنوان رئيسي متوسط', AppTextStyles.headline2),
                _buildTextExample('عنوان فرعي كبير', AppTextStyles.headline3),
                _buildTextExample('عنوان فرعي متوسط', AppTextStyles.headline4),
                _buildTextExample('عنوان فرعي صغير', AppTextStyles.headline5),
                _buildTextExample('عنوان صغير', AppTextStyles.headline6),
              ]),

              const SizedBox(height: 32),

              // عرض النصوص الأساسية
              _buildSection('النصوص الأساسية', [
                _buildTextExample('نص كبير عادي', AppTextStyles.bodyLarge),
                _buildTextExample('نص متوسط عادي', AppTextStyles.bodyMedium),
                _buildTextExample('نص صغير عادي', AppTextStyles.bodySmall),
                _buildTextExample('نص عريض', AppTextStyles.bodyBold),
                _buildTextExample(
                  'نص متوسط عريض',
                  AppTextStyles.bodyMediumBold,
                ),
              ]),

              const SizedBox(height: 32),

              // عرض التسميات والتعليقات
              _buildSection('التسميات والتعليقات', [
                _buildTextExample('تسمية عادية', AppTextStyles.label),
                _buildTextExample('تسمية صغيرة', AppTextStyles.labelSmall),
                _buildTextExample('تعليق عادي', AppTextStyles.caption),
                _buildTextExample('تعليق عريض', AppTextStyles.captionBold),
              ]),

              const SizedBox(height: 32),

              // عرض أنماط الأزرار
              _buildSection('أنماط الأزرار', [
                _buildTextExample('نص زر عادي', AppTextStyles.button),
                _buildTextExample('نص زر كبير', AppTextStyles.buttonLarge),
              ]),

              const SizedBox(height: 32),

              // عرض أنماط الإدخال
              _buildSection('أنماط الإدخال', [
                _buildTextExample('نص إدخال', AppTextStyles.input),
                _buildTextExample('تسمية إدخال', AppTextStyles.inputLabel),
              ]),

              const SizedBox(height: 32),

              // عرض أنماط الرسائل
              _buildSection('أنماط الرسائل', [
                _buildTextExample('رسالة خطأ', AppTextStyles.error),
                _buildTextExample('رسالة نجاح', AppTextStyles.success),
                _buildTextExample('رسالة تحذير', AppTextStyles.warning),
              ]),

              const SizedBox(height: 32),

              // عرض أنماط التنقل والجداول
              _buildSection('التنقل والجداول', [
                _buildTextExample(
                  'عنوان التنقل',
                  AppTextStyles.navigationTitle,
                ),
                _buildTextExample('عنصر التنقل', AppTextStyles.navigationItem),
                _buildTextExample('رأس الجدول', AppTextStyles.tableHeader),
                _buildTextExample('خلية الجدول', AppTextStyles.tableCell),
              ]),

              const SizedBox(height: 32),

              // عرض الألوان
              _buildColorSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> examples) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.headline4),
            const SizedBox(height: 16),
            ...examples.map(
              (example) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: example,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextExample(String text, TextStyle style) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(text, style: style)),
          Expanded(
            flex: 1,
            child: Text(
              '${style.fontSize?.toInt() ?? 14}px / ${_getFontWeightName(style.fontWeight)}',
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFF605E5C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ألوان النصوص', style: AppTextStyles.headline4),
            const SizedBox(height: 16),
            _buildColorExample('أساسي', AppTextColors.primary),
            _buildColorExample('ثانوي', AppTextColors.secondary),
            _buildColorExample('معطل', AppTextColors.disabled),
            _buildColorExample('معكوس', AppTextColors.inverse),
            _buildColorExample('مميز', AppTextColors.accent),
            _buildColorExample('خطأ', AppTextColors.error),
            _buildColorExample('نجاح', AppTextColors.success),
            _buildColorExample('تحذير', AppTextColors.warning),
          ],
        ),
      ),
    );
  }

  Widget _buildColorExample(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE1DFDD)),
            ),
          ),
          const SizedBox(width: 12),
          Text(name, style: AppTextStyles.bodyMedium),
          const SizedBox(width: 16),
          Text(
            '#${color.value.toRadixString(16).toUpperCase().substring(2)}',
            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFF605E5C),
            ),
          ),
        ],
      ),
    );
  }

  String _getFontWeightName(FontWeight? weight) {
    switch (weight) {
      case FontWeight.w300:
        return 'Light';
      case FontWeight.w400:
        return 'Regular';
      case FontWeight.w500:
        return 'Medium';
      case FontWeight.w600:
        return 'SemiBold';
      case FontWeight.w700:
        return 'Bold';
      default:
        return 'Regular';
    }
  }
}
