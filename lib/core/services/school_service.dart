import '../database/db_manager.dart';
import '../database/models/school_model.dart';

class SchoolService {
  // Get all schools
  static Future<List<SchoolModel>> getAllSchools() async {
    final db = await DbManager.database;
    final result = await db.query('schools', orderBy: 'name_ar ASC');
    return result.map((map) => SchoolModel.fromMap(map)).toList();
  }

  // Get school by ID
  static Future<SchoolModel?> getSchoolById(int id) async {
    final db = await DbManager.database;
    final result = await db.query('schools', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return SchoolModel.fromMap(result.first);
    }
    return null;
  }

  // Search schools
  static Future<List<SchoolModel>> searchSchools(String query) async {
    final db = await DbManager.database;
    final result = await db.query(
      'schools',
      where: 'name_ar LIKE ? OR name_en LIKE ? OR address LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name_ar ASC',
    );
    return result.map((map) => SchoolModel.fromMap(map)).toList();
  }

  // Create new school
  static Future<int> createSchool(SchoolModel school) async {
    final db = await DbManager.database;
    final now = DateTime.now();

    final schoolToInsert = school.copyWith(createdAt: now, updatedAt: now);

    return await db.insert('schools', schoolToInsert.toMap());
  }

  // Update school
  static Future<int> updateSchool(SchoolModel school) async {
    final db = await DbManager.database;
    return await db.update(
      'schools',
      school.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [school.id],
    );
  }

  // Delete school
  static Future<int> deleteSchool(int id) async {
    final db = await DbManager.database;

    // Check if school has students
    final students = await db.query(
      'students',
      where: 'school_id = ?',
      whereArgs: [id],
    );

    if (students.isNotEmpty) {
      throw Exception('لا يمكن حذف المدرسة لأنها تحتوي على طلاب');
    }

    return await db.delete('schools', where: 'id = ?', whereArgs: [id]);
  }

  // Get schools count
  static Future<int> getSchoolsCount() async {
    final db = await DbManager.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM schools');
    return result.first['count'] as int;
  }
}
