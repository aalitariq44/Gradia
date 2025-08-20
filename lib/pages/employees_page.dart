import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart' as flutter_widgets show TextDirection;
import 'package:intl/intl.dart';
import '../models/employee_model.dart';
import '../models/school_model.dart';
import '../services/employee_service.dart';
import '../services/school_service.dart';
import 'add_employee_dialog.dart';
import 'edit_employee_dialog.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({Key? key}) : super(key: key);

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  final EmployeeService _employeeService = EmployeeService();
  final SchoolService _schoolService = SchoolService();

  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  List<School> _schools = [];
  List<String> _jobTypes = [];
  bool _isLoading = false;

  // متحكمات التصفية
  int? _selectedSchoolId;
  String? _selectedJobType;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // الإحصائيات
  int _totalEmployees = 0;
  double _totalSalaries = 0.0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([_loadEmployees(), _loadSchools(), _loadJobTypes()]);
      _applyFilters();
    } catch (e) {
      _showErrorDialog('خطأ في تحميل البيانات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadEmployees() async {
    _employees = await _employeeService.getAllEmployees();
    _totalEmployees = await _employeeService.getEmployeesCount();
    _totalSalaries = await _employeeService.getTotalSalaries();
  }

  Future<void> _loadSchools() async {
    _schools = await _schoolService.getAllSchools();
  }

  Future<void> _loadJobTypes() async {
    _jobTypes = await _employeeService.getDistinctJobTypes();
  }

  void _applyFilters() {
    List<Employee> filtered = List.from(_employees);

    // تصفية حسب المدرسة
    if (_selectedSchoolId != null) {
      filtered = filtered
          .where((e) => e.schoolId == _selectedSchoolId)
          .toList();
    }

    // تصفية حسب المهنة
    if (_selectedJobType != null && _selectedJobType!.isNotEmpty) {
      filtered = filtered.where((e) => e.jobType == _selectedJobType).toList();
    }

    // تصفية حسب البحث (اسم الموظف)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((e) {
        final employeeName = e.name.toLowerCase();
        final schoolName = _getSchoolName(e.schoolId).toLowerCase();
        return employeeName.contains(_searchQuery.toLowerCase()) ||
            schoolName.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    setState(() {
      _filteredEmployees = filtered;
      _calculateTotals();
    });
  }

  void _calculateTotals() {
    _totalCount = _filteredEmployees.length;
  }

  void _clearFilters() {
    setState(() {
      _selectedSchoolId = null;
      _selectedJobType = null;
      _searchController.clear();
      _searchQuery = '';
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

  String _getSchoolName(int schoolId) {
    try {
      final school = _schools.firstWhere((s) => s.id == schoolId);
      return school.nameAr;
    } catch (e) {
      return 'غير محدد';
    }
  }

  void _showAddEmployeeDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEmployeeDialog(
        schools: _schools,
        onEmployeeAdded: () {
          _loadData();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showEditEmployeeDialog(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => EditEmployeeDialog(
        employee: employee,
        schools: _schools,
        onEmployeeUpdated: () {
          _loadData();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showDeleteConfirmation(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الموظف "${employee.name}"؟'),
        actions: [
          Button(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await _employeeService.deleteEmployee(employee.id!);
                Navigator.of(context).pop();
                _loadData();
                // يمكن إضافة رسالة نجاح هنا
              } catch (e) {
                Navigator.of(context).pop();
                _showErrorDialog('خطأ في حذف الموظف: ${e.toString()}');
              }
            },
            child: const Text('حذف'),
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
              // شريط إدارة الموظفين
              _buildManagementBar(),
              const SizedBox(height: 16),

              // قسم التصفية والبحث
              _buildFilterSection(),
              const SizedBox(height: 16),

              // أزرار الإجراءات
              _buildActionButtons(),
              const SizedBox(height: 16),

              // الجدول الرئيسي
              Expanded(child: _buildEmployeesTable()),

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
                  'إدارة الموظفين',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'عرض وإدارة جميع الموظفين في النظام مع إمكانيات البحث والتصفية المتقدمة',
                  style: TextStyle(fontSize: 14, color: Colors.grey[120]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.light,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  'إجمالي الرواتب',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${NumberFormat('#,###').format(_totalSalaries)} د.ع',
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
                          setState(() => _selectedSchoolId = value);
                          _applyFilters();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // قائمة المهن
                SizedBox(
                  width: 180,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('المهنة'),
                      const SizedBox(height: 8),
                      ComboBox<String?>(
                        placeholder: const Text('جميع المهن'),
                        value: _selectedJobType,
                        items: [
                          const ComboBoxItem<String?>(
                            value: null,
                            child: Text('جميع المهن'),
                          ),
                          ..._jobTypes.map(
                            (jobType) => ComboBoxItem<String?>(
                              value: jobType,
                              child: Text(jobType),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedJobType = value);
                          _applyFilters();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // حقل البحث
                SizedBox(
                  width: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ابحث'),
                      const SizedBox(height: 8),
                      TextBox(
                        controller: _searchController,
                        placeholder: 'اسم الموظف أو المدرسة',
                        suffix: IconButton(
                          icon: const Icon(FluentIcons.search),
                          onPressed: _applyFilters,
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                          _applyFilters();
                        },
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
        Button(
          onPressed: () {
            // TODO: تصدير التقرير
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.document, size: 16),
              SizedBox(width: 8),
              Text('تقرير الموظفين'),
            ],
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: _showAddEmployeeDialog,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.add, size: 16),
              SizedBox(width: 8),
              Text('إضافة موظف'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeesTable() {
    if (_isLoading) {
      return const Center(child: ProgressRing());
    }

    if (_filteredEmployees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FluentIcons.people, size: 64, color: Colors.grey[120]),
            const SizedBox(height: 16),
            Text(
              'لا توجد موظفين',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[120],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم يتم العثور على موظفين يطابقون معايير البحث المحددة',
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
              color: Colors.blue.light,
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
                    '#',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'اسم الموظف',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'المدرسة',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'المهنة',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'الراتب',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'الهاتف',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'الإجراءات',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // صفوف البيانات
          Expanded(
            child: ListView.builder(
              itemCount: _filteredEmployees.length,
              itemBuilder: (context, index) {
                final employee = _filteredEmployees[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[50])),
                    color: index % 2 == 0 ? Colors.grey[10] : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 1, child: Text('${index + 1}')),
                      Expanded(
                        flex: 3,
                        child: Text(
                          employee.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(_getSchoolName(employee.schoolId)),
                      ),
                      Expanded(flex: 2, child: Text(employee.jobType)),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${NumberFormat('#,###').format(employee.monthlySalary)} د.ع',
                          style: TextStyle(
                            color: Colors.green.dark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(flex: 2, child: Text(employee.phone ?? '-')),
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                FluentIcons.edit,
                                color: Colors.blue.normal,
                              ),
                              onPressed: () =>
                                  _showEditEmployeeDialog(employee),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(
                                FluentIcons.delete,
                                color: Colors.red.normal,
                              ),
                              onPressed: () =>
                                  _showDeleteConfirmation(employee),
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
        children: [
          Expanded(
            child: Row(
              children: [
                // إجمالي الموظفين
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.light, Colors.blue.normal],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          FluentIcons.people,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_totalEmployees',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'إجمالي الموظفين',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // المعروض حالياً
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.light, Colors.green.normal],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          FluentIcons.view,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_totalCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'المعروض حالياً',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // أنواع المهن
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.light, Colors.orange.normal],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          FluentIcons.settings,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_jobTypes.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'أنواع المهن',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // إجمالي الرواتب
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.light, Colors.purple.normal],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Icon(FluentIcons.money, color: Colors.white, size: 28),
                const SizedBox(height: 8),
                const Text(
                  'إجمالي الرواتب الشهرية',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${NumberFormat('#,###').format(_totalSalaries)} د.ع',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
