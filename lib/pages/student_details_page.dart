import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter/widgets.dart' as flutter_widgets show TextDirection;
import 'package:intl/intl.dart';
import '../models/student_model.dart';
import '../models/school_model.dart';
import '../models/installment_model.dart';
import '../services/school_service.dart';
import '../services/installment_service.dart';
import 'additional_fees_dialog.dart';

class StudentDetailsPage extends StatefulWidget {
  final Student student;

  const StudentDetailsPage({Key? key, required this.student}) : super(key: key);

  @override
  State<StudentDetailsPage> createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends State<StudentDetailsPage> {
  final SchoolService _schoolService = SchoolService();
  final InstallmentService _installmentService = InstallmentService();

  late Student _student;
  School? _school;
  List<Installment> _installments = [];
  bool _isLoading = false;

  // البيانات المالية
  double _totalPaid = 0.0;
  double _remainingAmount = 0.0;
  int _installmentCount = 0;
  double _currentInstallment = 0.0;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // تحميل بيانات المدرسة
      final schools = await _schoolService.getAllSchools();
      _school = schools.firstWhere(
        (s) => s.id == _student.schoolId,
        orElse: () => School(
          nameAr: 'غير محدد',
          schoolTypes: ['ابتدائي'],
          createdAt: DateTime.now(),
        ),
      );

      // تحميل الأقساط
      _installments = await _installmentService.getStudentInstallments(
        _student.id!,
      );
      // ترتيب الأقساط حسب التاريخ والوقت (الأقدم أولاً)
      _installments.sort((a, b) {
        final dateComp = a.paymentDate.compareTo(b.paymentDate);
        if (dateComp != 0) return dateComp;
        final partsA = a.paymentTime.split(':');
        final partsB = b.paymentTime.split(':');
        final hourA = int.tryParse(partsA[0]) ?? 0;
        final minA = int.tryParse(partsA[1]) ?? 0;
        final hourB = int.tryParse(partsB[0]) ?? 0;
        final minB = int.tryParse(partsB[1]) ?? 0;
        if (hourA != hourB) return hourA - hourB;
        return minA - minB;
      });

      // حساب البيانات المالية
      _totalPaid = await _installmentService.getTotalPaidAmount(_student.id!);
      _installmentCount = await _installmentService.getInstallmentCount(
        _student.id!,
      );
      _remainingAmount = _student.totalFee - _totalPaid;

      // حساب القسط الحالي (افتراضي)
      if (_remainingAmount > 0) {
        _currentInstallment =
            _remainingAmount / 4; // تقسيم على 4 أقساط افتراضياً
      }

      setState(() {});
    } catch (e) {
      _showErrorDialog('خطأ في تحميل البيانات: $e');
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

  void _showAdditionalFeesDialog() {
    showDialog(
      context: context,
      builder: (context) => AdditionalFeesDialog(
        student: _student,
        onFeesUpdated: () {
          // يمكن إضافة تحديث إضافي هنا إذا لزم الأمر
        },
      ),
    );
  }

  void _showAddInstallmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AddInstallmentDialog(
        student: _student,
        remainingAmount: _remainingAmount,
        onInstallmentAdded: () {
          _loadData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: flutter_widgets.TextDirection.rtl,
      child: ScaffoldPage(
        header: PageHeader(
          title: Row(
            children: [
              // زر الرجوع
              IconButton(
                icon: const Icon(FluentIcons.back),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 16),

              // عنوان الصفحة
              Expanded(
                child: Text(
                  'تفاصيل الطالب: ${_student.name}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // الأزرار الوظيفية
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Button(
                    onPressed: _showAdditionalFeesDialog,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(FluentIcons.money, size: 16),
                        SizedBox(width: 4),
                        Text('الرسوم الإضافية'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Button(
                    onPressed: _loadData,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(FluentIcons.refresh, size: 16),
                        SizedBox(width: 4),
                        Text('تحديث'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Button(
                    onPressed: () =>
                        _showErrorDialog('وظيفة الطباعة لم تنفذ بعد'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(FluentIcons.print, size: 16),
                        SizedBox(width: 4),
                        Text('طباعة'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        content: _isLoading
            ? const Center(child: ProgressRing())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معلومات الطالب
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: FluentTheme.of(context).micaBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[100]),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'معلومات الطالب',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // الصف الأول من المعلومات
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem('الاسم', _student.name),
                              ),
                              Expanded(
                                child: _buildInfoItem(
                                  'المدرسة',
                                  _school?.nameAr ?? 'غير محدد',
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem('الجنس', _student.gender),
                              ),
                              const Expanded(child: SizedBox()), // مساحة فارغة
                            ],
                          ),
                          const SizedBox(height: 12),

                          // الصف الثاني من المعلومات
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem('الصف', _student.grade),
                              ),
                              Expanded(
                                child: _buildInfoItem(
                                  'الشعبة',
                                  _student.section,
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem(
                                  'تاريخ المباشرة',
                                  DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(_student.startDate),
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem(
                                  'رقم الهاتف',
                                  _student.phone ?? 'غير محدد',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // الملخص المالي
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'القسط الكلي',
                            '${_currentInstallment.toStringAsFixed(0)} د.ع',
                            Colors.magenta,
                            FluentIcons.calculator_addition,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            'المدفوع',
                            '${_totalPaid.toStringAsFixed(0)} د.ع',
                            Colors.green,
                            FluentIcons.money,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            'المتبقي',
                            '${_remainingAmount.toStringAsFixed(0)} د.ع',
                            _remainingAmount > 0 ? Colors.orange : Colors.green,
                            FluentIcons.warning,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            'عدد الدفعات',
                            _installmentCount.toString(),
                            Colors.blue,
                            FluentIcons.number_field,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // الأقساط المدفوعة
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: FluentTheme.of(context).micaBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[100]),
                      ),
                      child: Column(
                        children: [
                          // رأس القسم
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'الأقساط المدفوعة',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              FilledButton(
                                onPressed: _showAddInstallmentDialog,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(FluentIcons.add, size: 16),
                                    SizedBox(width: 4),
                                    Text('إضافة قسط جديد'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // جدول الأقساط
                          _installments.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    children: [
                                      Icon(
                                        FluentIcons.money,
                                        size: 48,
                                        color: Colors.grey[160],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'لا توجد أقساط مدفوعة',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[160],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[100]),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      // رأس الجدول
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: FluentTheme.of(
                                            context,
                                          ).cardColor,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: Row(
                                          children: const [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                'التسلسل',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                'رقم الوصل',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                'المبلغ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                'التاريخ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                'وقت الدفع',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                'الملاحظات',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // صفوف البيانات
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: _installments.length,
                                        itemBuilder: (context, index) {
                                          final installment =
                                              _installments[index];
                                          return Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey[100],
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Text('${index + 1}'),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    installment.id != null
                                                        ? installment.id
                                                              .toString()
                                                        : '-',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    '${installment.amount.toStringAsFixed(0)} د.ع',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    DateFormat(
                                                      'yyyy/MM/dd',
                                                    ).format(
                                                      installment.paymentDate,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    installment.paymentTime,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    installment.notes ?? '-',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
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
              ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[160],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// نافذة إضافة قسط جديد
class AddInstallmentDialog extends StatefulWidget {
  final Student student;
  final double remainingAmount;
  final VoidCallback onInstallmentAdded;

  const AddInstallmentDialog({
    Key? key,
    required this.student,
    required this.remainingAmount,
    required this.onInstallmentAdded,
  }) : super(key: key);

  @override
  State<AddInstallmentDialog> createState() => _AddInstallmentDialogState();
}

class _AddInstallmentDialogState extends State<AddInstallmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final InstallmentService _installmentService = InstallmentService();

  // متحكمات النموذج
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // تعيين الوقت الحالي افتراضياً
    final now = TimeOfDay.now();
    _timeController.text =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _saveInstallment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      final timeString = _timeController.text.trim();

      final installment = Installment(
        studentId: widget.student.id!,
        amount: amount,
        paymentDate: _selectedDate,
        paymentTime: timeString,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _installmentService.insertInstallment(installment);

      if (mounted) {
        Navigator.pop(context);
        widget.onInstallmentAdded();
        displayInfoBar(
          context,
          builder: (context, close) => InfoBar(
            title: const Text('تم الحفظ'),
            content: const Text('تم إضافة القسط بنجاح'),
            severity: InfoBarSeverity.success,
            onClose: close,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('خطأ في حفظ القسط: $e');
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('إضافة قسط جديد'),
            IconButton(
              icon: const Icon(FluentIcons.chrome_close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          height: 400,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معلومات القسط المرجعية
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(FluentIcons.info, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'المبلغ المتبقي: ${widget.remainingAmount.toStringAsFixed(0)} د.ع',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // مبلغ القسط
                InfoLabel(
                  label: 'مبلغ القسط *',
                  child: TextFormBox(
                    controller: _amountController,
                    placeholder: 'أدخل مبلغ القسط',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'مبلغ القسط مطلوب';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'يرجى إدخال مبلغ صحيح';
                      }
                      if (amount > widget.remainingAmount) {
                        return 'المبلغ أكبر من المتبقي';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // تاريخ الدفعة
                InfoLabel(
                  label: 'تاريخ الدفعة *',
                  child: DatePicker(
                    selected: _selectedDate,
                    onChanged: (date) {
                      setState(() => _selectedDate = date);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // وقت الدفع
                InfoLabel(
                  label: 'وقت الدفع *',
                  child: TextFormBox(
                    controller: _timeController,
                    placeholder: 'مثال: 14:30',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'وقت الدفع مطلوب';
                      }
                      // التحقق من صيغة الوقت
                      final timeRegex = RegExp(
                        r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$',
                      );
                      if (!timeRegex.hasMatch(value.trim())) {
                        return 'صيغة الوقت غير صحيحة (مثال: 14:30)';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // الملاحظات
                InfoLabel(
                  label: 'الملاحظات',
                  child: TextFormBox(
                    controller: _notesController,
                    placeholder: 'أدخل أي ملاحظات إضافية (اختياري)',
                    maxLines: 3,
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
            onPressed: _isLoading ? null : _saveInstallment,
            child: _isLoading
                ? const SizedBox(width: 16, height: 16, child: ProgressRing())
                : const Text('حفظ القسط'),
          ),
        ],
      ),
    );
  }
}
