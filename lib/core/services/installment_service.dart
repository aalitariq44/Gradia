import '../database/db_manager.dart';
import '../database/models/installment_model.dart';

class InstallmentService {
  // Get all installments with student names
  static Future<List<InstallmentModel>> getAllInstallments() async {
    final db = await DbManager.database;
    final result = await db.rawQuery('''
      SELECT i.*, s.name as student_name
      FROM installments i
      LEFT JOIN students s ON i.student_id = s.id
      ORDER BY i.payment_date DESC, i.payment_time DESC
    ''');
    return result.map((map) => InstallmentModel.fromMap(map)).toList();
  }

  // Get installment by ID
  static Future<InstallmentModel?> getInstallmentById(int id) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      '''
      SELECT i.*, s.name as student_name
      FROM installments i
      LEFT JOIN students s ON i.student_id = s.id
      WHERE i.id = ?
    ''',
      [id],
    );

    if (result.isNotEmpty) {
      return InstallmentModel.fromMap(result.first);
    }
    return null;
  }

  // Get installments by student ID
  static Future<List<InstallmentModel>> getInstallmentsByStudent(
    int studentId,
  ) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      '''
      SELECT i.*, s.name as student_name
      FROM installments i
      LEFT JOIN students s ON i.student_id = s.id
      WHERE i.student_id = ?
      ORDER BY i.payment_date DESC, i.payment_time DESC
    ''',
      [studentId],
    );
    return result.map((map) => InstallmentModel.fromMap(map)).toList();
  }

  // Search installments
  static Future<List<InstallmentModel>> searchInstallments(String query) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      '''
      SELECT i.*, s.name as student_name
      FROM installments i
      LEFT JOIN students s ON i.student_id = s.id
      WHERE s.name LIKE ? OR i.notes LIKE ?
      ORDER BY i.payment_date DESC, i.payment_time DESC
    ''',
      ['%$query%', '%$query%'],
    );
    return result.map((map) => InstallmentModel.fromMap(map)).toList();
  }

  // Create new installment
  static Future<int> createInstallment(InstallmentModel installment) async {
    final db = await DbManager.database;
    final now = DateTime.now();

    final installmentToInsert = installment.copyWith(createdAt: now);

    return await db.insert('installments', installmentToInsert.toMap());
  }

  // Update installment
  static Future<int> updateInstallment(InstallmentModel installment) async {
    final db = await DbManager.database;
    return await db.update(
      'installments',
      installment.toMap(),
      where: 'id = ?',
      whereArgs: [installment.id],
    );
  }

  // Delete installment
  static Future<int> deleteInstallment(int id) async {
    final db = await DbManager.database;
    return await db.delete('installments', where: 'id = ?', whereArgs: [id]);
  }

  // Get total installments amount
  static Future<double> getTotalInstallments() async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM installments',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get installments count
  static Future<int> getInstallmentsCount() async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM installments',
    );
    return result.first['count'] as int;
  }

  // Get installments by date range
  static Future<List<InstallmentModel>> getInstallmentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      '''
      SELECT i.*, s.name as student_name
      FROM installments i
      LEFT JOIN students s ON i.student_id = s.id
      WHERE i.payment_date BETWEEN ? AND ?
      ORDER BY i.payment_date DESC, i.payment_time DESC
    ''',
      [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
    );
    return result.map((map) => InstallmentModel.fromMap(map)).toList();
  }

  // Get total amount paid by a student
  static Future<double> getTotalPaidByStudent(int studentId) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM installments WHERE student_id = ?',
      [studentId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get monthly installments report
  static Future<Map<String, double>> getMonthlyInstallmentsReport(
    int year,
  ) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      '''
      SELECT 
        strftime('%m', payment_date) as month,
        SUM(amount) as total
      FROM installments 
      WHERE strftime('%Y', payment_date) = ?
      GROUP BY strftime('%m', payment_date)
      ORDER BY month
    ''',
      [year.toString()],
    );

    Map<String, double> monthlyReport = {};
    for (var row in result) {
      final month = row['month'] as String;
      final total = (row['total'] as num?)?.toDouble() ?? 0.0;
      monthlyReport[month] = total;
    }
    return monthlyReport;
  }
}
