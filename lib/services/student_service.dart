import '../models/student_model.dart';
import 'database_helper.dart';

class StudentService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Student>> getAllStudents() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'status != ?',
      whereArgs: ['محذوف'],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  Future<List<Student>> getStudentsBySchool(int schoolId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'school_id = ? AND status != ?',
      whereArgs: [schoolId, 'محذوف'],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  Future<Student?> getStudentById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    }
    return null;
  }

  Future<Student?> getStudentByNationalId(String nationalId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'national_id_number = ?',
      whereArgs: [nationalId],
    );

    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertStudent(Student student) async {
    final db = await _databaseHelper.database;

    // التحقق من عدم وجود طالب بنفس الرقم الوطني
    if (student.nationalIdNumber != null &&
        student.nationalIdNumber!.isNotEmpty) {
      final existing = await db.query(
        'students',
        where: 'national_id_number = ?',
        whereArgs: [student.nationalIdNumber],
      );

      if (existing.isNotEmpty) {
        throw Exception('الرقم الوطني موجود بالفعل');
      }
    }

    return await db.insert('students', student.toMap());
  }

  Future<int> updateStudent(Student student) async {
    final db = await _databaseHelper.database;

    // التحقق من عدم وجود طالب آخر بنفس الرقم الوطني
    if (student.nationalIdNumber != null &&
        student.nationalIdNumber!.isNotEmpty) {
      final existing = await db.query(
        'students',
        where: 'national_id_number = ? AND id != ?',
        whereArgs: [student.nationalIdNumber, student.id],
      );

      if (existing.isNotEmpty) {
        throw Exception('الرقم الوطني موجود بالفعل');
      }
    }

    final updatedStudent = student.copyWith(updatedAt: DateTime.now());

    return await db.update(
      'students',
      updatedStudent.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await _databaseHelper.database;

    // التحقق من وجود أقساط أو رسوم مرتبطة بهذا الطالب
    final installments = await db.query(
      'installments',
      where: 'student_id = ?',
      whereArgs: [id],
    );

    final additionalFees = await db.query(
      'additional_fees',
      where: 'student_id = ?',
      whereArgs: [id],
    );

    if (installments.isNotEmpty || additionalFees.isNotEmpty) {
      // في حالة وجود أقساط، نقوم بتغيير الحالة إلى محذوف بدلاً من الحذف
      return await db.update(
        'students',
        {'status': 'محذوف', 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      // حذف نهائي إذا لم توجد أقساط مرتبطة
      return await db.delete('students', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<List<Student>> searchStudents(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: '''(name LIKE ? OR national_id_number LIKE ? OR phone LIKE ? 
                 OR grade LIKE ? OR section LIKE ?) AND status != ?''',
      whereArgs: [
        '%$query%',
        '%$query%',
        '%$query%',
        '%$query%',
        '%$query%',
        'محذوف',
      ],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  Future<int> getStudentsCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM students WHERE status != ?',
      ['محذوف'],
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<int> getStudentsCountBySchool(int schoolId) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM students WHERE school_id = ? AND status != ?',
      [schoolId, 'محذوف'],
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<Map<String, dynamic>> getStudentStatistics(int studentId) async {
    final db = await _databaseHelper.database;

    // إجمالي الأقساط المستحقة
    final totalInstallmentsDueResult = await db.rawQuery(
      '''
      SELECT SUM(amount) as total 
      FROM installments 
      WHERE student_id = ? AND payment_status = 'pending'
    ''',
      [studentId],
    );
    final totalInstallmentsDue =
        (totalInstallmentsDueResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // إجمالي الأقساط المدفوعة
    final totalInstallmentsPaidResult = await db.rawQuery(
      '''
      SELECT SUM(amount) as total 
      FROM installments 
      WHERE student_id = ? AND payment_status = 'paid'
    ''',
      [studentId],
    );
    final totalInstallmentsPaid =
        (totalInstallmentsPaidResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // إجمالي الرسوم الإضافية المستحقة
    final totalFeesDueResult = await db.rawQuery(
      '''
      SELECT SUM(amount) as total 
      FROM additional_fees 
      WHERE student_id = ? AND payment_status = 'pending'
    ''',
      [studentId],
    );
    final totalFeesDue =
        (totalFeesDueResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // إجمالي الرسوم الإضافية المدفوعة
    final totalFeesPaidResult = await db.rawQuery(
      '''
      SELECT SUM(amount) as total 
      FROM additional_fees 
      WHERE student_id = ? AND payment_status = 'paid'
    ''',
      [studentId],
    );
    final totalFeesPaid =
        (totalFeesPaidResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return {
      'totalInstallmentsDue': totalInstallmentsDue,
      'totalInstallmentsPaid': totalInstallmentsPaid,
      'totalFeesDue': totalFeesDue,
      'totalFeesPaid': totalFeesPaid,
      'totalDue': totalInstallmentsDue + totalFeesDue,
      'totalPaid': totalInstallmentsPaid + totalFeesPaid,
    };
  }

  Future<List<Map<String, dynamic>>> getStudentsWithSchoolInfo() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT s.*, sc.name_ar as school_name 
      FROM students s 
      LEFT JOIN schools sc ON s.school_id = sc.id 
      WHERE s.status != ? 
      ORDER BY s.name ASC
    ''',
      ['محذوف'],
    );

    return result;
  }

  // إحصائيات الطلاب
  Future<Map<String, int>> getStudentStatusCounts() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT status, COUNT(*) as count 
      FROM students 
      WHERE status != ? 
      GROUP BY status
    ''',
      ['محذوف'],
    );

    Map<String, int> counts = {};
    for (var row in result) {
      counts[row['status'] as String] = row['count'] as int;
    }
    return counts;
  }

  // إحصائيات الجنس
  Future<Map<String, int>> getStudentGenderCounts() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT gender, COUNT(*) as count 
      FROM students 
      WHERE status != ? 
      GROUP BY gender
    ''',
      ['محذوف'],
    );

    Map<String, int> counts = {};
    for (var row in result) {
      counts[row['gender'] as String] = row['count'] as int;
    }
    return counts;
  }

  // تصفية الطلاب
  Future<List<Student>> getFilteredStudents({
    int? schoolId,
    String? grade,
    String? section,
    String? status,
    String? gender,
  }) async {
    final db = await _databaseHelper.database;

    String whereClause = 'status != ?';
    List<dynamic> whereArgs = ['محذوف'];

    if (schoolId != null) {
      whereClause += ' AND school_id = ?';
      whereArgs.add(schoolId);
    }

    if (grade != null && grade.isNotEmpty) {
      whereClause += ' AND grade = ?';
      whereArgs.add(grade);
    }

    if (section != null && section.isNotEmpty) {
      whereClause += ' AND section = ?';
      whereArgs.add(section);
    }

    if (status != null && status.isNotEmpty) {
      whereClause += ' AND status = ?';
      whereArgs.add(status);
    }

    if (gender != null && gender.isNotEmpty) {
      whereClause += ' AND gender = ?';
      whereArgs.add(gender);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }
}
