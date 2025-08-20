import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/employee_model.dart';
import '../models/school_model.dart';
import '../services/employee_service.dart';

class AddEmployeeDialog extends StatefulWidget {
  final List<School> schools;
  final VoidCallback onEmployeeAdded;

  const AddEmployeeDialog({
    super.key,
    required this.schools,
    required this.onEmployeeAdded,
  });

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final EmployeeService _employeeService = EmployeeService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _jobTypeController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  int? _selectedSchoolId;
  String? _selectedJobType;
  bool _isLoading = false;

  // قائمة المهن الشائعة
  final List<String> _commonJobTypes = [
    'محاسب',
    'كاتب',
    'عامل نظافة',
    'حارس أمن',
    'سائق',
    'مشرف',
    'مساعد إداري',
    'فني صيانة',
    'عامل مختبر',
    'أمين مكتبة',
    'مرشد طلابي',
    'ممرض',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _jobTypeController.dispose();
    _salaryController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSchoolId == null) {
      _showErrorSnackBar('يرجى اختيار المدرسة');
      return;
    }

    final jobType = _selectedJobType ?? _jobTypeController.text.trim();
    if (jobType.isEmpty) {
      _showErrorSnackBar('يرجى اختيار أو إدخال المهنة');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final employee = Employee(
        name: _nameController.text.trim(),
        schoolId: _selectedSchoolId!,
        jobType: jobType,
        monthlySalary: double.parse(_salaryController.text),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await _employeeService.insertEmployee(employee);
      widget.onEmployeeAdded();
      _showSuccessSnackBar('تم إضافة الموظف بنجاح');
    } catch (e) {
      _showErrorSnackBar('خطأ في إضافة الموظف: ${e.toString()}');
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
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
                    'إضافة موظف جديد',
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
                          hintText: 'أدخل اسم الموظف',
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

                // المهنة
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text(
                        'المهنة *',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          // قائمة المهن الشائعة
                          DropdownButtonFormField<String>(
                            value: _selectedJobType,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'اختر من المهن الشائعة',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text(
                                  '-- اختر من القائمة أو أدخل مهنة جديدة --',
                                ),
                              ),
                              ..._commonJobTypes.map(
                                (jobType) => DropdownMenuItem<String>(
                                  value: jobType,
                                  child: Text(jobType),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedJobType = value;
                                if (value != null) {
                                  _jobTypeController.clear();
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text('أو', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          // حقل إدخال مهنة جديدة
                          TextFormField(
                            controller: _jobTypeController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'أدخل مهنة جديدة',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                setState(() => _selectedJobType = null);
                              }
                            },
                          ),
                        ],
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
                      onPressed: _isLoading ? null : _addEmployee,
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
                          : const Text('إضافة الموظف'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
