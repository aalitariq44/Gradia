import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart' as flutter_widgets show TextDirection;
import 'package:intl/intl.dart';
import '../models/installment_model.dart';
import '../models/student_model.dart';
import '../models/school_model.dart';
import '../services/installment_service.dart';
import '../services/student_service.dart';
import '../services/school_service.dart';

class TuitionsPage extends StatefulWidget {
  const TuitionsPage({Key? key}) : super(key: key);

  @override
  State<TuitionsPage> createState() => _TuitionsPageState();
}

class _TuitionsPageState extends State<TuitionsPage> {
  final InstallmentService _installmentService = InstallmentService();
  final StudentService _studentService = StudentService();
  final SchoolService _schoolService = SchoolService();

  List<Installment> _installments = [];
  List<Installment> _filteredInstallments = [];
  List<Student> _students = [];
  List<School> _schools = [];
  bool _isLoading = false;

  // متحكمات التصفية
  int? _selectedSchoolId;
  int? _selectedStudentId;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // الإحصائيات
  double _totalAmount = 0.0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([_loadInstallments(), _loadStudents(), _loadSchools()]);
      _applyFilters();
    } catch (e) {
      _showErrorDialog('خطأ في تحميل البيانات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadInstallments() async {
    _installments = await _installmentService.getAllInstallments();
  }

  Future<void> _loadStudents() async {
    _students = await _studentService.getAllStudents();
  }

  Future<void> _loadSchools() async {
    _schools = await _schoolService.getAllSchools();
  }

  void _applyFilters() {
    List<Installment> filtered = List.from(_installments);

    // تصفية حسب المدرسة
    if (_selectedSchoolId != null) {
      final studentIds = _students
          .where((s) => s.schoolId == _selectedSchoolId)
          .map((s) => s.id!)
          .toList();
      filtered = filtered
          .where((i) => studentIds.contains(i.studentId))
          .toList();
    }

    // تصفية حسب الطالب
    if (_selectedStudentId != null) {
      filtered = filtered
          .where((i) => i.studentId == _selectedStudentId)
          .toList();
    }

    // تصفية حسب نطاق التاريخ
    if (_startDate != null) {
      filtered = filtered
          .where(
            (i) => i.paymentDate.isAfter(
              _startDate!.subtract(const Duration(days: 1)),
            ),
          )
          .toList();
    }
    if (_endDate != null) {
      filtered = filtered
          .where(
            (i) =>
                i.paymentDate.isBefore(_endDate!.add(const Duration(days: 1))),
          )
          .toList();
    }

    setState(() {
      _filteredInstallments = filtered;
      _calculateTotals();
    });
  }

  void _calculateTotals() {
    _totalAmount = _filteredInstallments.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );
    _totalCount = _filteredInstallments.length;
  }

  void _clearFilters() {
    setState(() {
      _selectedSchoolId = null;
      _selectedStudentId = null;
      _startDate = null;
      _endDate = null;
      _startDateController.clear();
      _endDateController.clear();
    });
    _applyFilters();
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

  Future<void> _selectDate(bool isStartDate) async {
    final currentDate = isStartDate ? _startDate : _endDate;
    final TextEditingController dateController = TextEditingController(
      text: currentDate != null
          ? DateFormat('yyyy-MM-dd').format(currentDate)
          : '',
    );

    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(isStartDate ? 'اختر تاريخ البداية' : 'اختر تاريخ النهاية'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormBox(
                controller: dateController,
                placeholder: 'YYYY-MM-DD',
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  try {
                    DateTime.parse(value);
                    return null;
                  } catch (e) {
                    return 'تنسيق التاريخ غير صحيح';
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'أمثلة: 2024-01-15, 2024-12-31',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          Button(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('موافق'),
            onPressed: () {
              try {
                if (dateController.text.isNotEmpty) {
                  final picked = DateTime.parse(dateController.text);
                  setState(() {
                    if (isStartDate) {
                      _startDate = picked;
                      _startDateController.text = DateFormat(
                        'yyyy-MM-dd',
                      ).format(picked);
                    } else {
                      _endDate = picked;
                      _endDateController.text = DateFormat(
                        'yyyy-MM-dd',
                      ).format(picked);
                    }
                  });
                  _applyFilters();
                }
                Navigator.pop(context);
              } catch (e) {
                // إظهار رسالة خطأ
              }
            },
          ),
        ],
      ),
    );
  }

  String _getStudentName(int studentId) {
    try {
      final student = _students.firstWhere((s) => s.id == studentId);
      return student.name;
    } catch (e) {
      return 'غير محدد';
    }
  }

  String _getSchoolName(int studentId) {
    try {
      final student = _students.firstWhere((s) => s.id == studentId);
      final school = _schools.firstWhere((s) => s.id == student.schoolId);
      return school.nameAr;
    } catch (e) {
      return 'غير محدد';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: flutter_widgets.TextDirection.rtl,
      child: ScaffoldPage(
        content: Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 16),
          child: Column(
            children: [
              // الرأس والعنوان

              // شريط إدارة الأقساط
              _buildManagementBar(),
              const SizedBox(height: 16),

              // قسم التصفية والبحث
              _buildFilterSection(),
              const SizedBox(height: 16),

              // أزرار الإجراءات
              _buildActionButtons(),
              const SizedBox(height: 16),

              // الجدول الرئيسي
              Expanded(child: _buildInstallmentsTable()),

              // معلومات التلخيص
              _buildSummarySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إدارة الأقساط',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'عرض وإدارة جميع الأقساط المدفوعة في النظام مع إمكانيات البحث والتصفية المتقدمة',
                  style: TextStyle(fontSize: 14, color: Colors.grey[120]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.light,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  'إجمالي الأقساط',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${NumberFormat('#,###').format(_totalAmount)} ريال',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'التصفية والبحث',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // قائمة المدارس
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('المدرسة'),
                    const SizedBox(height: 8),
                    ComboBox<int?>(
                      placeholder: const Text('جميع المدارس'),
                      value: _selectedSchoolId,
                      items: [
                        const ComboBoxItem<int?>(
                          value: null,
                          child: Text('جميع المدارس'),
                        ),
                        ..._schools.map(
                          (school) => ComboBoxItem<int?>(
                            value: school.id,
                            child: Text(school.nameAr),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedSchoolId = value;
                          _selectedStudentId = null; // إعادة تعيين الطالب
                        });
                        _applyFilters();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // قائمة الطلاب
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('الطالب'),
                    const SizedBox(height: 8),
                    ComboBox<int?>(
                      placeholder: const Text('جميع الطلاب'),
                      value: _selectedStudentId,
                      items: [
                        const ComboBoxItem<int?>(
                          value: null,
                          child: Text('جميع الطلاب'),
                        ),
                        ..._students
                            .where(
                              (student) =>
                                  _selectedSchoolId == null ||
                                  student.schoolId == _selectedSchoolId,
                            )
                            .map(
                              (student) => ComboBoxItem<int?>(
                                value: student.id,
                                child: Text(student.name),
                              ),
                            ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedStudentId = value);
                        _applyFilters();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // تاريخ البداية
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('من تاريخ'),
                    const SizedBox(height: 8),
                    TextFormBox(
                      controller: _startDateController,
                      placeholder: 'اختر تاريخ البداية',
                      readOnly: true,
                      onTap: () => _selectDate(true),
                      suffix: IconButton(
                        icon: const Icon(FluentIcons.calendar),
                        onPressed: () => _selectDate(true),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // تاريخ النهاية
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('إلى تاريخ'),
                    const SizedBox(height: 8),
                    TextFormBox(
                      controller: _endDateController,
                      placeholder: 'اختر تاريخ النهاية',
                      readOnly: true,
                      onTap: () => _selectDate(false),
                      suffix: IconButton(
                        icon: const Icon(FluentIcons.calendar),
                        onPressed: () => _selectDate(false),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Button(
          onPressed: _clearFilters,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.clear_filter, size: 16),
              SizedBox(width: 8),
              Text('مسح المرشح'),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Button(
          onPressed: _loadData,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.refresh, size: 16),
              SizedBox(width: 8),
              Text('تحديث'),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Button(
          onPressed: () {
            // TODO: تصدير التقرير
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.document, size: 16),
              SizedBox(width: 8),
              Text('تقرير مالي'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstallmentsTable() {
    if (_isLoading) {
      return const Center(child: ProgressRing());
    }

    if (_filteredInstallments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FluentIcons.money, size: 64, color: Colors.grey[120]),
            const SizedBox(height: 16),
            Text(
              'لا توجد أقساط مدفوعة',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[120],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم يتم العثور على أقساط تطابق معايير البحث المحددة',
              style: TextStyle(fontSize: 14, color: Colors.grey[100]),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]),
      ),
      child: Column(
        children: [
          // رأس الجدول
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.light,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'رقم الوصل',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'الطالب',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'المدرسة',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'المبلغ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'تاريخ الدفع',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'وقت الدفع',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'ملاحظات',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // صفوف البيانات
          Expanded(
            child: ListView.builder(
              itemCount: _filteredInstallments.length,
              itemBuilder: (context, index) {
                final installment = _filteredInstallments[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[50])),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('${installment.id ?? '-'}'),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          _getStudentName(installment.studentId),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(_getSchoolName(installment.studentId)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${NumberFormat('#,###').format(installment.amount)} ريال',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.dark,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          DateFormat(
                            'yyyy-MM-dd',
                          ).format(installment.paymentDate),
                        ),
                      ),
                      Expanded(flex: 2, child: Text(installment.paymentTime)),
                      Expanded(
                        flex: 3,
                        child: Text(
                          installment.notes ?? '-',
                          style: TextStyle(
                            color: Colors.grey[120],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ملخص الأقساط المعروضة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'عدد الأقساط: $_totalCount قسط',
                style: TextStyle(fontSize: 14, color: Colors.grey[120]),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.light, Colors.green.dark],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  'إجمالي المبلغ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${NumberFormat('#,###').format(_totalAmount)} ريال',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}
