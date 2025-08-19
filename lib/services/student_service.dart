import '../models/student_model.dart';
import 'database_helper.dart';

class StudentService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Student>> getAllStudents() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'is_active = ?',
      whereArgs: [1],
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
      where: 'school_id = ? AND is_active = ?',
      whereArgs: [schoolId, 1],
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

  Future<Student?> getStudentByStudentId(String studentId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );

    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertStudent(Student student) async {
    final db = await _databaseHelper.database;

    // التحقق من عدم وجود طالب بنفس رقم الطالب
    final existing = await db.query(
      'students',
      where: 'student_id = ?',
      whereArgs: [student.studentId],
    );

    if (existing.isNotEmpty) {
      throw Exception('رقم الطالب موجود بالفعل');
    }

    return await db.insert('students', student.toMap());
  }

  Future<int> updateStudent(Student student) async {
    final db = await _databaseHelper.database;

    // التحقق من عدم وجود طالب آخر بنفس رقم الطالب
    final existing = await db.query(
      'students',
      where: 'student_id = ? AND id != ?',
      whereArgs: [student.studentId, student.id],
    );

    if (existing.isNotEmpty) {
      throw Exception('رقم الطالب موجود بالفعل');
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
      // في حالة وجود أقساط، نقوم بإلغاء تفعيل الطالب بدلاً من الحذف
      return await db.update(
        'students',
        {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
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
      where: '''(name LIKE ? OR student_id LIKE ? OR parent_name LIKE ? 
                 OR grade LIKE ? OR class_section LIKE ?) AND is_active = ?''',
      whereArgs: [
        '%$query%',
        '%$query%',
        '%$query%',
        '%$query%',
        '%$query%',
        1,
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
      'SELECT COUNT(*) as count FROM students WHERE is_active = 1',
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<int> getStudentsCountBySchool(int schoolId) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM students WHERE school_id = ? AND is_active = 1',
      [schoolId],
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
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT s.*, sc.name as school_name 
      FROM students s 
      LEFT JOIN schools sc ON s.school_id = sc.id 
      WHERE s.is_active = 1 
      ORDER BY s.name ASC
    ''');

    return result;
  }
}
