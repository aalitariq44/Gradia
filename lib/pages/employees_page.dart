import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../models/school_model.dart';
import '../services/employee_service.dart';
import '../services/school_service.dart';
import 'add_employee_dialog.dart';
import 'edit_employee_dialog.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

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

  final TextEditingController _searchController = TextEditingController();
  int? _selectedSchoolId;
  String? _selectedJobType;
  bool _isLoading = true;

  int _totalEmployees = 0;
  double _totalSalaries = 0.0;

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
      final employees = await _employeeService.getAllEmployees();
      final schools = await _schoolService.getAllSchools();
      final jobTypes = await _employeeService.getDistinctJobTypes();
      final totalEmployees = await _employeeService.getEmployeesCount();
      final totalSalaries = await _employeeService.getTotalSalaries();

      setState(() {
        _employees = employees;
        _filteredEmployees = employees;
        _schools = schools;
        _jobTypes = jobTypes;
        _totalEmployees = totalEmployees;
        _totalSalaries = totalSalaries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('خطأ في تحميل البيانات: ${e.toString()}');
    }
  }

  void _filterEmployees() {
    setState(() {
      _filteredEmployees = _employees.where((employee) {
        final matchesSearch =
            _searchController.text.isEmpty ||
            employee.name.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );

        final matchesSchool =
            _selectedSchoolId == null || employee.schoolId == _selectedSchoolId;

        final matchesJobType =
            _selectedJobType == null || employee.jobType == _selectedJobType;

        return matchesSearch && matchesSchool && matchesJobType;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedSchoolId = null;
      _selectedJobType = null;
      _filteredEmployees = _employees;
    });
  }

  String _getSchoolName(int schoolId) {
    final school = _schools.firstWhere(
      (s) => s.id == schoolId,
      orElse: () => School(
        id: 0,
        nameAr: 'غير محدد',
        schoolTypes: [],
        createdAt: DateTime.now(),
      ),
    );
    return school.nameAr;
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
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الموظف "${employee.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _employeeService.deleteEmployee(employee.id!);
                Navigator.of(context).pop();
                _loadData();
                _showSuccessSnackBar('تم حذف الموظف بنجاح');
              } catch (e) {
                Navigator.of(context).pop();
                _showErrorSnackBar('خطأ في حذف الموظف: ${e.toString()}');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الموظفين'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // قسم التحكم والبحث
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // قائمة المدارس
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<int>(
                              value: _selectedSchoolId,
                              decoration: const InputDecoration(
                                labelText: 'تصفية حسب المدرسة',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<int>(
                                  value: null,
                                  child: Text('جميع المدارس'),
                                ),
                                ..._schools.map(
                                  (school) => DropdownMenuItem<int>(
                                    value: school.id,
                                    child: Text(school.nameAr),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedSchoolId = value);
                                _filterEmployees();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // قائمة المهن
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _selectedJobType,
                              decoration: const InputDecoration(
                                labelText: 'تصفية حسب المهنة',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('جميع المهن'),
                                ),
                                ..._jobTypes.map(
                                  (jobType) => DropdownMenuItem<String>(
                                    value: jobType,
                                    child: Text(jobType),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedJobType = value);
                                _filterEmployees();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // حقل البحث
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                labelText: 'البحث بالاسم',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              onChanged: (_) => _filterEmployees(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _filterEmployees,
                            icon: const Icon(Icons.search),
                            label: const Text('بحث'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _clearFilters,
                            icon: const Icon(Icons.clear),
                            label: const Text('مسح الفلتر'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade600,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _loadData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('تحديث'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: _showAddEmployeeDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('إضافة موظف'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // جدول البيانات
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _filteredEmployees.isEmpty
                        ? const Center(
                            child: Text(
                              'لا توجد موظفين',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('#')),
                                DataColumn(label: Text('الاسم')),
                                DataColumn(label: Text('المدرسة')),
                                DataColumn(label: Text('المهنة')),
                                DataColumn(label: Text('الراتب الشهري')),
                                DataColumn(label: Text('رقم الهاتف')),
                                DataColumn(label: Text('ملاحظات')),
                                DataColumn(label: Text('إجراءات')),
                              ],
                              rows: _filteredEmployees.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final employee = entry.value;
                                return DataRow(
                                  color:
                                      MaterialStateProperty.resolveWith<Color?>(
                                        (states) => index % 2 == 0
                                            ? Colors.grey.shade50
                                            : Colors.white,
                                      ),
                                  cells: [
                                    DataCell(Text('${index + 1}')),
                                    DataCell(Text(employee.name)),
                                    DataCell(
                                      Text(_getSchoolName(employee.schoolId)),
                                    ),
                                    DataCell(Text(employee.jobType)),
                                    DataCell(
                                      Text(
                                        '${employee.monthlySalary.toStringAsFixed(2)} ريال',
                                      ),
                                    ),
                                    DataCell(Text(employee.phone ?? '-')),
                                    DataCell(
                                      SizedBox(
                                        width: 100,
                                        child: Text(
                                          employee.notes ?? '-',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () =>
                                                _showEditEmployeeDialog(
                                                  employee,
                                                ),
                                            tooltip: 'تعديل',
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                _showDeleteConfirmation(
                                                  employee,
                                                ),
                                            tooltip: 'حذف',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                ),

                // قسم الملخص
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ملخص الموظفين',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'إجمالي الموظفين',
                              '$_totalEmployees',
                              Icons.people,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'المعروض حالياً',
                              '${_filteredEmployees.length}',
                              Icons.visibility,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'أنواع المهن',
                              '${_jobTypes.length}',
                              Icons.work,
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'إجمالي الرواتب',
                              '${_totalSalaries.toStringAsFixed(2)} ريال',
                              Icons.monetization_on,
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'آخر تحديث: ${DateTime.now().toString().split('.')[0]}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
