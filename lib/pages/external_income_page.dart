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
  bool _isLoading = true;

  // Filter controllers
  final TextEditingController _searchController = TextEditingController();
  int? _selectedSchoolId;
  String? _selectedCategory;

  // Statistics
  Map<String, dynamic> _statistics = {};

  final DateFormat _displayDateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final incomes = await ExternalIncomeService.getAllExternalIncomes();
      final schools = await SchoolService.getAllSchools();
      final statistics =
          await ExternalIncomeService.getExternalIncomeStatistics();

      setState(() {
        _allIncomes = incomes;
        _filteredIncomes = incomes;
        _schools = schools;
        _statistics = statistics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('خطأ في تحميل البيانات: $e');
    }
  }

  Future<void> _applyFilters() async {
    setState(() => _isLoading = true);
    try {
      final filteredIncomes =
          await ExternalIncomeService.advancedSearchExternalIncomes(
            searchQuery: _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim(),
            schoolId: _selectedSchoolId,
            category: _selectedCategory,
          );

      setState(() {
        _filteredIncomes = filteredIncomes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('خطأ في تطبيق الفلاتر: $e');
    }
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedSchoolId = null;
      _selectedCategory = null;
      _filteredIncomes = _allIncomes;
    });
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

  Widget _buildStatisticsCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إدارة الواردات الخارجية',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatisticCard(
                  'إجمالي الواردات (الشهر الحالي)',
                  '${NumberFormat('#,##0.00').format(_statistics['monthlyAmount'] ?? 0)} د.ع',
                  FluentIcons.calendar,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatisticCard(
                  'إجمالي الواردات (العام الحالي)',
                  '${NumberFormat('#,##0.00').format(_statistics['yearlyAmount'] ?? 0)} د.ع',
                  FluentIcons.calendar,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatisticCard(
                  'عدد السجلات المعروضة',
                  '${_filteredIncomes.length}',
                  FluentIcons.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).micaBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).micaBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تصفية وبحث',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: InfoLabel(
                  label: 'المدرسة',
                  child: ComboBox<int>(
                    placeholder: const Text('جميع المدارس'),
                    value: _selectedSchoolId,
                    items: _schools
                        .map(
                          (school) => ComboBoxItem<int>(
                            value: school.id!,
                            child: Text(school.nameAr),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedSchoolId = value);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: InfoLabel(
                  label: 'الفئة',
                  child: ComboBox<String>(
                    placeholder: const Text('جميع الفئات'),
                    value: _selectedCategory,
                    items: const [
                      ComboBoxItem(
                        value: 'رسوم دراسية',
                        child: Text('رسوم دراسية'),
                      ),
                      ComboBoxItem(value: 'أنشطة', child: Text('أنشطة')),
                      ComboBoxItem(value: 'خدمات', child: Text('خدمات')),
                      ComboBoxItem(value: 'تبرعات', child: Text('تبرعات')),
                      ComboBoxItem(value: 'مبيعات', child: Text('مبيعات')),
                      ComboBoxItem(value: 'إيجارات', child: Text('إيجارات')),
                      ComboBoxItem(value: 'استشارات', child: Text('استشارات')),
                      ComboBoxItem(value: 'مشاريع', child: Text('مشاريع')),
                      ComboBoxItem(value: 'أخرى', child: Text('أخرى')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: InfoLabel(
                  label: 'بحث',
                  child: TextBox(
                    controller: _searchController,
                    placeholder: 'البحث في تفاصيل الواردات...',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton(
                onPressed: () => print('سيتم إضافة نافذة إضافة الوارد'),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FluentIcons.add, size: 16),
                    SizedBox(width: 4),
                    Text('إضافة وارد'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Button(
                onPressed: _clearFilters,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FluentIcons.clear, size: 16),
                    SizedBox(width: 4),
                    Text('مسح الفلتر'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Button(
                onPressed: _applyFilters,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FluentIcons.filter, size: 16),
                    SizedBox(width: 4),
                    Text('تطبيق الفلتر'),
                  ],
                ),
              ),
              const Spacer(),
              Button(
                onPressed: _loadData,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FluentIcons.refresh, size: 16),
                    SizedBox(width: 4),
                    Text('تحديث'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomesList() {
    if (_isLoading) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(32), child: ProgressRing()),
      );
    }

    if (_filteredIncomes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                FluentIcons.inbox,
                size: 64,
                color: FluentTheme.of(context).inactiveColor,
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد واردات خارجية',
                style: TextStyle(
                  fontSize: 18,
                  color: FluentTheme.of(context).inactiveColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FluentTheme.of(context).accentColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'م',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'نوع الوارد',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'المبلغ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'الفئة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'الوصف',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'التاريخ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'المدرسة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'الإجراءات',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Expanded(
            child: ListView.builder(
              itemCount: _filteredIncomes.length,
              itemBuilder: (context, index) {
                final income = _filteredIncomes[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 1, child: Text('${index + 1}')),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: FluentTheme.of(
                              context,
                            ).accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            income.incomeType,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${NumberFormat('#,##0.00').format(income.amount)} د.ع',
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
                            color: FluentTheme.of(context).micaBackgroundColor,
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
                          income.schoolName ?? '-',
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

  Widget _buildSummaryCard() {
    final displayedTotal = _filteredIncomes.fold<double>(
      0.0,
      (sum, income) => sum + income.amount,
    );
    final displayedAverage = _filteredIncomes.isNotEmpty
        ? displayedTotal / _filteredIncomes.length
        : 0.0;
    final largestAmount = _filteredIncomes.isNotEmpty
        ? _filteredIncomes.map((i) => i.amount).reduce((a, b) => a > b ? a : b)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).micaBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملخص البيانات المعروضة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'إجمالي مبالغ الواردات المعروضة',
                  '${NumberFormat('#,##0.00').format(displayedTotal)} د.ع',
                  FluentIcons.money,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  'متوسط قيمة الوارد الواحد',
                  '${NumberFormat('#,##0.00').format(displayedAverage)} د.ع',
                  FluentIcons.chart,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  'أكبر مبلغ وارد',
                  '${NumberFormat('#,##0.00').format(largestAmount)} د.ع',
                  FluentIcons.up,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  'آخر تحديث',
                  DateFormat('dd/MM/yyyy - HH:mm').format(DateTime.now()),
                  FluentIcons.clock,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
        header: const PageHeader(title: Text('إدارة الواردات الخارجية')),
        content: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStatisticsCards(),
              const SizedBox(height: 16),
              _buildFilterSection(),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: _buildIncomesList()),
                    const SizedBox(height: 16),
                    _buildSummaryCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
