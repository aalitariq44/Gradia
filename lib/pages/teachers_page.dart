import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart' as flutter_widgets show TextDirection;
import 'package:intl/intl.dart';
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
  bool _isLoading = false;

  // متحكمات التصفية
  int? _selectedSchoolId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // الإحصائيات
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
      await Future.wait([_loadTeachers(), _loadSchools()]);
      _applyFilters();
      await _loadStatistics();
    } catch (e) {
      _showErrorDialog('خطأ في تحميل البيانات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTeachers() async {
    _teachers = await _teacherService.getAllTeachers();
  }

  Future<void> _loadSchools() async {
    _schools = await _schoolService.getAllSchools();
  }

  Future<void> _loadStatistics() async {
    final totalTeachers = await _teacherService.getTeachersCount();
    final totalClassHours = await _teacherService.getTotalClassHours();
    final totalSalaries = await _teacherService.getTotalSalaries();

    setState(() {
      _totalTeachers = totalTeachers;
      _totalClassHours = totalClassHours;
      _totalSalaries = totalSalaries;
    });
  }

  void _applyFilters() {
    List<Teacher> filtered = List.from(_teachers);

    // تصفية حسب المدرسة
    if (_selectedSchoolId != null) {
      filtered = filtered
          .where((teacher) => teacher.schoolId == _selectedSchoolId)
          .toList();
    }

    // تصفية حسب البحث (اسم المعلم)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((teacher) {
        return teacher.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    setState(() {
      _filteredTeachers = filtered;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedSchoolId = null;
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('نجح'),
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

  void _showAddTeacherDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTeacherDialog(
        schools: _schools,
        onTeacherAdded: () {
          _loadData();
          Navigator.of(context).pop();
          _showSuccessDialog('تم إضافة المعلم بنجاح');
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
          _showSuccessDialog('تم تحديث المعلم بنجاح');
        },
      ),
    );
  }

  void _showDeleteConfirmation(Teacher teacher) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المعلم "${teacher.name}"؟'),
        actions: [
          Button(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await _teacherService.deleteTeacher(teacher.id!);
                Navigator.of(context).pop();
                _loadData();
                _showSuccessDialog('تم حذف المعلم بنجاح');
              } catch (e) {
                Navigator.of(context).pop();
                _showErrorDialog('خطأ في حذف المعلم: ${e.toString()}');
              }
            },
            style: ButtonStyle(
              backgroundColor: ButtonState.all(Colors.red),
            ),
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
              // شريط إدارة المعلمين
              _buildManagementBar(),
              const SizedBox(height: 16),

              // قسم التصفية والبحث
              _buildFilterSection(),
              const SizedBox(height: 16),

              // أزرار الإجراءات
              _buildActionButtons(),
              const SizedBox(height: 16),

              // الجدول الرئيسي
              Expanded(child: _buildTeachersTable()),

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
                  'إدارة المعلمين',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'عرض وإدارة جميع المعلمين في النظام مع إمكانيات البحث والتصفية المتقدمة',
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
                  'إجمالي المعلمين',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_totalTeachers معلم',
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
                const SizedBox(width: 16),
                // حقل البحث: اسم المعلم
                SizedBox(
                  width: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ابحث'),
                      const SizedBox(height: 8),
                      TextBox(
                        controller: _searchController,
                        placeholder: 'اسم المعلم',
                        suffix: IconButton(
                          icon: const Icon(FluentIcons.search),
                          onPressed: _applyFilters,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
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
        FilledButton(
          onPressed: _showAddTeacherDialog,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.add, size: 16),
              SizedBox(width: 8),
              Text('إضافة معلم'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeachersTable() {
    if (_isLoading) {
      return const Center(child: ProgressRing());
    }

    if (_filteredTeachers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FluentIcons.people, size: 64, color: Colors.grey[120]),
            const SizedBox(height: 16),
            Text(
              'لا توجد معلمين',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[120],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم يتم العثور على معلمين يطابقون معايير البحث المحددة',
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
                    'تسلسل',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'الاسم',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
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
                    'عدد الحصص',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'الراتب الشهري',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'رقم الهاتف',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
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
                    'إجراءات',
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
              itemCount: _filteredTeachers.length,
              itemBuilder: (context, index) {
                final teacher = _filteredTeachers[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[50])),
                  ),
                  child: Row(
                    children: [
                      // تسلسل
                      Expanded(flex: 1, child: Text('${index + 1}')),
                      // الاسم
                      Expanded(
                        flex: 3,
                        child: Text(
                          teacher.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      // المدرسة
                      Expanded(
                        flex: 3,
                        child: Text(_getSchoolName(teacher.schoolId)),
                      ),
                      // عدد الحصص
                      Expanded(
                        flex: 2,
                        child: Text('${teacher.classHours}'),
                      ),
                      // الراتب الشهري
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${NumberFormat('#,###').format(teacher.monthlySalary)} د.ع',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.dark,
                          ),
                        ),
                      ),
                      // رقم الهاتف
                      Expanded(
                        flex: 2,
                        child: Text(teacher.phone ?? '-'),
                      ),
                      // ملاحظات
                      Expanded(
                        flex: 3,
                        child: Text(
                          teacher.notes ?? '-',
                          style: TextStyle(
                            color: Colors.grey[120],
                            fontSize: 13,
                          ),
                        ),
                      ),
                      // إجراءات
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                FluentIcons.edit,
                                color: Colors.blue.dark,
                              ),
                              onPressed: () => _showEditTeacherDialog(teacher),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                FluentIcons.delete,
                                color: Colors.red.dark,
                              ),
                              onPressed: () => _showDeleteConfirmation(teacher),
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
                'ملخص المعلمين المعروضين',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'عدد المعلمين: ${_filteredTeachers.length} معلم',
                style: TextStyle(fontSize: 14, color: Colors.grey[120]),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.light, Colors.orange.dark],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'إجمالي الحصص',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_totalClassHours حصة',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.light, Colors.green.dark],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'إجمالي الرواتب',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${NumberFormat('#,###').format(_totalSalaries)} د.ع',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
