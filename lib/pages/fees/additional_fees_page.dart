import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart' as flutter_widgets show TextDirection;
import 'package:intl/intl.dart';
import '../../models/additional_fee_model.dart';
import '../../models/student_model.dart';
import '../../models/school_model.dart';
import '../../services/additional_fee_service.dart';
import '../../services/student_service.dart';
import '../../services/school_service.dart';

class AdditionalFeesPage extends StatefulWidget {
  const AdditionalFeesPage({Key? key}) : super(key: key);

  @override
  State<AdditionalFeesPage> createState() => _AdditionalFeesPageState();
}

class _AdditionalFeesPageState extends State<AdditionalFeesPage> {
  final AdditionalFeeService _additionalFeeService = AdditionalFeeService();
  final StudentService _studentService = StudentService();
  final SchoolService _schoolService = SchoolService();

  List<AdditionalFee> _additionalFees = [];
  List<AdditionalFee> _filteredFees = [];
  List<Student> _students = [];
  List<School> _schools = [];
  List<String> _feeTypes = [];
  bool _isLoading = false;

  // متحكمات التصفية
  int? _selectedSchoolId;
  int? _selectedStudentId;
  String? _selectedFeeType;
  String? _selectedPaymentStatus;
  final TextEditingController _searchController = TextEditingController();

  // الإحصائيات
  double _totalAmount = 0.0;
  int _totalCount = 0;

