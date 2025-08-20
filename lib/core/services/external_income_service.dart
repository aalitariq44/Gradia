import '../database/db_manager.dart';
import '../database/models/external_income_model.dart';

class ExternalIncomeService {
  // Get all external incomes with school names
  static Future<List<ExternalIncomeModel>> getAllExternalIncomes() async {
    final db = await DbManager.database;
    final result = await db.rawQuery('''
      SELECT ei.*, s.name as school_name
      FROM external_income ei
      LEFT JOIN schools s ON ei.school_id = s.id
      ORDER BY ei.income_date DESC, ei.created_at DESC
    ''');
    return result.map((map) => ExternalIncomeModel.fromMap(map)).toList();
  }

  // Get external income by ID
  static Future<ExternalIncomeModel?> getExternalIncomeById(int id) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      '''
      SELECT ei.*, s.name as school_name
      FROM external_income ei
      LEFT JOIN schools s ON ei.school_id = s.id
      WHERE ei.id = ?
    ''',
      [id],
    );

    if (result.isNotEmpty) {
      return ExternalIncomeModel.fromMap(result.first);
    }
    return null;
  }

  // Get external incomes by school ID
  static Future<List<ExternalIncomeModel>> getExternalIncomesBySchool(
    int schoolId,
  ) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      '''
      SELECT ei.*, s.name as school_name
      FROM external_income ei
      LEFT JOIN schools s ON ei.school_id = s.id
      WHERE ei.school_id = ?
      ORDER BY ei.income_date DESC, ei.created_at DESC
    ''',
      [schoolId],
    );
    return result.map((map) => ExternalIncomeModel.fromMap(map)).toList();
  }

  // Get external incomes by category
  static Future<List<ExternalIncomeModel>> getExternalIncomesByCategory(
    String category,
  ) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      '''
      SELECT ei.*, s.name as school_name
      FROM external_income ei
      LEFT JOIN schools s ON ei.school_id = s.id
      WHERE ei.category = ?
      ORDER BY ei.income_date DESC, ei.created_at DESC
    ''',
      [category],
    );
    return result.map((map) => ExternalIncomeModel.fromMap(map)).toList();
  }

  // Get external incomes by date range
  static Future<List<ExternalIncomeModel>> getExternalIncomesByDateRange(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      '''
      SELECT ei.*, s.name as school_name
      FROM external_income ei
      LEFT JOIN schools s ON ei.school_id = s.id
      WHERE ei.income_date >= ? AND ei.income_date <= ?
      ORDER BY ei.income_date DESC, ei.created_at DESC
    ''',
      [
        fromDate.toIso8601String().split('T')[0],
        toDate.toIso8601String().split('T')[0],
      ],
    );
    return result.map((map) => ExternalIncomeModel.fromMap(map)).toList();
  }

  // Search external incomes
  static Future<List<ExternalIncomeModel>> searchExternalIncomes(
    String query,
  ) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      '''
      SELECT ei.*, s.name as school_name
      FROM external_income ei
      LEFT JOIN schools s ON ei.school_id = s.id
      WHERE ei.title LIKE ? OR ei.description LIKE ? OR ei.notes LIKE ? 
            OR ei.category LIKE ? OR ei.income_type LIKE ? OR s.name LIKE ?
      ORDER BY ei.income_date DESC, ei.created_at DESC
    ''',
      ['%$query%', '%$query%', '%$query%', '%$query%', '%$query%', '%$query%'],
    );
    return result.map((map) => ExternalIncomeModel.fromMap(map)).toList();
  }

  // Advanced search with filters
  static Future<List<ExternalIncomeModel>> advancedSearchExternalIncomes({
    String? searchQuery,
    int? schoolId,
    String? category,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final db = await DbManager.database;

    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClause += '''
        AND (ei.title LIKE ? OR ei.description LIKE ? OR ei.notes LIKE ? 
             OR ei.category LIKE ? OR ei.income_type LIKE ? OR s.name LIKE ?)
      ''';
      whereArgs.addAll([
        '%$searchQuery%',
        '%$searchQuery%',
        '%$searchQuery%',
        '%$searchQuery%',
        '%$searchQuery%',
        '%$searchQuery%',
      ]);
    }

    if (schoolId != null) {
      whereClause += ' AND ei.school_id = ?';
      whereArgs.add(schoolId);
    }

    if (category != null && category.isNotEmpty) {
      whereClause += ' AND ei.category = ?';
      whereArgs.add(category);
    }

    if (fromDate != null) {
      whereClause += ' AND ei.income_date >= ?';
      whereArgs.add(fromDate.toIso8601String().split('T')[0]);
    }

    if (toDate != null) {
      whereClause += ' AND ei.income_date <= ?';
      whereArgs.add(toDate.toIso8601String().split('T')[0]);
    }

    final result = await db.rawQuery('''
      SELECT ei.*, s.name as school_name
      FROM external_income ei
      LEFT JOIN schools s ON ei.school_id = s.id
      WHERE $whereClause
      ORDER BY ei.income_date DESC, ei.created_at DESC
    ''', whereArgs);
    return result.map((map) => ExternalIncomeModel.fromMap(map)).toList();
  }

  // Create new external income
  static Future<int> createExternalIncome(
    ExternalIncomeModel externalIncome,
  ) async {
    final db = await DbManager.database;
    final now = DateTime.now();

    final incomeToInsert = externalIncome.copyWith(
      createdAt: now,
      updatedAt: now,
    );

    return await db.insert('external_income', incomeToInsert.toMap());
  }

  // Update external income
  static Future<int> updateExternalIncome(
    ExternalIncomeModel externalIncome,
  ) async {
    final db = await DbManager.database;
    final now = DateTime.now();

    final incomeToUpdate = externalIncome.copyWith(updatedAt: now);

    return await db.update(
      'external_income',
      incomeToUpdate.toMap(),
      where: 'id = ?',
      whereArgs: [externalIncome.id],
    );
  }

  // Delete external income
  static Future<int> deleteExternalIncome(int id) async {
    final db = await DbManager.database;
    return await db.delete('external_income', where: 'id = ?', whereArgs: [id]);
  }

  // Get total external income amount
  static Future<double> getTotalExternalIncomeAmount() async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM external_income',
    );
    return (result.first['total'] ?? 0.0) as double;
  }

  // Get total external income amount by school
  static Future<double> getTotalExternalIncomeAmountBySchool(
    int schoolId,
  ) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM external_income WHERE school_id = ?',
      [schoolId],
    );
    return (result.first['total'] ?? 0.0) as double;
  }

  // Get total external income amount by category
  static Future<double> getTotalExternalIncomeAmountByCategory(
    String category,
  ) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM external_income WHERE category = ?',
      [category],
    );
    return (result.first['total'] ?? 0.0) as double;
  }

  // Get monthly external income amount
  static Future<double> getMonthlyExternalIncomeAmount(
    int year,
    int month,
  ) async {
    final db = await DbManager.database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total FROM external_income 
      WHERE income_date >= ? AND income_date <= ?
      ''',
      [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
    );
    return (result.first['total'] ?? 0.0) as double;
  }

  // Get yearly external income amount
  static Future<double> getYearlyExternalIncomeAmount(int year) async {
    final db = await DbManager.database;
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31);

    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total FROM external_income 
      WHERE income_date >= ? AND income_date <= ?
      ''',
      [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
    );
    return (result.first['total'] ?? 0.0) as double;
  }

  // Get external income count
  static Future<int> getExternalIncomeCount() async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM external_income',
    );
    return result.first['count'] as int;
  }

  // Get external income count by school
  static Future<int> getExternalIncomeCountBySchool(int schoolId) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM external_income WHERE school_id = ?',
      [schoolId],
    );
    return result.first['count'] as int;
  }

  // Get categories list
  static Future<List<String>> getCategories() async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT category FROM external_income ORDER BY category',
    );
    return result.map((map) => map['category'] as String).toList();
  }

  // Get income types list
  static Future<List<String>> getIncomeTypes() async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT income_type FROM external_income ORDER BY income_type',
    );
    return result.map((map) => map['income_type'] as String).toList();
  }

  // Get largest external income amount
  static Future<double> getLargestExternalIncomeAmount() async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT MAX(amount) as max_amount FROM external_income',
    );
    return (result.first['max_amount'] ?? 0.0) as double;
  }

  // Get average external income amount
  static Future<double> getAverageExternalIncomeAmount() async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT AVG(amount) as avg_amount FROM external_income',
    );
    return (result.first['avg_amount'] ?? 0.0) as double;
  }

  // Get external income statistics
  static Future<Map<String, dynamic>> getExternalIncomeStatistics() async {
    final totalAmount = await getTotalExternalIncomeAmount();
    final totalCount = await getExternalIncomeCount();
    final largestAmount = await getLargestExternalIncomeAmount();
    final averageAmount = await getAverageExternalIncomeAmount();

    final now = DateTime.now();
    final monthlyAmount = await getMonthlyExternalIncomeAmount(
      now.year,
      now.month,
    );
    final yearlyAmount = await getYearlyExternalIncomeAmount(now.year);

    return {
      'totalAmount': totalAmount,
      'totalCount': totalCount,
      'largestAmount': largestAmount,
      'averageAmount': averageAmount,
      'monthlyAmount': monthlyAmount,
      'yearlyAmount': yearlyAmount,
    };
  }
}
