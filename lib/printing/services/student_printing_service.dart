import 'dart:typed_data';

import '../models/print_config.dart';
import '../services/printing_service.dart';
import '../../models/student_model.dart';
import '../../models/school_model.dart';

/// خدمة طباعة متخصصة للطلاب
class StudentPrintingService {
  static final StudentPrintingService _instance =
      StudentPrintingService._internal();
  factory StudentPrintingService() => _instance;
  StudentPrintingService._internal();

  final PrintingService _printingService = PrintingService();

  /// طباعة قائمة الطلاب مع إعدادات مخصصة
  Future<void> printStudentsList({
    required List<Student> students,
    required List<School> schools,
    Map<String, dynamic>? filters,
    bool showPreview = true,
  }) async {
    // تحويل بيانات الطلاب إلى تنسيق قابل للطباعة
    final printData = _convertStudentsToTableData(students, schools);

    // إنشاء عنوان ديناميكي بناءً على التصفية
    final title = _generateTitle(filters);
    final subtitle = _generateSubtitle(students.length, filters);

    // إعدادات الطباعة للطلاب مع الأعمدة الافتراضية
    final config = PrintConfig(
      title: title,
      subtitle: subtitle,
      orientation: 'portrait', // تغيير إلى عمودي كما طلب المستخدم
      fontSize: 9.0,
      headerFontSize: 16.0,
      columnHeaders: _getStudentColumnHeaders(),
      columnsToShow: _getDefaultColumns(), // الأعمدة الافتراضية
    );

    await _printingService.printTable(
      data: printData,
      config: config,
      previewOptions: PreviewOptions(showPreview: showPreview),
    );
  }

  /// الحصول على الأعمدة الافتراضية للطلاب
  List<String> _getDefaultColumns() {
    return [
      'index',
      'name',
      'school',
      'grade',
      'section',
      'gender',
      'status',
      'phone',
      'totalFee',
      'startDate',
    ];
  }

  /// طباعة سريعة لقائمة الطلاب
  Future<void> quickPrintStudents(
    List<Student> students,
    List<School> schools,
  ) async {
    await printStudentsList(
      students: students,
      schools: schools,
      showPreview: true,
    );
  }

  /// الحصول على جميع رؤوس الأعمدة المتاحة
  Map<String, String> _getAllColumnHeaders() {
    return {
      'index': '#',
      'name': 'اسم الطالب',
      'school': 'المدرسة',
      'grade': 'الصف',
      'section': 'الشعبة',
      'gender': 'الجنس',
      'status': 'الحالة',
      'phone': 'الهاتف',
      'totalFee': 'الرسوم',
      'startDate': 'تاريخ المباشرة',
      'academicYear': 'السنة الدراسية',
      'nationalIdNumber': 'رقم الهوية',
      'createdAt': 'تاريخ الإنشاء',
    };
  }

  /// طباعة تفاصيل طالب واحد
  Future<void> printStudentDetails({
    required Student student,
    required School school,
    bool showPreview = true,
  }) async {
    final printData = _convertStudentDetailsToTableData(student, school);

    final config = PrintConfig(
      title: 'بيانات الطالب: ${student.name}',
      subtitle: 'مدرسة: ${school.nameAr}',
      orientation: 'portrait',
      fontSize: 12.0,
      headerFontSize: 18.0,
      columnHeaders: {'field': 'البيان', 'value': 'القيمة'},
      columnsToShow: ['field', 'value'],
    );

    await _printingService.printTable(
      data: printData,
      config: config,
      previewOptions: PreviewOptions(showPreview: showPreview),
    );
  }

