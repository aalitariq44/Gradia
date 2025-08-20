import '../models/expense_model.dart';
import 'database_helper.dart';

class ExpenseService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // إضافة مصروف جديد
  Future<int> addExpense(ExpenseModel expense) async {
    final db = await _dbHelper.database;
    
    // إضافة جدول expenses إذا لم يكن موجود
    await _ensureTableExists(db);
    
    return await db.insert('expenses', expense.toMap());
  }

  // الحصول على جميع المصروفات
  Future<List<ExpenseModel>> getAllExpenses() async {
    final db = await _dbHelper.database;
    
    // إضافة جدول expenses إذا لم يكن موجود
    await _ensureTableExists(db);
    
    final maps = await db.query(
      'expenses',
      orderBy: 'expense_date DESC',
    );
    
    return List.generate(maps.length, (i) {
      return ExpenseModel.fromMap(maps[i]);
    });
  }

  // الحصول على المصروفات حسب المدرسة
  Future<List<ExpenseModel>> getExpensesBySchool(int schoolId) async {
    final db = await _dbHelper.database;
    
    // إضافة جدول expenses إذا لم يكن موجود
    await _ensureTableExists(db);
    
    final maps = await db.query(
      'expenses',
      where: 'school_id = ?',
      whereArgs: [schoolId],
      orderBy: 'expense_date DESC',
    );
    
    return List.generate(maps.length, (i) {
      return ExpenseModel.fromMap(maps[i]);
    });
  }

  // تحديث مصروف
  Future<int> updateExpense(ExpenseModel expense) async {
    final db = await _dbHelper.database;
    
    // إضافة جدول expenses إذا لم يكن موجود
    await _ensureTableExists(db);
    
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // حذف مصروف
  Future<int> deleteExpense(int id) async {
    final db = await _dbHelper.database;
    
    // إضافة جدول expenses إذا لم يكن موجود
    await _ensureTableExists(db);
    
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // الحصول على إجمالي المصروفات لمدرسة معينة
  Future<double> getTotalExpensesBySchool(int schoolId) async {
    final db = await _dbHelper.database;
    
    // إضافة جدول expenses إذا لم يكن موجود
    await _ensureTableExists(db);
    
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE school_id = ?',
      [schoolId],
    );
    
    return (result.first['total'] as double?) ?? 0.0;
  }

  // الحصول على المصروفات حسب النوع
  Future<List<ExpenseModel>> getExpensesByType(
    int schoolId,
    String expenseType,
  ) async {
    final db = await _dbHelper.database;
    
    // إضافة جدول expenses إذا لم يكن موجود
    await _ensureTableExists(db);
    
    final maps = await db.query(
      'expenses',
      where: 'school_id = ? AND expense_type = ?',
      whereArgs: [schoolId, expenseType],
      orderBy: 'expense_date DESC',
    );
    
    return List.generate(maps.length, (i) {
      return ExpenseModel.fromMap(maps[i]);
    });
  }

  // الحصول على المصروفات خلال فترة زمنية
  Future<List<ExpenseModel>> getExpensesByDateRange(
    int schoolId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    
    // إضافة جدول expenses إذا لم يكن موجود
    await _ensureTableExists(db);
    
    final maps = await db.query(
      'expenses',
      where: 'school_id = ? AND expense_date BETWEEN ? AND ?',
      whereArgs: [
        schoolId,
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
      orderBy: 'expense_date DESC',
    );
    
    return List.generate(maps.length, (i) {
      return ExpenseModel.fromMap(maps[i]);
    });
  }

  // التأكد من وجود جدول expenses
  Future<void> _ensureTableExists(db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        school_id INTEGER NOT NULL,
        expense_type TEXT NOT NULL,
        amount DECIMAL(10,2) NOT NULL,
        expense_date DATE NOT NULL,
        description TEXT,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
      )
    ''');

    // إنشاء فهارس للبحث السريع
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_expenses_school_id ON expenses(school_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_expenses_type ON expenses(expense_type)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(expense_date)',
    );
  }
}
