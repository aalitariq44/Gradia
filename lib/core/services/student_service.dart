import '../database/db_manager.dart';
import '../database/models/student_model.dart';

class StudentService {
  // Get all students with school names
  static Future<List<StudentModel>> getAllStudents() async {
    final db = await DbManager.database;
    final result = await db.rawQuery('''
      SELECT s.*, sc.name_ar as school_name
      FROM students s
      LEFT JOIN schools sc ON s.school_id = sc.id
      ORDER BY s.name ASC
    ''');
    return result.map((map) => StudentModel.fromMap(map)).toList();
  }

  // Get student by ID
  static Future<StudentModel?> getStudentById(int id) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      '''
      SELECT s.*, sc.name_ar as school_name
      FROM students s
      LEFT JOIN schools sc ON s.school_id = sc.id
      WHERE s.id = ?
    ''',
      [id],
    );

    if (result.isNotEmpty) {
      return StudentModel.fromMap(result.first);
    }
    return null;
  }

  // Get students by school ID
  static Future<List<StudentModel>> getStudentsBySchool(int schoolId) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      '''
      SELECT s.*, sc.name_ar as school_name
      FROM students s
      LEFT JOIN schools sc ON s.school_id = sc.id
      WHERE s.school_id = ?
      ORDER BY s.name ASC
    ''',
      [schoolId],
    );
    return result.map((map) => StudentModel.fromMap(map)).toList();
  }

  // Search students
  static Future<List<StudentModel>> searchStudents(String query) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      '''
      SELECT s.*, sc.name_ar as school_name
      FROM students s
      LEFT JOIN schools sc ON s.school_id = sc.id
      WHERE s.name LIKE ? OR s.national_id_number LIKE ? OR s.grade LIKE ? OR s.section LIKE ?
      ORDER BY s.name ASC
    ''',
      ['%$query%', '%$query%', '%$query%', '%$query%'],
    );
    return result.map((map) => StudentModel.fromMap(map)).toList();
  }

  // Create new student
  static Future<int> createStudent(StudentModel student) async {
    final db = await DbManager.database;
    final now = DateTime.now();

    final studentToInsert = student.copyWith(createdAt: now, updatedAt: now);

    return await db.insert('students', studentToInsert.toMap());
  }

  // Update student
  static Future<int> updateStudent(StudentModel student) async {
    final db = await DbManager.database;
    return await db.update(
      'students',
      student.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  // Delete student
  static Future<int> deleteStudent(int id) async {
    final db = await DbManager.database;

    // Check if student has installments
    final installments = await db.query(
      'installments',
      where: 'student_id = ?',
      whereArgs: [id],
    );

    // Check if student has additional fees
    final additionalFees = await db.query(
      'additional_fees',
      where: 'student_id = ?',
      whereArgs: [id],
    );

    if (installments.isNotEmpty || additionalFees.isNotEmpty) {
      throw Exception('لا يمكن حذف الطالب لأنه يحتوي على أقساط أو رسوم إضافية');
    }

    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // Get students count
  static Future<int> getStudentsCount() async {
    final db = await DbManager.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM students');
    return result.first['count'] as int;
  }

  // Get students count by school
  static Future<int> getStudentsCountBySchool(int schoolId) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM students WHERE school_id = ?',
      [schoolId],
    );
    return result.first['count'] as int;
  }

  // Get total fees for all students
  static Future<double> getTotalFees() async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT SUM(total_fee) as total FROM students',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get paid installments total for a student
  static Future<double> getPaidInstallments(int studentId) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM installments WHERE student_id = ?',
      [studentId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get remaining balance for a student
  static Future<double> getRemainingBalance(int studentId) async {
    final student = await getStudentById(studentId);
    if (student == null) return 0.0;

    final paidInstallments = await getPaidInstallments(studentId);
    return student.totalFee - paidInstallments;
  }
}
