import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart' as flutter_widgets show TextDirection;
import 'package:intl/intl.dart';
import '../models/student_model.dart';
import '../models/school_model.dart';
import '../services/student_service.dart';
import '../services/school_service.dart';
import './student_details_page.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({Key? key}) : super(key: key);

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final StudentService _studentService = StudentService();
  final SchoolService _schoolService = SchoolService();

  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  List<School> _schools = [];
  bool _isLoading = false;

  // متحكمات التصفية
  int? _selectedSchoolId;
  String? _selectedGrade;
  String? _selectedSection;
  String? _selectedStatus;
  String? _selectedGender;

  // إحصائيات
  Map<String, int> _genderCounts = {};

  // قوائم الخيارات
  final List<String> _grades = [
    'الأول الابتدائي',
    'الثاني الابتدائي',
    'الثالث الابتدائي',
    'الرابع الابتدائي',
    'الخامس الابتدائي',
    'السادس الابتدائي',
    'الأول المتوسط',
    'الثاني المتوسط',
    'الثالث المتوسط',
    'الرابع العلمي',
    'الرابع الأدبي',
    'الخامس العلمي',
    'الخامس الأدبي',
    'السادس العلمي',
    'السادس الأدبي',
  ];

  final List<String> _sections = [
    'أ',
    'ب',
    'ج',
    'د',
    'ه',
    'و',
    'ز',
    'ح',
    'ط',
    'ي',
  ];
  final List<String> _statuses = ['نشط', 'منقطع', 'متخرج', 'منتقل'];
  final List<String> _genders = ['ذكر', 'أنثى'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final studentsData = await _studentService.getAllStudents();
      final schoolsData = await _schoolService.getAllSchools();
      final genderCounts = await _studentService.getStudentGenderCounts();

      setState(() {
        _students = studentsData;
        _filteredStudents = studentsData;
        _sortStudents(); // تطبيق الترتيب الافتراضي
        _schools = schoolsData;
        _genderCounts = genderCounts;
      });
    } catch (e) {
      _showErrorDialog('خطأ في تحميل البيانات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sortStudents() {
    // قائمة الترتيب المخصص للصفوف
    const gradeOrder = [
      'الأول الابتدائي',
      'الثاني الابتدائي',
      'الثالث الابتدائي',
      'الرابع الابتدائي',
      'الخامس الابتدائي',
      'السادس الابتدائي',
      'الأول المتوسط',
      'الثاني المتوسط',
      'الثالث المتوسط',
      'الرابع العلمي',
      'الرابع الأدبي',
      'الخامس العلمي',
      'الخامس الأدبي',
      'السادس العلمي',
      'السادس الأدبي',
    ];

    _filteredStudents.sort((a, b) {
      final gradeAIndex = gradeOrder.indexOf(a.grade);
      final gradeBIndex = gradeOrder.indexOf(b.grade);

      // إذا كان الصف غير موجود في القائمة، ضعه في النهاية
      final effectiveGradeAIndex = gradeAIndex == -1
          ? gradeOrder.length
          : gradeAIndex;
      final effectiveGradeBIndex = gradeBIndex == -1
          ? gradeOrder.length
          : gradeBIndex;

      final comparison = effectiveGradeAIndex.compareTo(effectiveGradeBIndex);
      if (comparison != 0) {
        return comparison;
      }

      // إذا كانت الصفوف متساوية، قم بالترتيب حسب الاسم
      return a.name.compareTo(b.name);
    });
  }

  Future<void> _applyFilters() async {
    try {
      final filteredStudents = await _studentService.getFilteredStudents(
        schoolId: _selectedSchoolId,
        grade: _selectedGrade,
        section: _selectedSection,
        status: _selectedStatus,
        gender: _selectedGender,
      );

      setState(() {
        _filteredStudents = filteredStudents;
        _sortStudents(); // تطبيق الترتيب بعد التصفية
      });
    } catch (e) {
      _showErrorDialog('خطأ في التصفية: $e');
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedSchoolId = null;
      _selectedGrade = null;
      _selectedSection = null;
      _selectedStatus = null;
      _selectedGender = null;
      _filteredStudents = _students;
      _sortStudents(); // تطبيق الترتيب بعد مسح التصفية
    });
  }

  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (context) => AddStudentDialog(
        schools: _schools,
        onStudentAdded: () {
          _loadData();
        },
      ),
    );
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
    final school = _schools.firstWhere(
      (s) => s.id == schoolId,
      orElse: () => School(
        nameAr: 'غير محدد',
        schoolTypes: ['ابتدائي'],
        createdAt: DateTime.now(),
      ),
    );
    return school.nameAr;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: flutter_widgets.TextDirection.rtl,
      child: ScaffoldPage(
        header: PageHeader(title: const Text('إدارة الطلاب')),
        content: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: _isLoading
              ? const Center(child: ProgressRing())
              : Column(
                  children: [
                    // شريط التصفية العلوي
                    _buildFilterBar(),
                    const SizedBox(height: 16),

                    // الجدول الرئيسي
                    Expanded(child: _buildStudentsTable()),

                    // الإحصائيات السفلية
                    _buildStatisticsBar(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).micaBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment
            .start, // Align content to the start (right in RTL)
        children: [
          // المدرسة
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('المدرسة'),
              const SizedBox(height: 4),
              ComboBox<int>(
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
                  _applyFilters();
                },
              ),
            ],
          ),
          const SizedBox(width: 8), // Reduced spacing
          // الصف
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('الصف'),
              const SizedBox(height: 4),
              ComboBox<String>(
                placeholder: const Text('جميع الصفوف'),
                value: _selectedGrade,
                items: _grades
                    .map(
                      (grade) => ComboBoxItem<String>(
                        value: grade,
                        child: Text(grade),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedGrade = value);
                  _applyFilters();
                },
              ),
            ],
          ),
          const SizedBox(width: 8), // Reduced spacing
          // الشعبة
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('الشعبة'),
              const SizedBox(height: 4),
              ComboBox<String>(
                placeholder: const Text('جميع الشعب'),
                value: _selectedSection,
                items: _sections
                    .map(
                      (section) => ComboBoxItem<String>(
                        value: section,
                        child: Text(section),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedSection = value);
                  _applyFilters();
                },
              ),
            ],
          ),
          const SizedBox(width: 8), // Reduced spacing
          // الحالة
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('الحالة'),
              const SizedBox(height: 4),
              ComboBox<String>(
                placeholder: const Text('جميع الحالات'),
                value: _selectedStatus,
                items: _statuses
                    .map(
                      (status) => ComboBoxItem<String>(
                        value: status,
                        child: Text(status),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedStatus = value);
                  _applyFilters();
                },
              ),
            ],
          ),
          const SizedBox(width: 8), // Reduced spacing
          // الجنس
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('الجنس'),
              const SizedBox(height: 4),
              ComboBox<String>(
                placeholder: const Text('جميع الأجناس'),
                value: _selectedGender,
                items: _genders
                    .map(
                      (gender) => ComboBoxItem<String>(
                        value: gender,
                        child: Text(gender),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedGender = value);
                  _applyFilters();
                },
              ),
            ],
          ),
          // فاصل وارزار الوظائف على الجانب الآخر
          const Spacer(),
          // فاصل بسيط بين التصفية والأزرار
          Container(width: 1, color: Colors.grey),
          const SizedBox(width: 8),
          // الأزرار الوظيفية
          FilledButton(
            onPressed: _showAddStudentDialog,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(FluentIcons.add),
                SizedBox(width: 4),
                Text('إضافة طالب'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Button(
            onPressed: _loadData,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(FluentIcons.refresh),
                SizedBox(width: 4),
                Text('تحديث'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Button(
            onPressed: () {
              print('Students to print: ${_filteredStudents.length}');
              _showErrorDialog(
                'وظيفة الطباعة لم تنفذ بعد، لكن البيانات جاهزة للطباعة بالترتيب الصحيح.',
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(FluentIcons.print),
                SizedBox(width: 4),
                Text('طباعة'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Button(
            onPressed: _clearFilters,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(FluentIcons.clear_filter),
                SizedBox(width: 4),
                Text('مسح التصفية'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTable() {
    if (_filteredStudents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FluentIcons.people, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا توجد طلاب', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[100]),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // رأس الجدول
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: FluentTheme.of(context).micaBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: const [
                  Expanded(
                    flex: 1,
                    child: Text(
                      'المعرف',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'الاسم',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'المدرسة',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'الصف',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'الشعبة',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'الهاتف',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'الحالة',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'الجنس',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'الرسوم',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'تاريخ المباشرة',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'الإجراءات',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // صفوف البيانات
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredStudents.length,
              itemBuilder: (context, index) {
                final student = _filteredStudents[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      FluentPageRoute(
                        builder: (context) =>
                            StudentDetailsPage(student: student),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[100]),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: Text('${index + 1}')),
                        Expanded(
                          flex: 3,
                          child: Text(
                            student.name,
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(_getSchoolName(student.schoolId)),
                        ),
                        Expanded(flex: 2, child: Text(student.grade)),
                        Expanded(flex: 1, child: Text(student.section)),
                        Expanded(flex: 2, child: Text(student.phone ?? '-')),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(student.status),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              student.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(flex: 1, child: Text(student.gender)),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${student.totalFee.toStringAsFixed(0)} د.ع',
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            DateFormat('yyyy/MM/dd').format(student.startDate),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(FluentIcons.edit, size: 16),
                                onPressed: () {
                                  // TODO: تنفيذ التعديل
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  FluentIcons.delete,
                                  size: 16,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteStudent(student),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'نشط':
        return Colors.green;
      case 'منقطع':
        return Colors.red;
      case 'متخرج':
        return Colors.blue;
      case 'منتقل':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatisticsBar() {
    final totalStudents = _students.length;
    final maleCount = _genderCounts['ذكر'] ?? 0;
    final femaleCount = _genderCounts['أنثى'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).micaBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text('إجمالي الطلاب: $totalStudents'),
          const SizedBox(width: 24),
          Text('الذكور: $maleCount'),
          const SizedBox(width: 16),
          Text('الإناث: $femaleCount'),
          const Spacer(),
          Text(
            'آخر تحديث: ${DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now())}',
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStudent(Student student) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الطالب "${student.name}"؟'),
        actions: [
          Button(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context, false),
          ),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
            ),
            child: const Text('حذف'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _studentService.deleteStudent(student.id!);
        _loadData();
        if (mounted) {
          displayInfoBar(
            context,
            builder: (context, close) => InfoBar(
              title: const Text('تم الحذف'),
              content: const Text('تم حذف الطالب بنجاح'),
              severity: InfoBarSeverity.success,
              onClose: close,
            ),
          );
        }
      } catch (e) {
        _showErrorDialog('خطأ في حذف الطالب: $e');
      }
    }
  }
}

// نافذة إضافة طالب جديد
class AddStudentDialog extends StatefulWidget {
  final List<School> schools;
  final VoidCallback onStudentAdded;

  const AddStudentDialog({
    Key? key,
    required this.schools,
    required this.onStudentAdded,
  }) : super(key: key);

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final StudentService _studentService = StudentService();

  // متحكمات النموذج
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _totalFeeController = TextEditingController();
  final TextEditingController _academicYearController = TextEditingController();

  School? _selectedSchool;
  String _selectedGender = 'ذكر';
  String _selectedGrade = 'الأول الابتدائي';
  String _selectedSection = 'أ';
  String _selectedStatus = 'نشط';
  DateTime _selectedStartDate = DateTime.now();

  bool _isLoading = false;

  // قوائم الصفوف حسب نوع المدرسة
  List<String> get _availableGrades {
    if (_selectedSchool == null) return [];

    List<String> grades = [];
    for (String schoolType in _selectedSchool!.schoolTypes) {
      switch (schoolType) {
        case 'ابتدائي':
          grades.addAll([
            'الأول الابتدائي',
            'الثاني الابتدائي',
            'الثالث الابتدائي',
            'الرابع الابتدائي',
            'الخامس الابتدائي',
            'السادس الابتدائي',
          ]);
          break;
        case 'متوسط':
          grades.addAll(['الأول المتوسط', 'الثاني المتوسط', 'الثالث المتوسط']);
          break;
        case 'إعدادي':
          grades.addAll([
            'الرابع العلمي',
            'الرابع الأدبي',
            'الخامس العلمي',
            'الخامس الأدبي',
            'السادس العلمي',
            'السادس الأدبي',
          ]);
          break;
      }
    }
    return grades.toSet().toList(); // إزالة التكرار
  }

  final List<String> _sections = [
    'أ',
    'ب',
    'ج',
    'د',
    'ه',
    'و',
    'ز',
    'ح',
    'ط',
    'ي',
  ];
  final List<String> _statuses = ['نشط', 'منقطع', 'متخرج', 'منتقل'];
  final List<String> _genders = ['ذكر', 'أنثى'];

  @override
  void dispose() {
    _nameController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    _totalFeeController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSchool == null) {
      _showErrorDialog('يرجى اختيار المدرسة');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final student = Student(
        name: _nameController.text.trim(),
        nationalIdNumber: _nationalIdController.text.trim().isEmpty
            ? null
            : _nationalIdController.text.trim(),
        schoolId: _selectedSchool!.id!,
        grade: _selectedGrade,
        section: _selectedSection,
        academicYear: _academicYearController.text.trim().isEmpty
            ? null
            : _academicYearController.text.trim(),
        gender: _selectedGender,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        totalFee: double.tryParse(_totalFeeController.text) ?? 0.0,
        startDate: _selectedStartDate,
        status: _selectedStatus,
        createdAt: DateTime.now(),
      );

      await _studentService.insertStudent(student);

      if (mounted) {
        Navigator.pop(context);
        widget.onStudentAdded();
        displayInfoBar(
          context,
          builder: (context, close) => InfoBar(
            title: const Text('تم الحفظ'),
            content: const Text('تم إضافة الطالب بنجاح'),
            severity: InfoBarSeverity.success,
            onClose: close,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('خطأ في حفظ الطالب: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: flutter_widgets.TextDirection.rtl,
      child: ContentDialog(
        title: const Text('إضافة طالب جديد'),
        content: SizedBox(
          width: 600,
          height: 500,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // القسم الأول - المعلومات الأساسية
                  const Text(
                    'المعلومات الأساسية',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // الاسم الكامل
                  InfoLabel(
                    label: 'الاسم الكامل *',
                    child: TextFormBox(
                      controller: _nameController,
                      placeholder: 'أدخل الاسم الكامل للطالب',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الاسم مطلوب';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // الرقم الوطني
                      Expanded(
                        child: InfoLabel(
                          label: 'الرقم الوطني',
                          child: TextFormBox(
                            controller: _nationalIdController,
                            placeholder: 'أدخل الرقم الوطني (اختياري)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // الجنس
                      Expanded(
                        child: InfoLabel(
                          label: 'الجنس *',
                          child: ComboBox<String>(
                            value: _selectedGender,
                            items: _genders
                                .map(
                                  (gender) => ComboBoxItem<String>(
                                    value: gender,
                                    child: Text(gender),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedGender = value!);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // القسم الثاني - المعلومات الأكاديمية
                  const Text(
                    'المعلومات الأكاديمية',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // المدرسة
                  InfoLabel(
                    label: 'المدرسة *',
                    child: ComboBox<School>(
                      placeholder: const Text('اختر المدرسة'),
                      value: _selectedSchool,
                      items: widget.schools
                          .map(
                            (school) => ComboBoxItem<School>(
                              value: school,
                              child: Text(school.nameAr),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSchool = value;
                          // إعادة تعيين الصف عند تغيير المدرسة
                          if (_availableGrades.isNotEmpty) {
                            _selectedGrade = _availableGrades.first;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // الصف
                      Expanded(
                        child: InfoLabel(
                          label: 'الصف *',
                          child: ComboBox<String>(
                            value: _availableGrades.contains(_selectedGrade)
                                ? _selectedGrade
                                : null,
                            items: _availableGrades
                                .map(
                                  (grade) => ComboBoxItem<String>(
                                    value: grade,
                                    child: Text(grade),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedGrade = value!);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // الشعبة
                      Expanded(
                        child: InfoLabel(
                          label: 'الشعبة *',
                          child: ComboBox<String>(
                            value: _selectedSection,
                            items: _sections
                                .map(
                                  (section) => ComboBoxItem<String>(
                                    value: section,
                                    child: Text(section),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedSection = value!);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // الرسوم الدراسية
                      Expanded(
                        child: InfoLabel(
                          label: 'الرسوم الدراسية *',
                          child: TextFormBox(
                            controller: _totalFeeController,
                            placeholder: 'أدخل مبلغ الرسوم',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'الرسوم مطلوبة';
                              }
                              if (double.tryParse(value) == null) {
                                return 'يرجى إدخال رقم صحيح';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // السنة الدراسية
                      Expanded(
                        child: InfoLabel(
                          label: 'السنة الدراسية',
                          child: TextFormBox(
                            controller: _academicYearController,
                            placeholder: 'مثال: 2024-2025',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // تاريخ المباشرة
                      Expanded(
                        child: InfoLabel(
                          label: 'تاريخ المباشرة *',
                          child: DatePicker(
                            selected: _selectedStartDate,
                            onChanged: (date) {
                              setState(() => _selectedStartDate = date);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // الحالة
                      Expanded(
                        child: InfoLabel(
                          label: 'الحالة *',
                          child: ComboBox<String>(
                            value: _selectedStatus,
                            items: _statuses
                                .map(
                                  (status) => ComboBoxItem<String>(
                                    value: status,
                                    child: Text(status),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedStatus = value!);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // هاتف الطالب
                  InfoLabel(
                    label: 'هاتف الطالب',
                    child: TextFormBox(
                      controller: _phoneController,
                      placeholder: 'أدخل رقم الهاتف (اختياري)',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          Button(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            onPressed: _isLoading ? null : _saveStudent,
            child: _isLoading
                ? const SizedBox(width: 16, height: 16, child: ProgressRing())
                : const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
