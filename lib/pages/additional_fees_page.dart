import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart' as flutter_widgets show TextDirection;
import 'package:intl/intl.dart';
import '../models/additional_fee_model.dart';
import '../models/student_model.dart';
import '../models/school_model.dart';
import '../services/additional_fee_service.dart';
import '../services/student_service.dart';
import '../services/school_service.dart';

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
  double _paidAmount = 0.0;
  double _unpaidAmount = 0.0;
  int _totalCount = 0;
  int _paidCount = 0;
  int _unpaidCount = 0;

  // أنواع الرسوم المعرفة مسبقاً
  final List<String> _predefinedFeeTypes = [
    'رسوم نقل',
    'رسوم كتب',
    'رسوم أنشطة',
    'رسوم امتحانات',
    'رسوم مختبر',
    'رسوم رحلات',
    'رسوم زي مدرسي',
    'رسوم طبية',
    'رسوم إضافية أخرى',
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
    _paidAmount = _filteredFees
        .where((f) => f.paid)
        .fold(0.0, (sum, fee) => sum + fee.amount);
    _unpaidAmount = _filteredFees
        .where((f) => !f.paid)
        .fold(0.0, (sum, fee) => sum + fee.amount);

    _totalCount = _filteredFees.length;
    _paidCount = _filteredFees.where((f) => f.paid).length;
    _unpaidCount = _filteredFees.where((f) => !f.paid).length;
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
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            children: [
              // القسم العلوي - شريط الإحصائيات
              _buildStatisticsSection(),
              const SizedBox(height: 16),

              // قسم الفلاتر والبحث
              _buildFiltersSection(),
              const SizedBox(height: 16),

              // أزرار العمليات
              _buildActionButtons(),
              const SizedBox(height: 16),

              // الجدول الرئيسي
              Expanded(child: _buildFeesTable()),

              // القسم السفلي - ملخص الرسوم
              _buildSummarySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.light, Colors.purple.light],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'إدارة الرسوم الإضافية',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'عدد الرسوم المعروضة: $_totalCount',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'عرض وإدارة جميع الرسوم الإضافية مع إمكانيات البحث والتصفية',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'إجمالي المبلغ',
                  '${NumberFormat('#,###').format(_totalAmount)} ريال',
                  Colors.white.withOpacity(0.2),
                  FluentIcons.money,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'المحصول',
                  '${NumberFormat('#,###').format(_paidAmount)} ريال',
                  Colors.white.withOpacity(0.2),
                  FluentIcons.accept,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'المستحق',
                  '${NumberFormat('#,###').format(_unpaidAmount)} ريال',
                  Colors.white.withOpacity(0.2),
                  FluentIcons.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color backgroundColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
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

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]),
      ),
      child: Row(
        children: [
          // قائمة المدارس
          Expanded(
            child: ComboBox<int?>(
              placeholder: const Text('المدرسة'),
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
          ),
          const SizedBox(width: 12),

          // قائمة الطلاب
          Expanded(
            child: ComboBox<int?>(
              placeholder: const Text('الطالب'),
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
          ),
          const SizedBox(width: 12),

          // قائمة نوع الرسم
          Expanded(
            child: ComboBox<String?>(
              placeholder: const Text('نوع الرسم'),
              value: _selectedFeeType,
              items: [
                const ComboBoxItem<String?>(
                  value: null,
                  child: Text('جميع الأنواع'),
                ),
                ..._feeTypes.map(
                  (type) =>
                      ComboBoxItem<String?>(value: type, child: Text(type)),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedFeeType = value);
                _applyFilters();
              },
            ),
          ),
          const SizedBox(width: 12),

          // قائمة حالة الدفع
          Expanded(
            child: ComboBox<String?>(
              placeholder: const Text('حالة الدفع'),
              value: _selectedPaymentStatus,
              items: const [
                ComboBoxItem<String?>(value: null, child: Text('الكل')),
                ComboBoxItem<String?>(value: 'مدفوع', child: Text('مدفوع')),
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
          ),
          const SizedBox(width: 12),

          // مربع البحث
          Expanded(
            child: TextFormBox(
              controller: _searchController,
              placeholder: 'البحث...',
              prefix: const Icon(FluentIcons.search),
              onChanged: (value) => _applyFilters(),
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
              Text('مسح الفلاتر'),
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
              Text('تصدير التقرير'),
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
            Icon(
              FluentIcons.receipt_processing,
              size: 64,
              color: Colors.grey[120],
            ),
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
                Expanded(
                  flex: 2,
                  child: Text(
                    'تاريخ الإنشاء',
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
                          '${NumberFormat('#,###').format(fee.amount)} ريال',
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: fee.paid
                                ? Colors.green.light
                                : Colors.orange.light,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            fee.paid ? 'مدفوع' : 'غير مدفوع',
                            style: TextStyle(
                              color: fee.paid
                                  ? Colors.green.dark
                                  : Colors.orange.dark,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
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
                      Expanded(
                        flex: 2,
                        child: Text(
                          DateFormat('yyyy-MM-dd').format(fee.createdAt),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملخص الرسوم',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عدد الرسوم غير المدفوعة: $_unpaidCount',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.dark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'عدد الرسوم المدفوعة: $_paidCount',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.dark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المبلغ غير المدفوع: ${NumberFormat('#,###').format(_unpaidAmount)} ريال',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.dark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'المبلغ المدفوع: ${NumberFormat('#,###').format(_paidAmount)} ريال',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.dark,
                        fontWeight: FontWeight.w500,
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
