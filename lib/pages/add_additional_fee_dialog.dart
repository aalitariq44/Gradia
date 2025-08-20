import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart' as flutter_widgets show TextDirection;
import '../models/student_model.dart';
import '../models/additional_fee_model.dart';
import '../services/additional_fee_service.dart';

class AddAdditionalFeeDialog extends StatefulWidget {
  final Student student;
  final VoidCallback onFeeAdded;

  const AddAdditionalFeeDialog({
    Key? key,
    required this.student,
    required this.onFeeAdded,
  }) : super(key: key);

  @override
  State<AddAdditionalFeeDialog> createState() => _AddAdditionalFeeDialogState();
}

class _AddAdditionalFeeDialogState extends State<AddAdditionalFeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final AdditionalFeeService _feeService = AdditionalFeeService();

  // متحكمات النموذج
  final TextEditingController _customTypeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedFeeType;
  bool _isPaid = false;
  DateTime _paymentDate = DateTime.now();
  bool _isLoading = false;

  // أنواع الالمحددة مسبقاً
  final List<String> _predefinedFeeTypes = [
    'التسجيل',
    'كتب',
    'زي مدرسي',
    'نشاطات',
    'مختبر',
    'مكتبة',
    'نقل',
    'إضافية أخرى',
  ];

  @override
  void dispose() {
    _customTypeController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveFee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);

      String feeType;
      if (_selectedFeeType == 'نوع مخصص') {
        feeType = _customTypeController.text.trim();
      } else {
        feeType = _selectedFeeType!;
      }

      final fee = AdditionalFee(
        studentId: widget.student.id!,
        feeType: feeType,
        amount: amount,
        paid: _isPaid,
        paymentDate: _isPaid ? _paymentDate : null,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await _feeService.insertAdditionalFee(fee);

      if (mounted) {
        Navigator.pop(context);
        widget.onFeeAdded();
        displayInfoBar(
          context,
          builder: (context, close) => InfoBar(
            title: const Text('تم الحفظ'),
            content: const Text('تم إضافة الرسم بنجاح'),
            severity: InfoBarSeverity.success,
            onClose: close,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('خطأ في حفظ الرسم: $e');
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
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('إضافة رسم إضافي'),
            IconButton(
              icon: const Icon(FluentIcons.chrome_close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // عنوان فرعي
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(FluentIcons.contact, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'إضافة رسم إضافي جديد للطالب: ${widget.student.name}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // نوع الرسم
                InfoLabel(
                  label: 'نوع الرسم *',
                  child: ComboBox<String>(
                    placeholder: const Text('اختر نوع الرسم'),
                    value: _selectedFeeType,
                    items: [
                      ..._predefinedFeeTypes.map(
                        (type) => ComboBoxItem<String>(
                          value: type,
                          child: Text(type),
                        ),
                      ),
                      const ComboBoxItem<String>(
                        value: 'نوع مخصص',
                        child: Text('نوع مخصص'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFeeType = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // النوع المخصص (يظهر فقط عند اختيار نوع مخصص)
                if (_selectedFeeType == 'نوع مخصص') ...[
                  InfoLabel(
                    label: 'النوع المخصص *',
                    child: TextFormBox(
                      controller: _customTypeController,
                      placeholder: 'أدخل نوع الرسم المخصص',
                      validator: (value) {
                        if (_selectedFeeType == 'نوع مخصص' &&
                            (value == null || value.trim().isEmpty)) {
                          return 'النوع المخصص مطلوب';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // مبلغ الرسم
                InfoLabel(
                  label: 'مبلغ الرسم *',
                  child: TextFormBox(
                    controller: _amountController,
                    placeholder: 'أدخل مبلغ الرسم',
                    suffix: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: const Text('د.ع'),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'مبلغ الرسم مطلوب';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'يرجى إدخال مبلغ صحيح';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // حالة الدفع
                Checkbox(
                  checked: _isPaid,
                  onChanged: (value) {
                    setState(() {
                      _isPaid = value ?? false;
                    });
                  },
                  content: const Text('تم الدفع'),
                ),
                const SizedBox(height: 16),

                // تاريخ الدفع (يظهر فقط عند اختيار تم الدفع)
                if (_isPaid) ...[
                  InfoLabel(
                    label: 'تاريخ الدفع *',
                    child: DatePicker(
                      selected: _paymentDate,
                      onChanged: (date) {
                        setState(() => _paymentDate = date);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // الملاحظات
                InfoLabel(
                  label: 'الملاحظات',
                  child: TextFormBox(
                    controller: _notesController,
                    placeholder: 'أدخل أي ملاحظات إضافية (اختياري)',
                    maxLines: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Button(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            onPressed: _isLoading || _selectedFeeType == null ? null : _saveFee,
            child: _isLoading
                ? const SizedBox(width: 16, height: 16, child: ProgressRing())
                : const Text('حفظ الرسم'),
          ),
        ],
      ),
    );
  }
}
