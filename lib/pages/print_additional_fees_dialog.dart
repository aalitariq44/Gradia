import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart' as flutter_widgets show TextDirection;
import 'package:intl/intl.dart';
import '../models/student_model.dart';
import '../models/additional_fee_model.dart';

class PrintAdditionalFeesDialog extends StatefulWidget {
  final Student student;
  final List<AdditionalFee> fees;

  const PrintAdditionalFeesDialog({
    Key? key,
    required this.student,
    required this.fees,
  }) : super(key: key);

  @override
  State<PrintAdditionalFeesDialog> createState() => _PrintAdditionalFeesDialogState();
}

class _PrintAdditionalFeesDialogState extends State<PrintAdditionalFeesDialog> {
  String _selectedFilter = 'all'; // all, paid, unpaid
  List<AdditionalFee> _selectedFees = [];
  List<AdditionalFee> _filteredFees = [];
  
  double _selectedTotalAmount = 0.0;
  int _selectedCount = 0;

  @override
  void initState() {
    super.initState();
    _filteredFees = widget.fees;
    _selectAllFees();
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      
      switch (filter) {
        case 'paid':
          _filteredFees = widget.fees.where((fee) => fee.paid).toList();
          break;
        case 'unpaid':
          _filteredFees = widget.fees.where((fee) => !fee.paid).toList();
          break;
        default:
          _filteredFees = widget.fees;
      }
      
      // إعادة تعيين الاختيارات
      _selectedFees.clear();
      _selectAllFees();
    });
  }

  void _selectAllFees() {
    setState(() {
      _selectedFees = List.from(_filteredFees);
      _updateSelectedStats();
    });
  }

  void _toggleFeeSelection(AdditionalFee fee) {
    setState(() {
      if (_selectedFees.contains(fee)) {
        _selectedFees.remove(fee);
      } else {
        _selectedFees.add(fee);
      }
      _updateSelectedStats();
    });
  }

  void _updateSelectedStats() {
    _selectedCount = _selectedFees.length;
    _selectedTotalAmount = _selectedFees.fold(0.0, (sum, fee) => sum + fee.amount);
  }

  void _print() {
    if (_selectedFees.isEmpty) {
      displayInfoBar(
        context,
        builder: (context, close) => InfoBar(
          title: const Text('تنبيه'),
          content: const Text('يرجى اختيار رسم واحد على الأقل للطباعة'),
          severity: InfoBarSeverity.warning,
          onClose: close,
        ),
      );
      return;
    }

    // هنا يمكن إضافة منطق الطباعة الفعلي
    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: const Text('طباعة'),
        content: Text('سيتم طباعة ${_selectedFees.length} رسوم'),
        severity: InfoBarSeverity.info,
        onClose: close,
      ),
    );
  }

  void _preview() {
    if (_selectedFees.isEmpty) {
      displayInfoBar(
        context,
        builder: (context, close) => InfoBar(
          title: const Text('تنبيه'),
          content: const Text('يرجى اختيار رسم واحد على الأقل للمعاينة'),
          severity: InfoBarSeverity.warning,
          onClose: close,
        ),
      );
      return;
    }

    // هنا يمكن إضافة منطق المعاينة
    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: const Text('معاينة'),
        content: Text('سيتم معاينة ${_selectedFees.length} رسوم'),
        severity: InfoBarSeverity.info,
        onClose: close,
      ),
    );
  }

  void _customizeTemplates() {
    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: const Text('تخصيص القوالب'),
        content: const Text('وظيفة تخصيص القوالب لم تنفذ بعد'),
        severity: InfoBarSeverity.info,
        onClose: close,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: flutter_widgets.TextDirection.rtl,
      child: ContentDialog(
        constraints: const BoxConstraints(
          maxWidth: 1000,
          maxHeight: 700,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'طباعة إيصال الرسوم الإضافية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(FluentIcons.chrome_close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان الفرعي
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(FluentIcons.print, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'اختيار الرسوم الإضافية للطباعة',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // قسم تصفية الرسوم
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تصفية الرسوم:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      RadioButton(
                        checked: _selectedFilter == 'all',
                        onChanged: (value) {
                          if (value) _applyFilter('all');
                        },
                        content: const Text('جميع الرسوم'),
                      ),
                      const SizedBox(width: 20),
                      
                      RadioButton(
                        checked: _selectedFilter == 'paid',
                        onChanged: (value) {
                          if (value) _applyFilter('paid');
                        },
                        content: const Text('المدفوع فقط'),
                      ),
                      const SizedBox(width: 20),
                      
                      RadioButton(
                        checked: _selectedFilter == 'unpaid',
                        onChanged: (value) {
                          if (value) _applyFilter('unpaid');
                        },
                        content: const Text('غير المدفوع فقط'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // قسم اختيار الرسوم
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'اختيار الرسوم',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Button(
                    onPressed: _selectAllFees,
                    child: const Text('تحديد أكثر من رسوم'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // مربع معلومات المحدد
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(FluentIcons.info, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'المحدد: $_selectedCount رسوم - المبلغ الإجمالي: ${_selectedTotalAmount.toStringAsFixed(0)} د.ع',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // جدول الرسوم
              _filteredFees.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FluentIcons.money,
                              size: 64,
                              color: Colors.grey[160],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد رسوم مطابقة للفلتر المحدد',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[160],
                              ),
                            ),
                          ],
                        ),
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
                                  flex: 1,
                                  child: Text(
                                    'اختيار',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'النوع',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'المبلغ',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'الحالة',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'تاريخ الإضافة',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'تاريخ الدفع',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'الملاحظات',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // صفوف البيانات
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredFees.length,
                            itemBuilder: (context, index) {
                              final fee = _filteredFees[index];
                              final isSelected = _selectedFees.contains(fee);
                              
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? Colors.blue.withOpacity(0.1) 
                                      : null,
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey[100]),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Checkbox(
                                        checked: isSelected,
                                        onChanged: (value) => _toggleFeeSelection(fee),
                                      ),
                                    ),
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
                                      flex: 1,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: fee.paid
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          fee.paid ? 'مدفوع' : 'غير مدفوع',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: fee.paid ? Colors.green : Colors.orange,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        DateFormat('yyyy/MM/dd').format(fee.addedAt),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        fee.paymentDate != null
                                            ? DateFormat('yyyy/MM/dd').format(fee.paymentDate!)
                                            : '-',
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
            child: const Text('طباعة'),
            onPressed: _print,
          ),
          Button(
            child: const Text('معاينة'),
            onPressed: _preview,
          ),
          Button(
            child: const Text('تخصيص القالبات'),
            onPressed: _customizeTemplates,
          ),
          FilledButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
