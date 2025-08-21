import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../services/external_income_service.dart';
import '../../services/school_service.dart';
import '../../models/external_income_model.dart';
import '../../models/school_model.dart';

class EditExternalIncomeDialog extends StatefulWidget {
  final ExternalIncome income;

  const EditExternalIncomeDialog({Key? key, required this.income})
    : super(key: key);

  @override
  State<EditExternalIncomeDialog> createState() =>
      _EditExternalIncomeDialogState();
}

class _EditExternalIncomeDialogState extends State<EditExternalIncomeDialog> {
  final _formKey = GlobalKey<FormState>();

  final ExternalIncomeService _externalIncomeService = ExternalIncomeService();
  final SchoolService _schoolService = SchoolService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  int? _selectedSchoolId;
  String _selectedCategory = 'رسوم دراسية';
  DateTime _selectedDate = DateTime.now();
  List<School> _schools = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'رسوم دراسية',
    'أنشطة',
    'خدمات',
    'تبرعات',
    'مبيعات',
    'إيجارات',
    'استشارات',
    'مشاريع',
    'أخرى',
  ];

  final DateFormat _displayDateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadSchools();
  }

  void _initializeData() {
    _titleController.text = widget.income.title;
    _descriptionController.text = widget.income.description ?? '';
    _amountController.text = widget.income.amount.toString();
    _notesController.text = widget.income.notes ?? '';
    _selectedSchoolId = widget.income.schoolId;
    _selectedCategory = widget.income.category;
    _selectedDate = widget.income.incomeDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSchools() async {
    setState(() => _isLoading = true);
    try {
      final schools = await _schoolService.getAllSchools();
      setState(() {
        _schools = schools;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل المدارس: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'اختر تاريخ العملية',
      cancelText: 'إلغاء',
      confirmText: 'موافق',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateIncome() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSchoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار المدرسة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final updatedIncome = widget.income.copyWith(
        schoolId: _selectedSchoolId!,
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        category: _selectedCategory,
        incomeType: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        incomeDate: _selectedDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      await _externalIncomeService.updateExternalIncome(updatedIncome);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الوارد بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث الوارد: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تعديل الوارد الخارجي',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'تعديل بيانات الوارد: ${widget.income.title}',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Basic Information Section
                            const Text(
                              'المعلومات الأساسية',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Divider(color: Colors.blue),
                            const SizedBox(height: 16),

                            // Income Type
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'نوع الوارد *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.title),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'يرجى إدخال نوع الوارد';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Description
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'وصف الوارد',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.description),
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),

                            // Amount
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _amountController,
                                    decoration: const InputDecoration(
                                      labelText: 'المبلغ *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.attach_money),
                                      suffixText: 'د.ع',
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}'),
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'يرجى إدخال المبلغ';
                                      }
                                      final amount = double.tryParse(
                                        value.trim(),
                                      );
                                      if (amount == null || amount <= 0) {
                                        return 'يرجى إدخال مبلغ صحيح';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        final currentValue =
                                            double.tryParse(
                                              _amountController.text,
                                            ) ??
                                            0;
                                        _amountController.text =
                                            (currentValue + 1000).toString();
                                      },
                                      icon: const Icon(Icons.add),
                                      color: Colors.green,
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        final currentValue =
                                            double.tryParse(
                                              _amountController.text,
                                            ) ??
                                            0;
                                        if (currentValue >= 1000) {
                                          _amountController.text =
                                              (currentValue - 1000).toString();
                                        }
                                      },
                                      icon: const Icon(Icons.remove),
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // School and Date
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    value: _selectedSchoolId,
                                    decoration: const InputDecoration(
                                      labelText: 'المدرسة *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.school),
                                    ),
                                    items: _schools.map((school) {
                                      return DropdownMenuItem(
                                        value: school.id,
                                        child: Text(school.nameAr),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSchoolId = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return 'يرجى اختيار المدرسة';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: _selectDate,
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'تاريخ العملية *',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.calendar_today),
                                      ),
                                      child: Text(
                                        _displayDateFormatter.format(
                                          _selectedDate,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Additional Details Section
                            const Text(
                              'تفاصيل إضافية',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Divider(color: Colors.blue),
                            const SizedBox(height: 16),

                            // Category
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'الفئة',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // Notes
                            TextFormField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                labelText: 'ملاحظات إضافية',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.note),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 3,
                            ),

                            const SizedBox(height: 16),

                            // Created/Updated info
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'معلومات السجل',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'تاريخ الإنشاء: ${DateFormat('dd/MM/yyyy - HH:mm').format(widget.income.createdAt)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'آخر تحديث: ${DateFormat('dd/MM/yyyy - HH:mm').format(widget.income.updatedAt)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),

            // Action Buttons
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _updateIncome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('حفظ التعديلات'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
