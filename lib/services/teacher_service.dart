import '../models/teacher_model.dart';
import 'database_helper.dart';

class TeacherService {
  static final TeacherService _instance = TeacherService._internal();
  factory TeacherService() => _instance;
  TeacherService._internal();

  // إضافة معلم جديد
  Future<int> insertTeacher(Teacher teacher) async {
    final db = await DatabaseHelper().database;
    final teacherMap = teacher.toMap();
    teacherMap.remove('id'); // إزالة المعرف للإدراج
    return await db.insert('teachers', teacherMap);
  }

  // الحصول على جميع المعلمين
  Future<List<Teacher>> getAllTeachers() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'teachers',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Teacher.fromMap(maps[i]));
  }

  // الحصول على معلمين حسب المدرسة
  Future<List<Teacher>> getTeachersBySchool(int schoolId) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'teachers',
      where: 'school_id = ?',
      whereArgs: [schoolId],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Teacher.fromMap(maps[i]));
  }

  // البحث في المعلمين
  Future<List<Teacher>> searchTeachers(String searchTerm) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'teachers',
      where: 'name LIKE ?',
      whereArgs: ['%$searchTerm%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Teacher.fromMap(maps[i]));
  }

  // البحث المفصل (بالاسم والمدرسة)
  Future<List<Teacher>> searchTeachersDetailed({
    String? name,
    int? schoolId,
  }) async {
    final db = await DatabaseHelper().database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (name != null && name.isNotEmpty) {
      whereClause += 'name LIKE ?';
      whereArgs.add('%$name%');
    }

    if (schoolId != null) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += 'school_id = ?';
      whereArgs.add(schoolId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'teachers',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Teacher.fromMap(maps[i]));
  }

  // الحصول على معلم بالمعرف
  Future<Teacher?> getTeacherById(int id) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'teachers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Teacher.fromMap(maps.first);
    }
    return null;
  }

  // تحديث معلم
  Future<int> updateTeacher(Teacher teacher) async {
    final db = await DatabaseHelper().database;
    final teacherMap = teacher.toMap();
    teacherMap['updated_at'] = DateTime.now().toIso8601String();

    return await db.update(
      'teachers',
      teacherMap,
      where: 'id = ?',
      whereArgs: [teacher.id],
    );
  }

  // حذف معلم
  Future<int> deleteTeacher(int id) async {
    final db = await DatabaseHelper().database;
    return await db.delete('teachers', where: 'id = ?', whereArgs: [id]);
  }

  // الحصول على عدد المعلمين
  Future<int> getTeachersCount() async {
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM teachers');
    return result.first['count'] as int;
  }

  // الحصول على عدد المعلمين حسب المدرسة
  Future<int> getTeachersCountBySchool(int schoolId) async {
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM teachers WHERE school_id = ?',
      [schoolId],
    );
    return result.first['count'] as int;
  }

  // الحصول على إجمالي الرواتب
  Future<double> getTotalSalaries() async {
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery(
      'SELECT SUM(monthly_salary) as total FROM teachers',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // الحصول على إجمالي الحصص
  Future<int> getTotalClassHours() async {
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery(
      'SELECT SUM(class_hours) as total FROM teachers',
    );
    return (result.first['total'] as int?) ?? 0;
  }

  // الحصول على المعلمين مع أسماء المدارس
  Future<List<Map<String, dynamic>>> getTeachersWithSchoolNames() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, s.name as school_name 
      FROM teachers t 
      LEFT JOIN schools s ON t.school_id = s.id 
      ORDER BY t.name ASC
    ''');
    return maps;
  }

  // حذف جميع المعلمين (للاختبار فقط)
  Future<void> deleteAllTeachers() async {
    final db = await DatabaseHelper().database;
    await db.delete('teachers');
  }
}
