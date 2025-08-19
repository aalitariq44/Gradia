import 'package:fluent_ui/fluent_ui.dart';
import '../models/student_model.dart';
import '../models/school_model.dart';
import '../services/student_service.dart';
import '../services/school_service.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({Key? key}) : super(key: key);

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final StudentService _studentService = StudentService();
  final SchoolService _schoolService = SchoolService();
  List<Student> _students = [];
  List<School> _schools = [];
  bool _isLoading = false;

  // Form controllers
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _classSectionController = TextEditingController();
  final TextEditingController _parentNameController = TextEditingController();
  final TextEditingController _parentPhoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  School? _selectedSchool;
  DateTime _selectedEnrollmentDate = DateTime.now();

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
      setState(() {
        _students = studentsData;
        _schools = schoolsData;
      });
    } catch (e) {
      if (mounted) {
        _showErrorDialog('خطأ في تحميل البيانات: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addStudent() async {
    if (_nameController.text.isEmpty ||
        _studentIdController.text.isEmpty ||
        _selectedSchool == null) {
      _showErrorDialog('يرجى إدخال جميع البيانات المطلوبة');
      return;
    }

    try {
      final student = Student(
        schoolId: _selectedSchool!.id!,
        studentId: _studentIdController.text,
        name: _nameController.text,
        grade: _gradeController.text,
        classSection: _classSectionController.text,
        parentName: _parentNameController.text,
        parentPhone: _parentPhoneController.text,
        address: _addressController.text,
        enrollmentDate: _selectedEnrollmentDate,
        createdAt: DateTime.now(),
      );

      await _studentService.insertStudent(student);
      _clearForm();
      _loadData();
      Navigator.of(context).pop();
      _showSuccessMessage('تم إضافة الطالب بنجاح');
    } catch (e) {
      _showErrorDialog('خطأ في إضافة الطالب: $e');
    }
  }

  Future<void> _deleteStudent(int id) async {
    try {
      await _studentService.deleteStudent(id);
      _loadData();
      _showSuccessMessage('تم حذف الطالب بنجاح');
    } catch (e) {
      _showErrorDialog('خطأ في حذف الطالب: $e');
    }
  }

  void _clearForm() {
    _studentIdController.clear();
    _nameController.clear();
    _gradeController.clear();
    _classSectionController.clear();
    _parentNameController.clear();
    _parentPhoneController.clear();
    _addressController.clear();
    _selectedSchool = null;
    _selectedEnrollmentDate = DateTime.now();
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

  void _showSuccessMessage(String message) {
    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: const Text('نجح'),
        content: Text(message),
        severity: InfoBarSeverity.success,
        onClose: close,
      ),
    );
  }

  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('إضافة طالب جديد'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('المدرسة *'),
                const SizedBox(height: 8),
                ComboBox<School>(
                  placeholder: const Text('اختر المدرسة'),
                  value: _selectedSchool,
                  items: _schools
                      .map(
                        (school) => ComboBoxItem<School>(
                          value: school,
                          child: Text(school.name),
                        ),
                      )
                      .toList(),
                  onChanged: (school) =>
                      setState(() => _selectedSchool = school),
                ),
                const SizedBox(height: 16),
                const Text('رقم الطالب *'),
                const SizedBox(height: 8),
                TextBox(
                  controller: _studentIdController,
                  placeholder: 'أدخل رقم الطالب',
                ),
                const SizedBox(height: 16),
                const Text('اسم الطالب *'),
                const SizedBox(height: 8),
                TextBox(
                  controller: _nameController,
                  placeholder: 'أدخل اسم الطالب',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('الصف'),
                          const SizedBox(height: 8),
                          TextBox(
                            controller: _gradeController,
                            placeholder: 'الصف',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('الشعبة'),
                          const SizedBox(height: 8),
                          TextBox(
                            controller: _classSectionController,
                            placeholder: 'الشعبة',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('اسم ولي الأمر'),
                const SizedBox(height: 8),
                TextBox(
                  controller: _parentNameController,
                  placeholder: 'أدخل اسم ولي الأمر',
                ),
                const SizedBox(height: 16),
                const Text('هاتف ولي الأمر'),
                const SizedBox(height: 8),
                TextBox(
                  controller: _parentPhoneController,
                  placeholder: 'أدخل هاتف ولي الأمر',
                ),
                const SizedBox(height: 16),
                const Text('العنوان'),
                const SizedBox(height: 8),
                TextBox(
                  controller: _addressController,
                  placeholder: 'أدخل العنوان',
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          Button(
            child: const Text('إلغاء'),
            onPressed: () {
              _clearForm();
              Navigator.pop(context);
            },
          ),
          FilledButton(child: const Text('إضافة'), onPressed: _addStudent),
        ],
      ),
    );
  }

  String _getSchoolName(int schoolId) {
    final school = _schools.firstWhere(
      (s) => s.id == schoolId,
      orElse: () => School(name: 'غير محدد', createdAt: DateTime.now()),
    );
    return school.name;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('إدارة الطلاب'),
        commandBar: CommandBar(
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.add),
              label: const Text('إضافة طالب'),
              onPressed: _showAddStudentDialog,
            ),
            CommandBarButton(
              icon: const Icon(FluentIcons.refresh),
              label: const Text('تحديث'),
              onPressed: _loadData,
            ),
          ],
        ),
      ),
      content: _isLoading
          ? const Center(child: ProgressRing())
          : _students.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FluentIcons.people, size: 64, color: Color(0xFF0078D4)),
                  SizedBox(height: 16),
                  Text(
                    'لا يوجد طلاب مسجلون',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'انقر على "إضافة طالب" لبدء إضافة الطلاب',
                    style: TextStyle(fontSize: 14, color: Color(0xFF605E5C)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0078D4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        FluentIcons.people,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      student.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('رقم الطالب: ${student.studentId}'),
                        Text('المدرسة: ${_getSchoolName(student.schoolId)}'),
                        if (student.grade.isNotEmpty)
                          Text('الصف: ${student.grade}'),
                        if (student.classSection.isNotEmpty)
                          Text('الشعبة: ${student.classSection}'),
                        if (student.parentName.isNotEmpty)
                          Text('ولي الأمر: ${student.parentName}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(FluentIcons.edit),
                          onPressed: () {
                            // TODO: Implement edit functionality
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            FluentIcons.delete,
                            color: Colors.red.normal,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => ContentDialog(
                                title: const Text('تأكيد الحذف'),
                                content: Text(
                                  'هل أنت متأكد من حذف الطالب "${student.name}"؟',
                                ),
                                actions: [
                                  Button(
                                    child: const Text('إلغاء'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  FilledButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                        Colors.red.normal,
                                      ),
                                    ),
                                    child: const Text('حذف'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteStudent(student.id!);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _nameController.dispose();
    _gradeController.dispose();
    _classSectionController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
