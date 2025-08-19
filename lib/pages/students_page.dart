import 'package:fluent_ui/fluent_ui.dart';
import '../models/student_model.dart';
import '../models/school_model.dart';
import '../services/student_service.dart';
import '../services/school_service.dart';
import '../generated/app_localizations.dart';

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
        final localizations = AppLocalizations.of(context)!;
        _showErrorDialog('${localizations.errorLoadingData}: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addStudent() async {
    final localizations = AppLocalizations.of(context)!;

    if (_nameController.text.isEmpty ||
        _studentIdController.text.isEmpty ||
        _selectedSchool == null) {
      _showErrorDialog(localizations.pleaseEnterAllRequiredData);
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
      _showSuccessMessage(localizations.studentAdded);
    } catch (e) {
      _showErrorDialog('${localizations.errorAddingStudent}: $e');
    }
  }

  Future<void> _deleteStudent(int id) async {
    final localizations = AppLocalizations.of(context)!;

    try {
      await _studentService.deleteStudent(id);
      _loadData();
      _showSuccessMessage(localizations.studentDeleted);
    } catch (e) {
      _showErrorDialog('${localizations.errorDeletingStudent}: $e');
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
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(localizations.error),
        content: Text(message),
        actions: [
          FilledButton(
            child: Text(localizations.ok),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    final localizations = AppLocalizations.of(context)!;

    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: Text(localizations.success),
        content: Text(message),
        severity: InfoBarSeverity.success,
        onClose: close,
      ),
    );
  }

  void _showAddStudentDialog() {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(localizations.addNewStudent),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${localizations.school} *'),
                const SizedBox(height: 8),
                ComboBox<School>(
                  placeholder: Text(localizations.chooseSchool),
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
                Text('${localizations.studentId} *'),
                const SizedBox(height: 8),
                TextBox(
                  controller: _studentIdController,
                  placeholder: localizations.enterStudentId,
                ),
                const SizedBox(height: 16),
                Text('${localizations.studentName} *'),
                const SizedBox(height: 8),
                TextBox(
                  controller: _nameController,
                  placeholder: localizations.enterStudentName,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(localizations.grade),
                          const SizedBox(height: 8),
                          TextBox(
                            controller: _gradeController,
                            placeholder: localizations.grade,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(localizations.classSection),
                          const SizedBox(height: 8),
                          TextBox(
                            controller: _classSectionController,
                            placeholder: localizations.classSection,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(localizations.parentName),
                const SizedBox(height: 8),
                TextBox(
                  controller: _parentNameController,
                  placeholder: localizations.enterParentName,
                ),
                const SizedBox(height: 16),
                Text(localizations.parentPhone),
                const SizedBox(height: 8),
                TextBox(
                  controller: _parentPhoneController,
                  placeholder: localizations.enterParentPhone,
                ),
                const SizedBox(height: 16),
                Text(localizations.address),
                const SizedBox(height: 8),
                TextBox(
                  controller: _addressController,
                  placeholder: localizations.enterAddress,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          Button(
            child: Text(localizations.cancel),
            onPressed: () {
              _clearForm();
              Navigator.pop(context);
            },
          ),
          FilledButton(child: Text(localizations.add), onPressed: _addStudent),
        ],
      ),
    );
  }

  String _getSchoolName(int schoolId) {
    final localizations = AppLocalizations.of(context)!;
    final school = _schools.firstWhere(
      (s) => s.id == schoolId,
      orElse: () =>
          School(name: localizations.undefined, createdAt: DateTime.now()),
    );
    return school.name;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ScaffoldPage(
        header: PageHeader(
          title: Text(localizations.studentManagement),
          commandBar: CommandBar(
            primaryItems: [
              CommandBarButton(
                icon: const Icon(FluentIcons.add),
                label: Text(localizations.addStudent),
                onPressed: _showAddStudentDialog,
              ),
              CommandBarButton(
                icon: const Icon(FluentIcons.refresh),
                label: Text(localizations.refresh),
                onPressed: _loadData,
              ),
            ],
          ),
        ),
        content: _isLoading
            ? const Center(child: ProgressRing())
            : _students.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      FluentIcons.people,
                      size: 64,
                      color: Color(0xFF0078D4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations.noStudentsRegistered,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.clickAddStudentToStart,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF605E5C),
                      ),
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
                          Text(
                            '${localizations.studentId}: ${student.studentId}',
                          ),
                          Text(
                            '${localizations.school}: ${_getSchoolName(student.schoolId)}',
                          ),
                          if (student.grade.isNotEmpty)
                            Text('${localizations.grade}: ${student.grade}'),
                          if (student.classSection.isNotEmpty)
                            Text(
                              '${localizations.classSection}: ${student.classSection}',
                            ),
                          if (student.parentName.isNotEmpty)
                            Text(
                              '${localizations.guardian}: ${student.parentName}',
                            ),
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
                                  title: Text(localizations.confirmDelete),
                                  content: Text(
                                    localizations.areYouSureDeleteStudent(
                                      student.name,
                                    ),
                                  ),
                                  actions: [
                                    Button(
                                      child: Text(localizations.cancel),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    FilledButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                              Colors.red.normal,
                                            ),
                                      ),
                                      child: Text(localizations.delete),
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
