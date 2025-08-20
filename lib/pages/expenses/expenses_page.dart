import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart' as flutter_widgets show TextDirection;
import 'package:intl/intl.dart';
import '../../services/expense_service.dart';
import '../../services/school_service.dart';
import '../../models/school_model.dart';
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
  List<School> _schools = [];

  final ExpenseService _expenseService = ExpenseService();
  final SchoolService _schoolService = SchoolService();
  bool _isLoading = true;

  // Filter controllers
  final TextEditingController _searchController = TextEditingController();
  int? _selectedSchoolId;
  String? _selectedExpenseType;
  DateTime? _startDate;
  DateTime? _endDate;

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
      final expenses = await _expenseService.getAllExpenses();
      final schools = await _schoolService.getAllSchools();

      setState(() {
        _allExpenses = expenses;
        _filteredExpenses = expenses;
        _schools = schools;
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
      List<ExpenseModel> filteredExpenses = _allExpenses;

      // تطبيق فلتر البحث النصي
      if (_searchController.text.trim().isNotEmpty) {
        final searchQuery = _searchController.text.trim().toLowerCase();
        filteredExpenses = filteredExpenses
            .where(
              (expense) =>
                  expense.expenseType.toLowerCase().contains(searchQuery) ||
                  (expense.description?.toLowerCase().contains(searchQuery) ??
                      false) ||
                  (expense.notes?.toLowerCase().contains(searchQuery) ?? false),
            )
            .toList();
      }

      // تطبيق فلتر المدرسة
      if (_selectedSchoolId != null) {
        filteredExpenses = filteredExpenses
            .where((expense) => expense.schoolId == _selectedSchoolId)
            .toList();
      }

      // تطبيق فلتر نوع المصروف
      if (_selectedExpenseType != null) {
        filteredExpenses = filteredExpenses
            .where((expense) => expense.expenseType == _selectedExpenseType)
            .toList();
      }

      // تطبيق فلتر التاريخ
      if (_startDate != null) {
        filteredExpenses = filteredExpenses
            .where(
              (expense) =>
                  expense.expenseDate.isAfter(_startDate!) ||
                  expense.expenseDate.isAtSameMomentAs(_startDate!),
            )
            .toList();
      }

      if (_endDate != null) {
        filteredExpenses = filteredExpenses
            .where(
              (expense) =>
                  expense.expenseDate.isBefore(_endDate!) ||
                  expense.expenseDate.isAtSameMomentAs(_endDate!),
            )
            .toList();
      }

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

  Widget _buildActionButtons() {
    return Row(
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
              SizedBox(width: 8),
              Text('إضافة مصروف'),
            ],
          ),
        ),
        const SizedBox(width: 12),
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
          onPressed: _applyFilters,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.filter, size: 16),
              SizedBox(width: 8),
              Text('تطبيق الفلتر'),
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
        const SizedBox(width: 12),
        Button(
          onPressed: () {
            // TODO: استيراد من Excel
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.upload, size: 16),
              SizedBox(width: 8),
              Text('استيراد من Excel'),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Button(
          onPressed: () {
            // TODO: تصدير الى Excel
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.download, size: 16),
              SizedBox(width: 8),
              Text('تصدير الى Excel'),
            ],
          ),
        ),
      ],
    );
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
        await _expenseService.deleteExpense(expense.id!);
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
                  'إدارة المصروفات',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'عرض وإدارة جميع المصروفات في النظام مع إمكانيات البحث والتصفية المتقدمة',
                  style: TextStyle(fontSize: 14, color: Colors.grey[120]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red.light,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  'إجمالي المصروفات',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${NumberFormat('#,##0.00').format(_filteredExpenses.fold<double>(0.0, (sum, expense) => sum + expense.amount))} د.ع',
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
                          setState(() {
                            _selectedSchoolId = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // نوع المصروف
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('نوع المصروف'),
                      const SizedBox(height: 8),
                      ComboBox<String?>(
                        placeholder: const Text('جميع الأنواع'),
                        value: _selectedExpenseType,
                        items: [
                          const ComboBoxItem<String?>(
                            value: null,
                            child: Text('جميع الأنواع'),
                          ),
                          ...ExpenseTypes.allTypes.map(
                            (type) => ComboBoxItem<String?>(
                              value: type,
                              child: Text(type),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedExpenseType = value);
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
                      Button(
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
                      Button(
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
                        placeholder: 'البحث في تفاصيل المصروفات...',
                        suffix: IconButton(
                          icon: const Icon(FluentIcons.search),
                          onPressed: _applyFilters,
                        ),
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

  Widget _buildExpensesList() {
    if (_isLoading) {
      return const Center(child: ProgressRing());
    }

    if (_filteredExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FluentIcons.money, size: 64, color: Colors.grey[120]),
            const SizedBox(height: 16),
            Text(
              'لا توجد مصروفات',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[120],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم يتم العثور على مصروفات تطابق معايير البحث المحددة',
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
              color: Colors.red.light,
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
                    'تسلسل',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'نوع المصروف',
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
                  flex: 2,
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
                  flex: 2,
                  child: Text(
                    'ملاحظات',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
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
              itemCount: _filteredExpenses.length,
              itemBuilder: (context, index) {
                final expense = _filteredExpenses[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[50])),
                  ),
                  child: Row(
                    children: [
                      // تسلسل
                      Expanded(flex: 1, child: Text('${index + 1}')),
                      // نوع المصروف
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
                      // المبلغ
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${NumberFormat('#,##0.00').format(expense.amount)} د.ع',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.dark,
                          ),
                        ),
                      ),
                      // الوصف
                      Expanded(
                        flex: 2,
                        child: Text(
                          expense.description ?? '-',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      // التاريخ
                      Expanded(
                        flex: 2,
                        child: Text(
                          _displayDateFormatter.format(expense.expenseDate),
                        ),
                      ),
                      // المدرسة
                      Expanded(
                        flex: 2,
                        child: Text(
                          expense.schoolName ?? '-',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      // الملاحظات
                      Expanded(
                        flex: 2,
                        child: Text(
                          expense.notes ?? '-',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.grey[120],
                            fontSize: 13,
                          ),
                        ),
                      ),
                      // الإجراءات
                      Expanded(
                        flex: 2,
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
                'ملخص المصروفات المعروضة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'عدد المصروفات: ${_filteredExpenses.length} مصروف',
                style: TextStyle(fontSize: 14, color: Colors.grey[120]),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.light, Colors.red.dark],
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
                  '${NumberFormat('#,##0.00').format(displayedTotal)} د.ع',
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
              // شريط إدارة المصروفات
              _buildManagementBar(),
              const SizedBox(height: 16),

              // قسم التصفية والبحث
              _buildFilterSection(),
              const SizedBox(height: 16),

              // أزرار الإجراءات
              _buildActionButtons(),
              const SizedBox(height: 16),

              // الجدول الرئيسي
              Expanded(child: _buildExpensesList()),

              // معلومات التلخيص
              _buildSummaryCard(),
            ],
          ),
        ),
      ),
    );
  }
}
