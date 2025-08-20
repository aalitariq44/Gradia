import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart' as flutter_widgets show TextDirection;
import 'package:intl/intl.dart';
import '../core/services/external_income_service.dart';
import '../core/services/school_service.dart';
import '../core/database/models/external_income_model.dart';
import '../core/database/models/school_model.dart';

class ExternalIncomePage extends StatefulWidget {
  const ExternalIncomePage({Key? key}) : super(key: key);

  @override
  State<ExternalIncomePage> createState() => _ExternalIncomePageState();
}

class _ExternalIncomePageState extends State<ExternalIncomePage> {
  List<ExternalIncomeModel> _allIncomes = [];
  List<ExternalIncomeModel> _filteredIncomes = [];
  List<SchoolModel> _schools = [];
  bool _isLoading = false;

  // Filter controllers
  final TextEditingController _searchController = TextEditingController();
  int? _selectedSchoolId;
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Statistics
  double _totalAmount = 0.0;
  int _totalCount = 0;

  final DateFormat _displayDateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([_loadIncomes(), _loadSchools()]);
      _applyFilters();
    } catch (e) {
      _showErrorDialog('خطأ في تحميل البيانات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadIncomes() async {
    _allIncomes = await ExternalIncomeService.getAllExternalIncomes();
  }

  Future<void> _loadSchools() async {
    _schools = await SchoolService.getAllSchools();
  }

  void _applyFilters() {
    List<ExternalIncomeModel> filtered = List.from(_allIncomes);

    // تصفية حسب المدرسة
    if (_selectedSchoolId != null) {
      filtered = filtered
          .where((i) => i.schoolId == _selectedSchoolId)
          .toList();
    }

    // تصفية حسب الفئة
    if (_selectedCategory != null) {
      filtered = filtered
          .where((i) => i.category == _selectedCategory)
          .toList();
    }

    // تصفية حسب نطاق التاريخ
    if (_startDate != null) {
      filtered = filtered
          .where(
            (i) => i.incomeDate.isAfter(
              _startDate!.subtract(const Duration(days: 1)),
            ),
          )
          .toList();
    }
    if (_endDate != null) {
      filtered = filtered
          .where(
            (i) =>
                i.incomeDate.isBefore(_endDate!.add(const Duration(days: 1))),
          )
          .toList();
    }

    // تصفية حسب البحث
    if (_searchController.text.isNotEmpty) {
      final searchQuery = _searchController.text.toLowerCase();
      filtered = filtered.where((i) {
        final title = i.title.toLowerCase();
        final description = (i.description ?? '').toLowerCase();
        final idString = i.id?.toString() ?? '';
        return title.contains(searchQuery) ||
            description.contains(searchQuery) ||
            idString.contains(searchQuery);
      }).toList();
    }

    setState(() {
      _filteredIncomes = filtered;
      _calculateTotals();
    });
  }

  void _calculateTotals() {
    _totalAmount = _filteredIncomes.fold(0.0, (sum, item) => sum + item.amount);
    _totalCount = _filteredIncomes.length;
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedSchoolId = null;
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
      _startDateController.clear();
      _endDateController.clear();
    });
    _applyFilters();
  }

  void _showErrorDialog(String message) {
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

  Future<void> _selectDate(bool isStartDate) async {
    final currentDate = isStartDate ? _startDate : _endDate;
    final TextEditingController dateController = TextEditingController(
      text: currentDate != null
          ? DateFormat('yyyy-MM-dd').format(currentDate)
          : '',
    );

    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(isStartDate ? 'اختر تاريخ البداية' : 'اختر تاريخ النهاية'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormBox(
                controller: dateController,
                placeholder: 'YYYY-MM-DD',
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  try {
                    DateTime.parse(value);
                    return null;
                  } catch (e) {
                    return 'تنسيق التاريخ غير صحيح';
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'أمثلة: 2024-01-15, 2024-12-31',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          Button(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('موافق'),
            onPressed: () {
              try {
                if (dateController.text.isNotEmpty) {
                  final picked = DateTime.parse(dateController.text);
                  setState(() {
                    if (isStartDate) {
                      _startDate = picked;
                      _startDateController.text = DateFormat(
                        'yyyy-MM-dd',
                      ).format(picked);
                    } else {
                      _endDate = picked;
                      _endDateController.text = DateFormat(
                        'yyyy-MM-dd',
                      ).format(picked);
                    }
                  });
                  _applyFilters();
                }
                Navigator.pop(context);
              } catch (e) {
                // إظهار رسالة خطأ
              }
            },
          ),
        ],
      ),
    );
  }

  String _getSchoolName(int? schoolId) {
    if (schoolId == null) return 'غير محدد';
    try {
      final school = _schools.firstWhere((s) => s.id == schoolId);
      return school.nameAr;
    } catch (e) {
      return 'غير محدد';
    }
  }

  Future<void> _deleteIncome(ExternalIncomeModel income) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الوارد "${income.title}"؟'),
        actions: [
          Button(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await ExternalIncomeService.deleteExternalIncome(income.id!);
        await _loadData();
      } catch (e) {
        print('خطأ في حذف الوارد: $e');
      }
    }
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'التصفية والبحث',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Filters row with right alignment and fixed widths
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // قائمة المدارس
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('المدرسة'),
                      const SizedBox(height: 8),
                      ComboBox<int?>(
                        placeholder: const Text('جميع المدارس'),
                        value: _selectedSchoolId,
                        items: [
                          const ComboBoxItem<int?>(
                            value: null,
                            child: Text('جميع المدارس'),
                          ),
                          ..._schools.map(
                            (school) => ComboBoxItem<int?>(
                              value: school.id,
                              child: Text(school.nameAr),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedSchoolId = value);
                          _applyFilters();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // قائمة الفئات
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الفئة'),
                      const SizedBox(height: 8),
                      ComboBox<String?>(
                        placeholder: const Text('جميع الفئات'),
                        value: _selectedCategory,
                        items: const [
                          ComboBoxItem<String?>(
                            value: null,
                            child: Text('جميع الفئات'),
                          ),
                          ComboBoxItem(
                            value: 'رسوم دراسية',
                            child: Text('رسوم دراسية'),
                          ),
                          ComboBoxItem(value: 'أنشطة', child: Text('أنشطة')),
                          ComboBoxItem(value: 'خدمات', child: Text('خدمات')),
                          ComboBoxItem(value: 'تبرعات', child: Text('تبرعات')),
                          ComboBoxItem(value: 'مبيعات', child: Text('مبيعات')),
                          ComboBoxItem(
                            value: 'إيجارات',
                            child: Text('إيجارات'),
                          ),
                          ComboBoxItem(
                            value: 'استشارات',
                            child: Text('استشارات'),
                          ),
                          ComboBoxItem(value: 'مشاريع', child: Text('مشاريع')),
                          ComboBoxItem(value: 'أخرى', child: Text('أخرى')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                          _applyFilters();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // تاريخ البداية
                SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('من تاريخ'),
                      const SizedBox(height: 8),
                      TextFormBox(
                        controller: _startDateController,
                        placeholder: 'اختر تاريخ البداية',
                        readOnly: true,
                        onTap: () => _selectDate(true),
                        suffix: IconButton(
                          icon: const Icon(FluentIcons.calendar),
                          onPressed: () => _selectDate(true),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // تاريخ النهاية
                SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('إلى تاريخ'),
                      const SizedBox(height: 8),
                      TextFormBox(
                        controller: _endDateController,
                        placeholder: 'اختر تاريخ النهاية',
                        readOnly: true,
                        onTap: () => _selectDate(false),
                        suffix: IconButton(
                          icon: const Icon(FluentIcons.calendar),
                          onPressed: () => _selectDate(false),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // حقل البحث
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ابحث'),
                      const SizedBox(height: 8),
                      TextBox(
                        controller: _searchController,
                        placeholder: 'البحث في العنوان أو الوصف...',
                        onChanged: (value) => _applyFilters(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Button(
          onPressed: _clearFilters,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.clear_filter, size: 16),
              SizedBox(width: 8),
              Text('مسح المرشح'),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Button(
          onPressed: _loadData,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.refresh, size: 16),
              SizedBox(width: 8),
              Text('تحديث'),
            ],
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: () => print('سيتم إضافة نافذة إضافة الوارد'),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.add, size: 16),
              SizedBox(width: 8),
              Text('إضافة وارد جديد'),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Button(
          onPressed: () {
            // TODO: تصدير التقرير
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.document, size: 16),
              SizedBox(width: 8),
              Text('تقرير مالي'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIncomesTable() {
    if (_isLoading) {
      return const Center(child: ProgressRing());
    }

    if (_filteredIncomes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FluentIcons.money, size: 64, color: Colors.grey[120]),
            const SizedBox(height: 16),
            Text(
              'لا توجد واردات خارجية',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[120],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم يتم العثور على واردات تطابق معايير البحث المحددة',
              style: TextStyle(fontSize: 14, color: Colors.grey[100]),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]),
      ),
      child: Column(
        children: [
          // رأس الجدول
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.light,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'م',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'العنوان',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'المبلغ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'الفئة',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'الوصف',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'التاريخ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'المدرسة',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'الإجراءات',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // صفوف البيانات
          Expanded(
            child: ListView.builder(
              itemCount: _filteredIncomes.length,
              itemBuilder: (context, index) {
                final income = _filteredIncomes[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[50])),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 1, child: Text('${index + 1}')),
                      Expanded(
                        flex: 2,
                        child: Text(
                          income.title,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${NumberFormat('#,###').format(income.amount)} د.ع',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            income.category,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          income.description ?? '-',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          _displayDateFormatter.format(income.incomeDate),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _getSchoolName(income.schoolId),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () =>
                                  print('سيتم إضافة نافذة التعديل'),
                              icon: const Icon(FluentIcons.edit),
                            ),
                            IconButton(
                              onPressed: () => _deleteIncome(income),
                              icon: const Icon(FluentIcons.delete),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ملخص الواردات المعروضة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'عدد الواردات: $_totalCount وارد',
                style: TextStyle(fontSize: 14, color: Colors.grey[120]),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.light, Colors.green.dark],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  'إجمالي المبلغ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${NumberFormat('#,###').format(_totalAmount)} د.ع',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: flutter_widgets.TextDirection.rtl,
      child: ScaffoldPage(
        content: Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 16),
          child: Column(
            children: [
              // شريط إدارة الواردات الخارجية
              _buildManagementBar(),
              const SizedBox(height: 16),

              // قسم التصفية والبحث
              _buildFilterSection(),
              const SizedBox(height: 16),

              // أزرار الإجراءات
              _buildActionButtons(),
              const SizedBox(height: 16),

              // الجدول الرئيسي
              Expanded(child: _buildIncomesTable()),

              // معلومات التلخيص
              _buildSummarySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إدارة الواردات الخارجية',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'عرض وإدارة جميع الواردات الخارجية في النظام مع إمكانيات البحث والتصفية المتقدمة',
                  style: TextStyle(fontSize: 14, color: Colors.grey[120]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.light,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  'إجمالي الواردات',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${NumberFormat('#,###').format(_totalAmount)} د.ع',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
