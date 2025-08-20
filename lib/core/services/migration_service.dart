import '../database/db_manager.dart';
import '../database/models/school_model.dart';
import '../../services/school_service.dart';

class MigrationService {
  /// مهاجرة البيانات من قاعدة البيانات القديمة للجديدة
  static Future<void> migrateSchoolsFromOldToNew() async {
    try {
      // الحصول على المدارس من قاعدة البيانات القديمة
      final oldSchoolService = SchoolService();
      final oldSchools = await oldSchoolService.getAllSchools();

      // الحصول على قاعدة البيانات الجديدة
      final db = await DbManager.database;

      for (final oldSchool in oldSchools) {
        // التحقق من عدم وجود المدرسة في قاعدة البيانات الجديدة
        final existing = await db.query(
          'schools',
          where: 'name_ar = ?',
          whereArgs: [oldSchool.nameAr],
        );

        if (existing.isEmpty) {
          // إنشاء مدرسة جديدة في قاعدة البيانات الجديدة
          final newSchool = SchoolModel(
            nameAr: oldSchool.nameAr,
            nameEn: oldSchool.nameEn,
            logoPath: oldSchool.logoPath,
            address: oldSchool.address,
            phone: oldSchool.phone,
            principalName: oldSchool.principalName,
            schoolTypes: oldSchool.schoolTypes.join(','),
            createdAt: oldSchool.createdAt,
            updatedAt: DateTime.now(),
          );

          await db.insert('schools', newSchool.toMap());
          print('تم نقل المدرسة: ${oldSchool.nameAr}');
        }
      }

      print('تم الانتهاء من نقل جميع المدارس');
    } catch (e) {
      print('خطأ في نقل المدارس: $e');
      throw e;
    }
  }

  /// التحقق من وجود مدارس في قاعدة البيانات الجديدة
  static Future<bool> hasSchoolsInNewDatabase() async {
    try {
      final db = await DbManager.database;
      final result = await db.query('schools', limit: 1);
      return result.isNotEmpty;
    } catch (e) {
      print('خطأ في التحقق من المدارس: $e');
      return false;
    }
  }
}
