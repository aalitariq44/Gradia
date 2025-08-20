import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart' as flutter_widgets show TextDirection;
import 'package:intl/intl.dart';
import '../../core/services/expense_service.dart';
import '../../core/services/school_service.dart';
import '../../core/database/models/school_model.dart';
import '../../models/expense_model.dart';

class AddExpenseDialog extends StatefulWidget {
  final ExpenseModel? expense; // For editing existing expense

  const AddExpenseDialog({Key? key, this.expense}) : super(key: key);

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Form values
  int? _selectedSchoolId;
  String? _selectedExpenseType;
  DateTime _selectedDate = DateTime.now();

  // Data
  List<SchoolModel> _schools = [];
  bool _isLoading = false;
  bool _isSaving = false;

  final DateFormat _displayDateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadSchools();
    _initializeForm();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (widget.expense != null) {
      _descriptionController.text = widget.expense!.description ?? '';
      _amountController.text = widget.expense!.amount.toString();
      _notesController.text = widget.expense!.notes ?? '';
      _selectedSchoolId = widget.expense!.schoolId;
      _selectedExpenseType = widget.expense!.expenseType;
      _selectedDate = widget.expense!.expenseDate;
    }
  }

  Future<void> _loadSchools() async {
    setState(() => _isLoading = true);
    try {
      final schools = await SchoolService.getAllSchools();
      setState(() {
        _schools = schools;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('خطأ في تحميل المدارس: $e');
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSchoolId == null) {
      _showErrorMessage('يرجى اختيار المدرسة');
      return;
    }
    if (_selectedExpenseType == null) {
      _showErrorMessage('يرجى اختيار نوع المصروف');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final expense = ExpenseModel(
        id: widget.expense?.id,
        schoolId: _selectedSchoolId!,
        expenseType: _selectedExpenseType!,
        amount: double.parse(_amountController.text),
        expenseDate: _selectedDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.expense?.createdAt,
        updatedAt: widget.expense?.updatedAt,
      );

      if (widget.expense == null) {
        // Create new expense
        await ExpenseService.createExpense(expense);
      } else {
        // Update existing expense
        await ExpenseService.updateExpense(expense);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      _showErrorMessage('حدث خطأ أثناء حفظ المصروف: $e');
    }
  }

  void _showErrorMessage(String message) {
    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: const Text('خطأ'),
        content: Text(message),
        severity: InfoBarSeverity.error,
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close,
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) => DatePicker(
        selected: _selectedDate,
        onChanged: (date) => Navigator.of(context).pop(date),
      ),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  Widget _buildBasicInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'المعلومات الأساسية',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Description field
          InfoLabel(
            label: 'وصف المصروف *',
            child: TextBox(
              controller: _descriptionController,
              placeholder: 'أدخل وصف المصروف...',
              maxLines: 2,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              // Amount field
              Expanded(
                flex: 2,
                child: InfoLabel(
                  label: 'المبلغ *',
                  child: NumberBox<double>(
                    value: _amountController.text.isEmpty
                        ? null
                        : double.tryParse(_amountController.text),
                    onChanged: (value) {
                      _amountController.text = value?.toString() ?? '';
                    },
                    placeholder: 'المبلغ بالدينار العراقي',
                    mode: SpinButtonPlacementMode.inline,
                    smallChange: 1000,
                    largeChange: 10000,
                    min: 0,
                    max: 999999999,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // School selection
              Expanded(
                flex: 2,
                child: InfoLabel(
                  label: 'المدرسة *',
                  child: _isLoading
                      ? const ProgressRing()
                      : ComboBox<int>(
                          placeholder: const Text('اختر المدرسة'),
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
                          },
                        ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              // Date selection
              Expanded(
                flex: 2,
                child: InfoLabel(
                  label: 'التاريخ *',
                  child: Button(
                    onPressed: _selectDate,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_displayDateFormatter.format(_selectedDate)),
                        const Icon(FluentIcons.calendar),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Expense type selection
              Expanded(
                flex: 2,
                child: InfoLabel(
                  label: 'نوع المصروف *',
                  child: ComboBox<String>(
                    placeholder: const Text('اختر نوع المصروف'),
                    value: _selectedExpenseType,
                    items: ExpenseTypes.allTypes
                        .map(
                          (type) => ComboBoxItem<String>(
                            value: type,
                            child: Text(type),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedExpenseType = value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تفاصيل إضافية',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          InfoLabel(
            label: 'ملاحظات',
            child: TextBox(
              controller: _notesController,
              placeholder: 'أضف أي ملاحظات إضافية حول المصروف...',
              maxLines: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Button(
            onPressed: _isSaving
                ? null
                : () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _isSaving ? null : _saveExpense,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
            ),
            child: _isSaving
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: ProgressRing(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('جاري الحفظ...'),
                    ],
                  )
                : Text(
                    widget.expense == null ? 'حفظ المصروف' : 'تحديث المصروف',
                  ),
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
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              const Icon(FluentIcons.money, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                widget.expense == null ? 'إضافة مصروف جديد' : 'تعديل المصروف',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1)),
                  child: Text(
                    widget.expense == null
                        ? 'يرجى ملء المعلومات المطلوبة لإضافة مصروف جديد. الحقول المحددة بـ * إجبارية.'
                        : 'يرجى تعديل المعلومات المطلوبة. الحقول المحددة بـ * إجبارية.',
                    style: TextStyle(color: Colors.red.darker, fontSize: 14),
                  ),
                ),
                _buildBasicInfoSection(),
                const Divider(),
                _buildAdditionalDetailsSection(),
              ],
            ),
          ),
        ),
        actions: [_buildActionButtons()],
      ),
    );
  }
}
