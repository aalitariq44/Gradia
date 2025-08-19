import '../models/school_model.dart';
import 'database_helper.dart';

class SchoolService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<School>> getAllSchools() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'schools',
      orderBy: 'name_ar ASC',
    );

    return List.generate(maps.length, (i) {
      return School.fromMap(maps[i]);
    });
  }

  Future<School?> getSchoolById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'schools',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return School.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertSchool(School school) async {
    final db = await _databaseHelper.database;

    // التحقق من عدم وجود مدرسة بنفس الاسم العربي
    final existing = await db.query(
      'schools',
      where: 'name_ar = ?',
      whereArgs: [school.nameAr],
    );

    if (existing.isNotEmpty) {
      throw Exception('مدرسة بهذا الاسم موجودة بالفعل');
    }

    return await db.insert('schools', school.toMap());
  }

  Future<int> updateSchool(School school) async {
    final db = await _databaseHelper.database;

    // التحقق من عدم وجود مدرسة أخرى بنفس الاسم العربي
    final existing = await db.query(
      'schools',
      where: 'name_ar = ? AND id != ?',
      whereArgs: [school.nameAr, school.id],
    );

    if (existing.isNotEmpty) {
      throw Exception('مدرسة بهذا الاسم موجودة بالفعل');
    }

    final updatedSchool = school.copyWith(updatedAt: DateTime.now());

    return await db.update(
      'schools',
      updatedSchool.toMap(),
      where: 'id = ?',
      whereArgs: [school.id],
    );
  }

  Future<int> deleteSchool(int id) async {
    final db = await _databaseHelper.database;

    // التحقق من وجود طلاب مرتبطين بهذه المدرسة
    final students = await db.query(
      'students',
      where: 'school_id = ?',
      whereArgs: [id],
    );

    if (students.isNotEmpty) {
      throw Exception('لا يمكن حذف المدرسة لوجود طلاب مسجلين بها');
    }

    return await db.delete('schools', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<School>> searchSchools(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'schools',
      where:
          'name_ar LIKE ? OR name_en LIKE ? OR address LIKE ? OR phone LIKE ? OR principal_name LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: 'name_ar ASC',
    );

    return List.generate(maps.length, (i) {
      return School.fromMap(maps[i]);
    });
  }

  Future<int> getSchoolsCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM schools');
    return result.first['count'] as int? ?? 0;
  }

  Future<Map<String, dynamic>> getSchoolStatistics(int schoolId) async {
    final db = await _databaseHelper.database;

    // عدد الطلاب
    final studentsResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM students WHERE school_id = ? AND is_active = 1',
      [schoolId],
    );
    final studentsCount = studentsResult.first['count'] as int? ?? 0;

    // إجمالي الأقساط المستحقة
    final totalDueResult = await db.rawQuery(
      '''
      SELECT SUM(i.amount) as total 
      FROM installments i 
      INNER JOIN students s ON i.student_id = s.id 
      WHERE s.school_id = ? AND i.payment_status = 'pending'
    ''',
      [schoolId],
    );
    final totalDue = (totalDueResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // إجمالي الأقساط المدفوعة
    final totalPaidResult = await db.rawQuery(
      '''
      SELECT SUM(i.amount) as total 
      FROM installments i 
      INNER JOIN students s ON i.student_id = s.id 
      WHERE s.school_id = ? AND i.payment_status = 'paid'
    ''',
      [schoolId],
    );
    final totalPaid =
        (totalPaidResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return {
      'studentsCount': studentsCount,
      'totalDue': totalDue,
      'totalPaid': totalPaid,
    };
  }
}