  // أنواع الرسوم المعرفة مسبقاً
  final List<String> _predefinedFeeTypes = [
    'التسجيل',
    'كتب',
    'زي مدرسي',
    'نشاطات',
    'مختبر',
    'مكتبة',
    'نقل',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadAdditionalFees(),
        _loadStudents(),
        _loadSchools(),
        _loadFeeTypes(),
      ]);
      _applyFilters();
    } catch (e) {
      _showErrorDialog('خطأ في تحميل البيانات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAdditionalFees() async {
    // تحميل جميع الرسوم الإضافية من جميع الطلاب
    _additionalFees = [];
    for (final student in await _studentService.getAllStudents()) {
      final studentFees = await _additionalFeeService.getStudentAdditionalFees(
        student.id!,
      );
      _additionalFees.addAll(studentFees);
    }
  }

  Future<void> _loadStudents() async {
    _students = await _studentService.getAllStudents();
  }

  Future<void> _loadSchools() async {
    _schools = await _schoolService.getAllSchools();
  }

  Future<void> _loadFeeTypes() async {
    final usedTypes = await _additionalFeeService.getUsedFeeTypes();
    _feeTypes = [
      ..._predefinedFeeTypes,
      ...usedTypes.where((type) => !_predefinedFeeTypes.contains(type)),
    ];
  }

  void _applyFilters() {
    List<AdditionalFee> filtered = List.from(_additionalFees);

    // تصفية حسب المدرسة
    if (_selectedSchoolId != null) {
      final studentIds = _students
          .where((s) => s.schoolId == _selectedSchoolId)
          .map((s) => s.id!)
          .toList();
      filtered = filtered
          .where((f) => studentIds.contains(f.studentId))
          .toList();
    }

    // تصفية حسب الطالب
    if (_selectedStudentId != null) {
      filtered = filtered
          .where((f) => f.studentId == _selectedStudentId)
          .toList();
    }

    // تصفية حسب نوع الرسم
    if (_selectedFeeType != null && _selectedFeeType!.isNotEmpty) {
      filtered = filtered.where((f) => f.feeType == _selectedFeeType).toList();
    }

    // تصفية حسب حالة الدفع
    if (_selectedPaymentStatus != null) {
      if (_selectedPaymentStatus == 'مدفوع') {
        filtered = filtered.where((f) => f.paid).toList();
      } else if (_selectedPaymentStatus == 'غير مدفوع') {
        filtered = filtered.where((f) => !f.paid).toList();
      }
    }

    // البحث النصي
    if (_searchController.text.isNotEmpty) {
      final searchText = _searchController.text.toLowerCase();
      filtered = filtered.where((f) {
        final studentName = _getStudentName(f.studentId).toLowerCase();
        final schoolName = _getSchoolName(f.studentId).toLowerCase();
        final feeType = f.feeType.toLowerCase();
        final notes = (f.notes ?? '').toLowerCase();

        return studentName.contains(searchText) ||
            schoolName.contains(searchText) ||
            feeType.contains(searchText) ||
            notes.contains(searchText);
      }).toList();
    }

    setState(() {
      _filteredFees = filtered;
      _calculateStatistics();
    });
  }

  void _calculateStatistics() {
    _totalAmount = _filteredFees.fold(0.0, (sum, fee) => sum + fee.amount);
    _totalCount = _filteredFees.length;
  }

  void _clearFilters() {
    setState(() {
      _selectedSchoolId = null;
      _selectedStudentId = null;
      _selectedFeeType = null;
      _selectedPaymentStatus = null;
      _searchController.clear();
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
              // شريط إدارة الرسوم الإضافية
              _buildManagementBar(),
              const SizedBox(height: 16),

              // قسم التصفية والبحث
              _buildFilterSection(),
              const SizedBox(height: 16),

              // أزرار الإجراءات
              _buildActionButtons(),
              const SizedBox(height: 16),

              // الجدول الرئيسي
              Expanded(child: _buildFeesTable()),

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
                  'إدارة الرسوم الإضافية',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'عرض وإدارة جميع الرسوم الإضافية في النظام مع إمكانيات البحث والتصفية المتقدمة',
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
                  'إجمالي الرسوم',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${NumberFormat('#,###').format(_totalAmount)} د.ع',
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

          // Filters row with right alignment and fixed widths
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // قائمة المدارس
                SizedBox(
                  width: 180,
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
                            _selectedStudentId = null;
                          });
                          _applyFilters();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // قائمة الطلاب
                SizedBox(
                  width: 180,
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
                const SizedBox(width: 8),
                // نوع الرسم
                SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('نوع الرسم'),
                      const SizedBox(height: 8),
                      ComboBox<String?>(
                        placeholder: const Text('جميع الأنواع'),
                        value: _selectedFeeType,
                        items: [
                          const ComboBoxItem<String?>(
                            value: null,
                            child: Text('جميع الأنواع'),
                          ),
                          ..._feeTypes.map(
                            (type) => ComboBoxItem<String?>(
                              value: type,
                              child: Text(type),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedFeeType = value);
                          _applyFilters();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // حالة الدفع
                SizedBox(
                  width: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('حالة الدفع'),
                      const SizedBox(height: 8),
                      ComboBox<String?>(
                        placeholder: const Text('الكل'),
                        value: _selectedPaymentStatus,
                        items: const [
                          ComboBoxItem<String?>(
                            value: null,
                            child: Text('الكل'),
                          ),
                          ComboBoxItem<String?>(
                            value: 'مدفوع',
                            child: Text('مدفوع'),
                          ),
                          ComboBoxItem<String?>(
                            value: 'غير مدفوع',
                            child: Text('غير مدفوع'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedPaymentStatus = value);
                          _applyFilters();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // حقل البحث
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ابحث'),
                      const SizedBox(height: 8),
                      TextBox(
                        controller: _searchController,
                        placeholder: 'اسم الطالب أو نوع الرسم',
                        suffix: IconButton(
                          icon: const Icon(FluentIcons.search),
                          onPressed: _applyFilters,
                        ),
                        onChanged: (value) => _applyFilters(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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

  Widget _buildFeesTable() {
    if (_isLoading) {
      return const Center(child: ProgressRing());
    }

    if (_filteredFees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FluentIcons.money, size: 64, color: Colors.grey[120]),
            const SizedBox(height: 16),
            Text(
              'لا توجد رسوم إضافية',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[120],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم يتم العثور على رسوم تطابق معايير البحث المحددة',
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
                  flex: 1,
                  child: Text(
                    'تسلسل',
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
                    'نوع الرسم',
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
                    'حالة الدفع',
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
              itemCount: _filteredFees.length,
              itemBuilder: (context, index) {
                final fee = _filteredFees[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[50])),
                  ),
                  child: Row(
                    children: [
                      // تسلسل
                      Expanded(flex: 1, child: Text('${index + 1}')),
                      Expanded(
                        flex: 3,
                        child: Text(
                          _getStudentName(fee.studentId),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(_getSchoolName(fee.studentId)),
                      ),
                      Expanded(flex: 2, child: Text(fee.feeType)),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${NumberFormat('#,###').format(fee.amount)} د.ع',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: fee.paid
                                ? Colors.green.dark
                                : Colors.orange.dark,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          fee.paid ? 'مدفوع' : 'غير مدفوع',
                          style: TextStyle(
                            color: fee.paid
                                ? Colors.green.dark
                                : Colors.orange.dark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          fee.paymentDate != null
                              ? DateFormat(
                                  'yyyy-MM-dd',
                                ).format(fee.paymentDate!)
                              : '-',
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          fee.notes ?? '-',
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
                'ملخص الرسوم المعروضة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'عدد الرسوم: $_totalCount رسم',
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
                  '${NumberFormat('#,###').format(_totalAmount)} د.ع',
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
    _searchController.dispose();
    super.dispose();
  }
}
