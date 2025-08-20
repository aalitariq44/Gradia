import '../database/db_manager.dart';
import '../../models/expense_model.dart';

class ExpenseService {
  // Get all expenses with school names
  static Future<List<ExpenseModel>> getAllExpenses() async {
    final db = await DbManager.database;
    final result = await db.rawQuery('''
      SELECT e.*, s.name_ar as school_name
      FROM expenses e
      LEFT JOIN schools s ON e.school_id = s.id
      ORDER BY e.expense_date DESC, e.created_at DESC
    ''');
    return result.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  // Get expense by ID
  static Future<ExpenseModel?> getExpenseById(int id) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      '''
      SELECT e.*, s.name_ar as school_name
      FROM expenses e
      LEFT JOIN schools s ON e.school_id = s.id
      WHERE e.id = ?
    ''',
      [id],
    );

    if (result.isNotEmpty) {
      return ExpenseModel.fromMap(result.first);
    }
    return null;
  }

  // Get expenses by school ID
  static Future<List<ExpenseModel>> getExpensesBySchool(int schoolId) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      '''
      SELECT e.*, s.name_ar as school_name
      FROM expenses e
      LEFT JOIN schools s ON e.school_id = s.id
      WHERE e.school_id = ?
      ORDER BY e.expense_date DESC, e.created_at DESC
    ''',
      [schoolId],
    );
    return result.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  // Get expenses by date range
  static Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? schoolId,
  }) async {
    final db = await DbManager.database;
    String query = '''
      SELECT e.*, s.name_ar as school_name
      FROM expenses e
      LEFT JOIN schools s ON e.school_id = s.id
      WHERE e.expense_date BETWEEN ? AND ?
    ''';

    List<dynamic> params = [
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
    ];

    if (schoolId != null) {
      query += ' AND e.school_id = ?';
      params.add(schoolId);
    }

    query += ' ORDER BY e.expense_date DESC, e.created_at DESC';

    final result = await db.rawQuery(query, params);
    return result.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  // Get expenses by type
  static Future<List<ExpenseModel>> getExpensesByType(
    String expenseType,
  ) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      '''
      SELECT e.*, s.name_ar as school_name
      FROM expenses e
      LEFT JOIN schools s ON e.school_id = s.id
      WHERE e.expense_type = ?
      ORDER BY e.expense_date DESC, e.created_at DESC
    ''',
      [expenseType],
    );
    return result.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  // Advanced search for expenses
  static Future<List<ExpenseModel>> advancedSearchExpenses({
    String? searchQuery,
    int? schoolId,
    String? expenseType,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
  }) async {
    final db = await DbManager.database;

    String whereClause = 'WHERE 1=1';
    List<dynamic> params = [];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClause += ''' AND (
        e.description LIKE ? OR 
        e.notes LIKE ? OR 
        e.expense_type LIKE ?
      )''';
      final searchPattern = '%$searchQuery%';
      params.addAll([searchPattern, searchPattern, searchPattern]);
    }

    if (schoolId != null) {
      whereClause += ' AND e.school_id = ?';
      params.add(schoolId);
    }

    if (expenseType != null && expenseType.isNotEmpty) {
      whereClause += ' AND e.expense_type = ?';
      params.add(expenseType);
    }

    if (startDate != null) {
      whereClause += ' AND e.expense_date >= ?';
      params.add(startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      whereClause += ' AND e.expense_date <= ?';
      params.add(endDate.toIso8601String().split('T')[0]);
    }

    if (minAmount != null) {
      whereClause += ' AND e.amount >= ?';
      params.add(minAmount);
    }

    if (maxAmount != null) {
      whereClause += ' AND e.amount <= ?';
      params.add(maxAmount);
    }

    final query =
        '''
      SELECT e.*, s.name_ar as school_name
      FROM expenses e
      LEFT JOIN schools s ON e.school_id = s.id
      $whereClause
      ORDER BY e.expense_date DESC, e.created_at DESC
    ''';

    final result = await db.rawQuery(query, params);
    return result.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  // Create new expense
  static Future<int> createExpense(ExpenseModel expense) async {
    final db = await DbManager.database;
    return await db.insert('expenses', expense.toInsertMap());
  }

  // Update expense
  static Future<int> updateExpense(ExpenseModel expense) async {
    final db = await DbManager.database;
    return await db.update(
      'expenses',
      expense.toUpdateMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // Delete expense
  static Future<int> deleteExpense(int id) async {
    final db = await DbManager.database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // Delete all expenses for a school
  static Future<int> deleteExpensesBySchool(int schoolId) async {
    final db = await DbManager.database;
    return await db.delete(
      'expenses',
      where: 'school_id = ?',
      whereArgs: [schoolId],
    );
  }

  // Get expense statistics
  static Future<Map<String, dynamic>> getExpenseStatistics({
    int? schoolId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await DbManager.database;

    String whereClause = 'WHERE 1=1';
    List<dynamic> params = [];

    if (schoolId != null) {
      whereClause += ' AND school_id = ?';
      params.add(schoolId);
    }

    if (startDate != null) {
      whereClause += ' AND expense_date >= ?';
      params.add(startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      whereClause += ' AND expense_date <= ?';
      params.add(endDate.toIso8601String().split('T')[0]);
    }

    // Get total amount, count, average, min, max
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_count,
        COALESCE(SUM(amount), 0) as total_amount,
        COALESCE(AVG(amount), 0) as average_amount,
        COALESCE(MIN(amount), 0) as min_amount,
        COALESCE(MAX(amount), 0) as max_amount
      FROM expenses 
      $whereClause
    ''', params);

    // Get monthly amount (current month)
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    String monthlyWhereClause = 'WHERE expense_date >= ? AND expense_date <= ?';
    List<dynamic> monthlyParams = [
      monthStart.toIso8601String().split('T')[0],
      monthEnd.toIso8601String().split('T')[0],
    ];

    if (schoolId != null) {
      monthlyWhereClause += ' AND school_id = ?';
      monthlyParams.add(schoolId);
    }

    final monthlyResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as monthly_amount
      FROM expenses 
      $monthlyWhereClause
    ''', monthlyParams);

    // Get yearly amount (current year)
    final yearStart = DateTime(now.year, 1, 1);
    final yearEnd = DateTime(now.year, 12, 31);

    String yearlyWhereClause = 'WHERE expense_date >= ? AND expense_date <= ?';
    List<dynamic> yearlyParams = [
      yearStart.toIso8601String().split('T')[0],
      yearEnd.toIso8601String().split('T')[0],
    ];

    if (schoolId != null) {
      yearlyWhereClause += ' AND school_id = ?';
      yearlyParams.add(schoolId);
    }

    final yearlyResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as yearly_amount
      FROM expenses 
      $yearlyWhereClause
    ''', yearlyParams);

    // Get expenses by type
    final typeResult = await db.rawQuery('''
      SELECT 
        expense_type,
        COUNT(*) as count,
        COALESCE(SUM(amount), 0) as total_amount
      FROM expenses 
      $whereClause
      GROUP BY expense_type
      ORDER BY total_amount DESC
    ''', params);

    return {
      'totalCount': result.first['total_count'] ?? 0,
      'totalAmount': result.first['total_amount'] ?? 0.0,
      'averageAmount': result.first['average_amount'] ?? 0.0,
      'minAmount': result.first['min_amount'] ?? 0.0,
      'maxAmount': result.first['max_amount'] ?? 0.0,
      'monthlyAmount': monthlyResult.first['monthly_amount'] ?? 0.0,
      'yearlyAmount': yearlyResult.first['yearly_amount'] ?? 0.0,
      'expensesByType': typeResult,
    };
  }

  // Get monthly expense summary
  static Future<List<Map<String, dynamic>>> getMonthlyExpenseSummary({
    int? schoolId,
    int? year,
  }) async {
    final db = await DbManager.database;

    final targetYear = year ?? DateTime.now().year;
    String whereClause = "WHERE strftime('%Y', expense_date) = ?";
    List<dynamic> params = [targetYear.toString()];

    if (schoolId != null) {
      whereClause += ' AND school_id = ?';
      params.add(schoolId);
    }

    final result = await db.rawQuery('''
      SELECT 
        strftime('%m', expense_date) as month,
        strftime('%Y', expense_date) as year,
        COUNT(*) as count,
        COALESCE(SUM(amount), 0) as total_amount
      FROM expenses 
      $whereClause
      GROUP BY strftime('%Y-%m', expense_date)
      ORDER BY month
    ''', params);

    return result;
  }

  // Get top expenses by amount
  static Future<List<ExpenseModel>> getTopExpensesByAmount({
    int limit = 10,
    int? schoolId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await DbManager.database;

    String whereClause = 'WHERE 1=1';
    List<dynamic> params = [];

    if (schoolId != null) {
      whereClause += ' AND e.school_id = ?';
      params.add(schoolId);
    }

    if (startDate != null) {
      whereClause += ' AND e.expense_date >= ?';
      params.add(startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      whereClause += ' AND e.expense_date <= ?';
      params.add(endDate.toIso8601String().split('T')[0]);
    }

    final result = await db.rawQuery(
      '''
      SELECT e.*, s.name_ar as school_name
      FROM expenses e
      LEFT JOIN schools s ON e.school_id = s.id
      $whereClause
      ORDER BY e.amount DESC
      LIMIT ?
    ''',
      [...params, limit],
    );

    return result.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  // Check if expense exists
  static Future<bool> expenseExists(int id) async {
    final db = await DbManager.database;
    final result = await db.query('expenses', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty;
  }

  // Get total count of expenses
  static Future<int> getTotalExpensesCount({int? schoolId}) async {
    final db = await DbManager.database;

    String whereClause = '';
    List<dynamic> params = [];

    if (schoolId != null) {
      whereClause = 'WHERE school_id = ?';
      params.add(schoolId);
    }

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM expenses $whereClause
    ''', params);

    return result.first['count'] as int;
  }
}
