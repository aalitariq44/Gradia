import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/teacher_model.dart';
import '../models/school_model.dart';
import '../services/teacher_service.dart';

class AddTeacherDialog extends StatefulWidget {
  final List<School> schools;
  final VoidCallback onTeacherAdded;

  const AddTeacherDialog({
    super.key,
    required this.schools,
    required this.onTeacherAdded,
  });

  @override
  State<AddTeacherDialog> createState() => _AddTeacherDialogState();
}

class _AddTeacherDialogState extends State<AddTeacherDialog> {
  final _formKey = GlobalKey<FormState>();
  final TeacherService _teacherService = TeacherService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _classHoursController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  int? _selectedSchoolId;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _classHoursController.dispose();
    _salaryController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addTeacher() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSchoolId == null) {
      _showErrorSnackBar('يرجى اختيار المدرسة');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final teacher = Teacher(
        name: _nameController.text.trim(),
        schoolId: _selectedSchoolId!,
        classHours: int.parse(_classHoursController.text),
        monthlySalary: double.parse(_salaryController.text),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await _teacherService.insertTeacher(teacher);
      widget.onTeacherAdded();
      _showSuccessSnackBar('تم إضافة المعلم بنجاح');
    } catch (e) {
      _showErrorSnackBar('خطأ في إضافة المعلم: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: const Text(
                  'إضافة معلم جديد',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              // حقل الاسم
              Row(
                children: [
                  const SizedBox(
                    width: 100,
                    child: Text(
                      'الاسم *',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'أدخل اسم المعلم',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الاسم مطلوب';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // قائمة المدارس
              Row(
                children: [
                  const SizedBox(
                    width: 100,
                    child: Text(
                      'المدرسة *',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedSchoolId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'اختر المدرسة',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: widget.schools
                          .map(
                            (school) => DropdownMenuItem<int>(
                              value: school.id,
                              child: Text(school.nameAr),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedSchoolId = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'المدرسة مطلوبة';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // عدد الحصص
              Row(
                children: [
                  const SizedBox(
                    width: 100,
                    child: Text(
                      'عدد الحصص *',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _classHoursController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '0',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        suffixIcon: Icon(Icons.schedule),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'عدد الحصص مطلوب';
                        }
                        final hours = int.tryParse(value);
                        if (hours == null || hours < 0) {
                          return 'يرجى إدخال رقم صحيح';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // الراتب الشهري
              Row(
                children: [
                  const SizedBox(
                    width: 100,
                    child: Text(
                      'الراتب الشهري *',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _salaryController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '0.00',
                        suffixText: 'د.ع',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        suffixIcon: Icon(Icons.monetization_on),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الراتب مطلوب';
                        }
                        final salary = double.tryParse(value);
                        if (salary == null || salary < 0) {
                          return 'يرجى إدخال مبلغ صحيح';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // رقم الهاتف
              Row(
                children: [
                  const SizedBox(
                    width: 100,
                    child: Text(
                      'رقم الهاتف',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'أدخل رقم الهاتف',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        suffixIcon: Icon(Icons.phone),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // الملاحظات
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 100,
                    child: Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'ملاحظات',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'أدخل أي ملاحظات إضافية',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // أزرار العمل
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _addTeacher,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('إضافة المعلم'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
