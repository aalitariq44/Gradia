import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart' as flutter_widgets show TextDirection;
import 'package:intl/intl.dart';
import '../models/student_model.dart';
import '../models/additional_fee_model.dart';
import '../services/additional_fee_service.dart';
import 'add_additional_fee_dialog.dart';
import 'print_additional_fees_dialog.dart';

class AdditionalFeesDialog extends StatefulWidget {
  final Student student;
  final VoidCallback? onFeesUpdated;

  const AdditionalFeesDialog({
    Key? key,
    required this.student,
    this.onFeesUpdated,
  }) : super(key: key);

  @override
  State<AdditionalFeesDialog> createState() => _AdditionalFeesDialogState();
}

class _AdditionalFeesDialogState extends State<AdditionalFeesDialog> {
  final AdditionalFeeService _feeService = AdditionalFeeService();

  List<AdditionalFee> _fees = [];
  bool _isLoading = false;

  // الإحصائيات
  int _feesCount = 0;
  double _totalAmount = 0.0;
  double _paidAmount = 0.0;
  double _unpaidAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      _fees = await _feeService.getStudentAdditionalFees(widget.student.id!);
      _feesCount = await _feeService.getFeesCount(widget.student.id!);
      _totalAmount = await _feeService.getTotalFeesAmount(widget.student.id!);
      _paidAmount = await _feeService.getTotalPaidAmount(widget.student.id!);
      _unpaidAmount = await _feeService.getTotalUnpaidAmount(
        widget.student.id!,
      );

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

  void _showAddFeeDialog() {
    showDialog(
      context: context,
      builder: (context) => AddAdditionalFeeDialog(
        student: widget.student,
        onFeeAdded: () {
          _loadData();
          widget.onFeesUpdated?.call();
        },
      ),
    );
  }

  void _showPrintDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          PrintAdditionalFeesDialog(student: widget.student, fees: _fees),
    );
  }

  Future<void> _deleteFee(AdditionalFee fee) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
          'هل تريد حذف رسم "${fee.feeType}" بمبلغ ${fee.amount.toStringAsFixed(0)} د.ع؟',
        ),
        actions: [
          Button(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context, false),
          ),
          FilledButton(
            child: const Text('حذف'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _feeService.deleteAdditionalFee(fee.id!);
        _loadData();
        widget.onFeesUpdated?.call();

        if (mounted) {
          displayInfoBar(
            context,
            builder: (context, close) => InfoBar(
              title: const Text('تم الحذف'),
              content: const Text('تم حذف الرسم بنجاح'),
              severity: InfoBarSeverity.success,
              onClose: close,
            ),
          );
        }
      } catch (e) {
        _showErrorDialog('خطأ في حذف الرسم: $e');
      }
    }
  }

  Future<void> _togglePaymentStatus(AdditionalFee fee) async {
    try {
      if (fee.paid) {
        await _feeService.unpayFee(fee.id!);
      } else {
        await _feeService.payFee(fee.id!, DateTime.now());
      }

      _loadData();
      widget.onFeesUpdated?.call();

      if (mounted) {
        displayInfoBar(
          context,
          builder: (context, close) => InfoBar(
            title: const Text('تم التحديث'),
            content: Text(fee.paid ? 'تم إلغاء تسديد الرسم' : 'تم تسديد الرسم'),
            severity: InfoBarSeverity.success,
            onClose: close,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('خطأ في تحديث حالة الدفع: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: flutter_widgets.TextDirection.rtl,
      child: ContentDialog(
        constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 800),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'الرسوم الإضافية',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(FluentIcons.chrome_close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: _isLoading
            ? const Center(child: ProgressRing())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // شريط معلومات الطالب
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
                            'الطالب: ${widget.student.name} - الصف: ${widget.student.grade} ${widget.student.section}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // قسم الملخص المالي
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'عدد الرسوم',
                            _feesCount.toString(),
                            Colors.blue,
                            FluentIcons.number_field,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'المجموع',
                            '${_totalAmount.toStringAsFixed(0)} د.ع',
                            Colors.purple,
                            FluentIcons.calculator_addition,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'المدفوع',
                            '${_paidAmount.toStringAsFixed(0)} د.ع',
                            Colors.green,
                            FluentIcons.money,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'غير المدفوع',
                            '${_unpaidAmount.toStringAsFixed(0)} د.ع',
                            Colors.orange,
                            FluentIcons.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // قسم إدارة الرسوم
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'قائمة الرسوم الإضافية',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FilledButton(
                          onPressed: _showAddFeeDialog,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(FluentIcons.add, size: 16),
                              SizedBox(width: 4),
                              Text('إضافة رسم جديد'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // جدول الرسوم
                    _fees.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  FluentIcons.money,
                                  size: 64,
                                  color: Colors.grey[160],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد رسوم إضافية',
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
                                    color: FluentTheme.of(context).cardColor,
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
                                          'النوع',
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
                                          'تاريخ الإضافة',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'تاريخ الدفع',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          'الحالة',
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
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'إجراءات',
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
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _fees.length,
                                  itemBuilder: (context, index) {
                                    final fee = _fees[index];
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
                                            child: Text(fee.feeType),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              '${fee.amount.toStringAsFixed(0)} د.ع',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              DateFormat(
                                                'yyyy/MM/dd',
                                              ).format(fee.addedAt),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              fee.paymentDate != null
                                                  ? DateFormat(
                                                      'yyyy/MM/dd',
                                                    ).format(fee.paymentDate!)
                                                  : '-',
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: fee.paid
                                                    ? Colors.green.withOpacity(
                                                        0.2,
                                                      )
                                                    : Colors.orange.withOpacity(
                                                        0.2,
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                fee.paid
                                                    ? 'مدفوع'
                                                    : 'غير مدفوع',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: fee.paid
                                                      ? Colors.green
                                                      : Colors.orange,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              fee.notes ?? '-',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (!fee.paid)
                                                  IconButton(
                                                    style: ButtonStyle(
                                                      padding: ButtonState.all(
                                                        const EdgeInsets.all(
                                                          12,
                                                        ),
                                                      ),
                                                    ),
                                                    icon: Icon(
                                                      FluentIcons.money,
                                                      color: Colors.green,
                                                      size: 32,
                                                    ),
                                                    onPressed: () =>
                                                        _togglePaymentStatus(
                                                          fee,
                                                        ),
                                                  ),
                                                IconButton(
                                                  style: ButtonStyle(
                                                    padding: ButtonState.all(
                                                      const EdgeInsets.all(12),
                                                    ),
                                                  ),
                                                  icon: Icon(
                                                    FluentIcons.delete,
                                                    color: Colors.red,
                                                    size: 32,
                                                  ),
                                                  onPressed: () =>
                                                      _deleteFee(fee),
                                                ),
                                              ],
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
        actions: [
          Button(
            child: const Text('إغلاق'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            onPressed: _fees.isNotEmpty ? _showPrintDialog : null,
            child: const Text('طباعة إيصال الرسوم'),
          ),
        ],
      ),
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
