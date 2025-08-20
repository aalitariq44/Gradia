import 'package:flutter/material.dart';
import '../models/teacher_model.dart';
import '../models/school_model.dart';
import '../services/teacher_service.dart';
import '../services/school_service.dart';
import 'add_teacher_dialog.dart';
import 'edit_teacher_dialog.dart';

class TeachersPage extends StatefulWidget {
  const TeachersPage({super.key});

  @override
  State<TeachersPage> createState() => _TeachersPageState();
}

class _TeachersPageState extends State<TeachersPage> {
  final TeacherService _teacherService = TeacherService();
  final SchoolService _schoolService = SchoolService();

  List<Teacher> _teachers = [];
  List<Teacher> _filteredTeachers = [];
  List<School> _schools = [];

  final TextEditingController _searchController = TextEditingController();
  int? _selectedSchoolId;
  bool _isLoading = true;

  int _totalTeachers = 0;
  int _totalClassHours = 0;
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
      final teachers = await _teacherService.getAllTeachers();
      final schools = await _schoolService.getAllSchools();
      final totalTeachers = await _teacherService.getTeachersCount();
      final totalClassHours = await _teacherService.getTotalClassHours();
      final totalSalaries = await _teacherService.getTotalSalaries();

      setState(() {
        _teachers = teachers;
        _filteredTeachers = teachers;
        _schools = schools;
        _totalTeachers = totalTeachers;
        _totalClassHours = totalClassHours;
        _totalSalaries = totalSalaries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('خطأ في تحميل البيانات: ${e.toString()}');
    }
  }

  void _filterTeachers() {
    setState(() {
      _filteredTeachers = _teachers.where((teacher) {
        final matchesSearch =
            _searchController.text.isEmpty ||
            teacher.name.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );

        final matchesSchool =
            _selectedSchoolId == null || teacher.schoolId == _selectedSchoolId;

        return matchesSearch && matchesSchool;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedSchoolId = null;
      _filteredTeachers = _teachers;
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

  void _showAddTeacherDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTeacherDialog(
        schools: _schools,
        onTeacherAdded: () {
          _loadData();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showEditTeacherDialog(Teacher teacher) {
    showDialog(
      context: context,
      builder: (context) => EditTeacherDialog(
        teacher: teacher,
        schools: _schools,
        onTeacherUpdated: () {
          _loadData();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showDeleteConfirmation(Teacher teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المعلم "${teacher.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _teacherService.deleteTeacher(teacher.id!);
                Navigator.of(context).pop();
                _loadData();
                _showSuccessSnackBar('تم حذف المعلم بنجاح');
              } catch (e) {
                Navigator.of(context).pop();
                _showErrorSnackBar('خطأ في حذف المعلم: ${e.toString()}');
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
        title: const Text('إدارة المعلمين'),
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
                                _filterTeachers();
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
                              onChanged: (_) => _filterTeachers(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _filterTeachers,
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
                            onPressed: _showAddTeacherDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('إضافة معلم'),
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
                    child: _filteredTeachers.isEmpty
                        ? const Center(
                            child: Text(
                              'لا توجد معلمين',
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
                                DataColumn(label: Text('عدد الحصص')),
                                DataColumn(label: Text('الراتب الشهري')),
                                DataColumn(label: Text('رقم الهاتف')),
                                DataColumn(label: Text('ملاحظات')),
                                DataColumn(label: Text('إجراءات')),
                              ],
                              rows: _filteredTeachers.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final teacher = entry.value;
                                return DataRow(
                                  color:
                                      MaterialStateProperty.resolveWith<Color?>(
                                        (states) => index % 2 == 0
                                            ? Colors.grey.shade50
                                            : Colors.white,
                                      ),
                                  cells: [
                                    DataCell(Text('${index + 1}')),
                                    DataCell(Text(teacher.name)),
                                    DataCell(
                                      Text(_getSchoolName(teacher.schoolId)),
                                    ),
                                    DataCell(Text('${teacher.classHours}')),
                                    DataCell(
                                      Text(
                                        '${teacher.monthlySalary.toStringAsFixed(2)} ريال',
                                      ),
                                    ),
                                    DataCell(Text(teacher.phone ?? '-')),
                                    DataCell(
                                      SizedBox(
                                        width: 100,
                                        child: Text(
                                          teacher.notes ?? '-',
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
                                                _showEditTeacherDialog(teacher),
                                            tooltip: 'تعديل',
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                _showDeleteConfirmation(
                                                  teacher,
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
                        'ملخص المعلمين',
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
                              'إجمالي المعلمين',
                              '$_totalTeachers',
                              Icons.people,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'المعروض حالياً',
                              '${_filteredTeachers.length}',
                              Icons.visibility,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'إجمالي الحصص',
                              '$_totalClassHours',
                              Icons.schedule,
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