  /// تحويل قائمة الطلاب إلى بيانات جدول
  List<Map<String, dynamic>> _convertStudentsToTableData(
    List<Student> students,
    List<School> schools,
  ) {
    final schoolsMap = {for (var school in schools) school.id: school.nameAr};

    return students.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final student = entry.value;

      return {
        'index': index,
        'name': student.name,
        'school': schoolsMap[student.schoolId] ?? 'غير محدد',
        'grade': student.grade,
        'section': student.section,
        'gender': student.gender,
        'status': student.status,
        'phone': student.phone ?? '-',
        'totalFee': '${student.totalFee.toStringAsFixed(0)} د.ع',
        'startDate': student.startDate,
        'academicYear': student.academicYear ?? '-',
        'nationalIdNumber': student.nationalIdNumber ?? '-',
        'createdAt': student.createdAt,
      };
    }).toList();
  }

  /// تحويل تفاصيل طالب واحد إلى بيانات جدول
  List<Map<String, dynamic>> _convertStudentDetailsToTableData(
    Student student,
    School school,
  ) {
    return [
      {'field': 'الاسم الكامل', 'value': student.name},
      {'field': 'الرقم الوطني', 'value': student.nationalIdNumber ?? '-'},
      {'field': 'المدرسة', 'value': school.nameAr},
      {'field': 'الصف', 'value': student.grade},
      {'field': 'الشعبة', 'value': student.section},
      {'field': 'السنة الدراسية', 'value': student.academicYear ?? '-'},
      {'field': 'الجنس', 'value': student.gender},
      {'field': 'رقم الهاتف', 'value': student.phone ?? '-'},
      {
        'field': 'الرسوم الدراسية',
        'value': '${student.totalFee.toStringAsFixed(0)} د.ع',
      },
      {'field': 'تاريخ المباشرة', 'value': _formatDate(student.startDate)},
      {'field': 'الحالة', 'value': student.status},
      {'field': 'تاريخ الإنشاء', 'value': _formatDate(student.createdAt)},
    ];
  }

  /// رؤوس أعمدة جدول الطلاب
  Map<String, String> _getStudentColumnHeaders() {
    return {
      'index': '#',
      'name': 'اسم الطالب',
      'school': 'المدرسة',
      'grade': 'الصف',
      'section': 'الشعبة',
      'gender': 'الجنس',
      'status': 'الحالة',
      'phone': 'الهاتف',
      'totalFee': 'الرسوم',
      'startDate': 'تاريخ المباشرة',
    };
  }

  /// توليد عنوان ديناميكي بناءً على التصفية
  String _generateTitle(Map<String, dynamic>? filters) {
    if (filters == null || filters.isEmpty) {
      return 'قائمة جميع الطلاب';
    }

    List<String> titleParts = ['قائمة الطلاب'];

    if (filters['schoolName'] != null) {
      titleParts.add('- مدرسة ${filters['schoolName']}');
    }

    if (filters['grade'] != null) {
      titleParts.add('- صف ${filters['grade']}');
    }

    if (filters['section'] != null) {
      titleParts.add('- شعبة ${filters['section']}');
    }

    if (filters['status'] != null) {
      titleParts.add('- ${filters['status']}');
    }

    if (filters['gender'] != null) {
      titleParts.add('- ${filters['gender']}');
    }

    return titleParts.join(' ');
  }

  /// توليد عنوان فرعي مع إحصائيات
  String _generateSubtitle(int totalStudents, Map<String, dynamic>? filters) {
    List<String> subtitleParts = ['إجمالي الطلاب: $totalStudents'];

    if (filters != null && filters.isNotEmpty) {
      subtitleParts.add('(مصفى)');
    }

    subtitleParts.add('- تاريخ الطباعة: ${_formatDate(DateTime.now())}');

    return subtitleParts.join(' ');
  }

  /// تنسيق التاريخ
  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  /// طباعة إحصائيات الطلاب
  Future<void> printStudentsStatistics({
    required Map<String, int> genderCounts,
    required Map<String, int> statusCounts,
    required Map<String, int> gradeCounts,
    bool showPreview = true,
  }) async {
    final printData = _convertStatisticsToTableData(
      genderCounts,
      statusCounts,
      gradeCounts,
    );

    final config = PrintConfig(
      title: 'إحصائيات الطلاب',
      subtitle: 'تقرير شامل عن توزيع الطلاب',
      orientation: 'portrait',
      fontSize: 12.0,
      headerFontSize: 16.0,
      columnHeaders: {
        'category': 'التصنيف',
        'item': 'العنصر',
        'count': 'العدد',
        'percentage': 'النسبة المئوية',
      },
      columnsToShow: ['category', 'item', 'count', 'percentage'],
    );

    await _printingService.printTable(
      data: printData,
      config: config,
      previewOptions: PreviewOptions(showPreview: showPreview),
    );
  }

  /// تحويل الإحصائيات إلى بيانات جدول
  List<Map<String, dynamic>> _convertStatisticsToTableData(
    Map<String, int> genderCounts,
    Map<String, int> statusCounts,
    Map<String, int> gradeCounts,
  ) {
    List<Map<String, dynamic>> data = [];

    final totalStudents = genderCounts.values.fold(0, (a, b) => a + b);

    // إحصائيات الجنس
    genderCounts.forEach((gender, count) {
      final percentage = totalStudents > 0
          ? (count / totalStudents * 100).toStringAsFixed(1)
          : '0.0';
      data.add({
        'category': 'الجنس',
        'item': gender,
        'count': count,
        'percentage': '$percentage%',
      });
    });

    // إحصائيات الحالة
    statusCounts.forEach((status, count) {
      final percentage = totalStudents > 0
          ? (count / totalStudents * 100).toStringAsFixed(1)
          : '0.0';
      data.add({
        'category': 'الحالة',
        'item': status,
        'count': count,
        'percentage': '$percentage%',
      });
    });

    // إحصائيات الصفوف
    gradeCounts.forEach((grade, count) {
      final percentage = totalStudents > 0
          ? (count / totalStudents * 100).toStringAsFixed(1)
          : '0.0';
      data.add({
        'category': 'الصف',
        'item': grade,
        'count': count,
        'percentage': '$percentage%',
      });
    });

    return data;
  }

  /// إنشاء ملف PDF لقائمة الطلاب
  Future<Uint8List> generateStudentsListPdf({
    required List<Student> students,
    required List<School> schools,
    Map<String, dynamic>? filters,
  }) async {
    final printData = _convertStudentsToTableData(students, schools);
    final title = _generateTitle(filters);
    final subtitle = _generateSubtitle(students.length, filters);

    final config = PrintConfig(
      title: title,
      subtitle: subtitle,
      orientation: 'portrait',
      fontSize: 9.0,
      headerFontSize: 16.0,
      columnHeaders: _getStudentColumnHeaders(),
      columnsToShow: _getDefaultColumns(),
    );

    return await _printingService.generatePdfBytes(
      data: printData,
      config: config,
    );
  }
}