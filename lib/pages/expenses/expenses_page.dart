import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart' as flutter_widgets show TextDirection;
import 'package:intl/intl.dart';
import '../../core/services/expense_service.dart';
import '../../core/services/school_service.dart';
import '../../core/database/models/school_model.dart';
import '../../models/expense_model.dart';
import 'add_expense_dialog.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  List<ExpenseModel> _allExpenses = [];
  List<ExpenseModel> _filteredExpenses = [];
  List<SchoolModel> _schools = [];
  bool _isLoading = true;

  // Filter controllers
  final TextEditingController _searchController = TextEditingController();
  int? _selectedSchoolId;
  String? _selectedExpenseType;
  DateTime? _startDate;
  DateTime? _endDate;

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
      final expenses = await ExpenseService.getAllExpenses();
      final schools = await SchoolService.getAllSchools();
      final statistics = await ExpenseService.getExpenseStatistics();

      setState(() {
        _allExpenses = expenses;
        _filteredExpenses = expenses;
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
      final filteredExpenses = await ExpenseService.advancedSearchExpenses(
        searchQuery: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        schoolId: _selectedSchoolId,
        expenseType: _selectedExpenseType,
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        _filteredExpenses = filteredExpenses;
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
      _selectedExpenseType = null;
      _startDate = null;
      _endDate = null;
      _filteredExpenses = _allExpenses;
    });
  }

  Future<void> _showAddExpenseDialog({ExpenseModel? expense}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddExpenseDialog(expense: expense),
    );

    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _deleteExpense(ExpenseModel expense) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
          'هل أنت متأكد من حذف المصروف "${expense.description ?? expense.expenseType}"؟',
        ),
        actions: [
          Button(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await ExpenseService.deleteExpense(expense.id!);
        await _loadData();
        _showSuccessMessage('تم حذف المصروف بنجاح');
      } catch (e) {
        _showErrorMessage('خطأ في حذف المصروف: $e');
      }
    }
  }

  void _showSuccessMessage(String message) {
    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: const Text('نجح'),
        content: Text(message),
        severity: InfoBarSeverity.success,
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close,
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: const Text('خطأ'),
        content: Text(message),
        severity: InfoBarSeverity.error,
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close,
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) => DatePicker(
        selected: _startDate ?? DateTime.now(),
        onChanged: (date) => Navigator.of(context).pop(date),
      ),
    );

    if (selectedDate != null) {
      setState(() {
        _startDate = selectedDate;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) => DatePicker(
        selected: _endDate ?? DateTime.now(),
        onChanged: (date) => Navigator.of(context).pop(date),
      ),
    );

    if (selectedDate != null) {
      setState(() {
        _endDate = selectedDate;
      });
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
            'إدارة المصروفات',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatisticCard(
                  'إجمالي المصروفات (الشهر الحالي)',
                  '${NumberFormat('#,##0.00').format(_statistics['monthlyAmount'] ?? 0)} د.ع',
                  FluentIcons.calendar,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatisticCard(
                  'إجمالي المصروفات (العام الحالي)',
                  '${NumberFormat('#,##0.00').format(_statistics['yearlyAmount'] ?? 0)} د.ع',
                  FluentIcons.calendar,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatisticCard(
                  'عدد السجلات المعروضة',
                  '${_filteredExpenses.length}',
                  FluentIcons.number,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Button(
                  onPressed: _loadData,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FluentIcons.refresh, size: 16),
                      SizedBox(width: 4),
                      Text('تحديث'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
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
                  label: 'نوع المصروف',
                  child: ComboBox<String>(
                    placeholder: const Text('جميع الأنواع'),
                    value: _selectedExpenseType,
                    items: ExpenseTypes.allTypes
                        .map(
                          (type) => ComboBoxItem<String>(
                            value: type,
                            child: Text(type),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedExpenseType = value);
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
                    placeholder: 'البحث في تفاصيل المصروفات...',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: 'من تاريخ',
                  child: Button(
                    onPressed: _selectStartDate,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _startDate != null
                              ? _displayDateFormatter.format(_startDate!)
                              : 'اختر التاريخ',
                        ),
                        const Icon(FluentIcons.calendar),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InfoLabel(
                  label: 'إلى تاريخ',
                  child: Button(
                    onPressed: _selectEndDate,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _endDate != null
                              ? _displayDateFormatter.format(_endDate!)
                              : 'اختر التاريخ',
                        ),
                        const Icon(FluentIcons.calendar),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton(
                onPressed: () => _showAddExpenseDialog(),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.red),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FluentIcons.add, size: 16),
                    SizedBox(width: 4),
                    Text('إضافة مصروف'),
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
                onPressed: () => print('سيتم إضافة تصدير التقرير'),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FluentIcons.export, size: 16),
                    SizedBox(width: 4),
                    Text('تصدير التقرير'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList() {
    if (_isLoading) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(32), child: ProgressRing()),
      );
    }

    if (_filteredExpenses.isEmpty) {
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
                'لا توجد مصروفات',
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
              color: Colors.red.withOpacity(0.1),
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
                    'نوع المصروف',
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
                    'ملاحظات',
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
              itemCount: _filteredExpenses.length,
              itemBuilder: (context, index) {
                final expense = _filteredExpenses[index];
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
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            expense.expenseType,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${NumberFormat('#,##0.00').format(expense.amount)} د.ع',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          expense.description ?? '-',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          _displayDateFormatter.format(expense.expenseDate),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          expense.schoolName ?? '-',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          expense.notes ?? '-',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () =>
                                  _showAddExpenseDialog(expense: expense),
                              icon: Icon(FluentIcons.edit, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () => _deleteExpense(expense),
                              icon: Icon(FluentIcons.delete, color: Colors.red),
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
    final displayedTotal = _filteredExpenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
    final displayedAverage = _filteredExpenses.isNotEmpty
        ? displayedTotal / _filteredExpenses.length
        : 0.0;
    final largestAmount = _filteredExpenses.isNotEmpty
        ? _filteredExpenses.map((e) => e.amount).reduce((a, b) => a > b ? a : b)
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
                  'إجمالي مبالغ المصروفات المعروضة',
                  '${NumberFormat('#,##0.00').format(displayedTotal)} د.ع',
                  FluentIcons.money,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  'متوسط قيمة المصروف الواحد',
                  '${NumberFormat('#,##0.00').format(displayedAverage)} د.ع',
                  FluentIcons.chart,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  'أكبر مبلغ مصروف',
                  '${NumberFormat('#,##0.00').format(largestAmount)} د.ع',
                  FluentIcons.up,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  'آخر تحديث',
                  DateFormat('dd/MM/yyyy - HH:mm').format(DateTime.now()),
                  FluentIcons.clock,
                  Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
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
        header: const PageHeader(title: Text('إدارة المصروفات')),
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
                    Expanded(child: _buildExpensesList()),
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
