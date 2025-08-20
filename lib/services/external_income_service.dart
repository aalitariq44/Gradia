import '../models/external_income_model.dart';
import 'database_helper.dart';

class ExternalIncomeService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // إضافة دخل خارجي جديد
  Future<int> addExternalIncome(ExternalIncome income) async {
    final db = await _dbHelper.database;
    
    // إضافة جدول external_income إذا لم يكن موجود
    await _ensureTableExists(db);
    
    return await db.insert('external_income', income.toMap());
  }

  // الحصول على جميع الدخل الخارجي
  Future<List<ExternalIncome>> getAllExternalIncomes() async {
    final db = await _dbHelper.database;
    
    // إضافة جدول external_income إذا لم يكن موجود
    await _ensureTableExists(db);
    
    final maps = await db.query(
      'external_income',
      orderBy: 'income_date DESC',
    );
    
    return List.generate(maps.length, (i) {
      return ExternalIncome.fromMap(maps[i]);
    });
  }

  // الحصول على الدخل الخارجي حسب المدرسة
  Future<List<ExternalIncome>> getExternalIncomesBySchool(int schoolId) async {
    final db = await _dbHelper.database;
    
    // إضافة جدول external_income إذا لم يكن موجود
    await _ensureTableExists(db);
    
    final maps = await db.query(
      'external_income',
      where: 'school_id = ?',
      whereArgs: [schoolId],
      orderBy: 'income_date DESC',
    );
    
    return List.generate(maps.length, (i) {
      return ExternalIncome.fromMap(maps[i]);
    });
  }

  // تحديث دخل خارجي
  Future<int> updateExternalIncome(ExternalIncome income) async {
    final db = await _dbHelper.database;
    
    // إضافة جدول external_income إذا لم يكن موجود
    await _ensureTableExists(db);
    
    return await db.update(
      'external_income',
      income.toMap(),
      where: 'id = ?',
      whereArgs: [income.id],
    );
  }

  // حذف دخل خارجي
  Future<int> deleteExternalIncome(int id) async {
    final db = await _dbHelper.database;
    
    // إضافة جدول external_income إذا لم يكن موجود
    await _ensureTableExists(db);
    
    return await db.delete(
      'external_income',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // الحصول على إجمالي الدخل الخارجي لمدرسة معينة
  Future<double> getTotalExternalIncomeBySchool(int schoolId) async {
    final db = await _dbHelper.database;
    
    // إضافة جدول external_income إذا لم يكن موجود
    await _ensureTableExists(db);
    
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM external_income WHERE school_id = ?',
      [schoolId],
    );
    
    return (result.first['total'] as double?) ?? 0.0;
  }

  // الحصول على الدخل الخارجي حسب الفئة
  Future<List<ExternalIncome>> getExternalIncomesByCategory(
    int schoolId,
    String category,
  ) async {
    final db = await _dbHelper.database;
    
    // إضافة جدول external_income إذا لم يكن موجود
    await _ensureTableExists(db);
    
    final maps = await db.query(
      'external_income',
      where: 'school_id = ? AND category = ?',
      whereArgs: [schoolId, category],
      orderBy: 'income_date DESC',
    );
    
    return List.generate(maps.length, (i) {
      return ExternalIncome.fromMap(maps[i]);
    });
  }

  // الحصول على الدخل الخارجي خلال فترة زمنية
  Future<List<ExternalIncome>> getExternalIncomesByDateRange(
    int schoolId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    
    // إضافة جدول external_income إذا لم يكن موجود
    await _ensureTableExists(db);
    
    final maps = await db.query(
      'external_income',
      where: 'school_id = ? AND income_date BETWEEN ? AND ?',
      whereArgs: [
        schoolId,
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
      orderBy: 'income_date DESC',
    );
    
    return List.generate(maps.length, (i) {
      return ExternalIncome.fromMap(maps[i]);
    });
  }

  // التأكد من وجود جدول external_income
  Future<void> _ensureTableExists(db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS external_income (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        school_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        amount DECIMAL(10,2) NOT NULL,
        category TEXT NOT NULL,
        income_type TEXT NOT NULL,
        description TEXT,
        income_date DATE NOT NULL,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
      )
    ''');

    // إنشاء فهارس للبحث السريع
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_external_income_school_id ON external_income(school_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_external_income_category ON external_income(category)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_external_income_date ON external_income(income_date)',
    );
  }
}
