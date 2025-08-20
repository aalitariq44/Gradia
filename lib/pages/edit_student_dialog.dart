import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import '../models/student_model.dart';
import '../models/school_model.dart';
import '../services/student_service.dart';

class EditStudentDialog extends StatefulWidget {
  final Student student;
  final List<School> schools;
  final VoidCallback onStudentUpdated;

  const EditStudentDialog({
    super.key,
    required this.student,
    required this.schools,
    required this.onStudentUpdated,
  });

  @override
  State<EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<EditStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final StudentService _studentService = StudentService();

  late final TextEditingController _nameController;
  late final TextEditingController _nationalIdController;
  late final TextEditingController _phoneController;
  late final TextEditingController _totalFeeController;
  late final TextEditingController _academicYearController;

  School? _selectedSchool;
  String? _selectedGender;
  String? _selectedGrade;
  String? _selectedSection;
  String? _selectedStatus;
  DateTime? _selectedStartDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _nationalIdController = TextEditingController(
      text: widget.student.nationalIdNumber ?? '',
    );
    _phoneController = TextEditingController(text: widget.student.phone ?? '');
    _totalFeeController = TextEditingController(
      text: widget.student.totalFee.toString(),
    );
    _academicYearController = TextEditingController(
      text: widget.student.academicYear ?? '',
    );

    _selectedSchool = widget.schools.firstWhere(
      (s) => s.id == widget.student.schoolId,
    );
    _selectedGender = widget.student.gender;
    _selectedGrade = widget.student.grade;
    _selectedSection = widget.student.section;
    _selectedStatus = widget.student.status;
    _selectedStartDate = widget.student.startDate;
  }

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

  Future<void> _updateStudent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSchool == null) {
      _showErrorDialog('يرجى اختيار المدرسة');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedStudent = widget.student.copyWith(
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
        updatedAt: DateTime.now(),
      );

      await _studentService.updateStudent(updatedStudent);
      widget.onStudentUpdated();
      Navigator.of(context).pop();
      _showSuccessDialog('تم تحديث الطالب بنجاح');
    } catch (e) {
      _showErrorDialog('خطأ في تحديث الطالب: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('نجاح'),
        content: Text(message),
        actions: [
          Button(
            child: const Text('حسنا'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
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
          Button(
            child: const Text('حسنا'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('تعديل بيانات الطالب'),
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
          onPressed: _isLoading ? null : _updateStudent,
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: ProgressRing())
              : const Text('حفظ التغييرات'),
        ),
      ],
    );
  }
}
