import '../database/db_manager.dart';
import '../database/models/additional_fee_model.dart';

class AdditionalFeeService {
  // Get all additional fees with student names
  static Future<List<AdditionalFeeModel>> getAllAdditionalFees() async {
    final db = await DbManager.database;
    final result = await db.rawQuery('''
      SELECT af.*, s.name as student_name
      FROM additional_fees af
      LEFT JOIN students s ON af.student_id = s.id
      ORDER BY af.added_at DESC
    ''');
    return result.map((map) => AdditionalFeeModel.fromMap(map)).toList();
  }

  // Get additional fee by ID
  static Future<AdditionalFeeModel?> getAdditionalFeeById(int id) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      '''
      SELECT af.*, s.name as student_name
      FROM additional_fees af
      LEFT JOIN students s ON af.student_id = s.id
      WHERE af.id = ?
    ''',
      [id],
    );

    if (result.isNotEmpty) {
      return AdditionalFeeModel.fromMap(result.first);
    }
    return null;
  }

  // Get additional fees by student ID
  static Future<List<AdditionalFeeModel>> getAdditionalFeesByStudent(
    int studentId,
  ) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      '''
      SELECT af.*, s.name as student_name
      FROM additional_fees af
      LEFT JOIN students s ON af.student_id = s.id
      WHERE af.student_id = ?
      ORDER BY af.added_at DESC
    ''',
      [studentId],
    );
    return result.map((map) => AdditionalFeeModel.fromMap(map)).toList();
  }

  // Get unpaid additional fees
  static Future<List<AdditionalFeeModel>> getUnpaidAdditionalFees() async {
    final db = await DbManager.database;
    final result = await db.rawQuery('''
      SELECT af.*, s.name as student_name
      FROM additional_fees af
      LEFT JOIN students s ON af.student_id = s.id
      WHERE af.paid = 0
      ORDER BY af.added_at DESC
    ''');
    return result.map((map) => AdditionalFeeModel.fromMap(map)).toList();
  }

  // Search additional fees
  static Future<List<AdditionalFeeModel>> searchAdditionalFees(
    String query,
  ) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      '''
      SELECT af.*, s.name as student_name
      FROM additional_fees af
      LEFT JOIN students s ON af.student_id = s.id
      WHERE s.name LIKE ? OR af.fee_type LIKE ? OR af.notes LIKE ?
      ORDER BY af.added_at DESC
    ''',
      ['%$query%', '%$query%', '%$query%'],
    );
    return result.map((map) => AdditionalFeeModel.fromMap(map)).toList();
  }

  // Create new additional fee
  static Future<int> createAdditionalFee(
    AdditionalFeeModel additionalFee,
  ) async {
    final db = await DbManager.database;
    final now = DateTime.now();

    final feeToInsert = additionalFee.copyWith(
      addedAt: now,
      createdAt: now,
      updatedAt: now,
    );

    return await db.insert('additional_fees', feeToInsert.toMap());
  }

  // Update additional fee
  static Future<int> updateAdditionalFee(
    AdditionalFeeModel additionalFee,
  ) async {
    final db = await DbManager.database;
    return await db.update(
      'additional_fees',
      additionalFee.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [additionalFee.id],
    );
  }

  // Mark additional fee as paid
  static Future<int> markAsPaid(int id, DateTime paymentDate) async {
    final db = await DbManager.database;
    return await db.update(
      'additional_fees',
      {
        'paid': 1,
        'payment_date': paymentDate.toIso8601String().split('T')[0],
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Mark additional fee as unpaid
  static Future<int> markAsUnpaid(int id) async {
    final db = await DbManager.database;
    return await db.update(
      'additional_fees',
      {
        'paid': 0,
        'payment_date': null,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete additional fee
  static Future<int> deleteAdditionalFee(int id) async {
    final db = await DbManager.database;
    return await db.delete('additional_fees', where: 'id = ?', whereArgs: [id]);
  }

  // Get total additional fees amount
  static Future<double> getTotalAdditionalFees() async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM additional_fees',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get total paid additional fees amount
  static Future<double> getTotalPaidAdditionalFees() async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM additional_fees WHERE paid = 1',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get total unpaid additional fees amount
  static Future<double> getTotalUnpaidAdditionalFees() async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM additional_fees WHERE paid = 0',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get additional fees count
  static Future<int> getAdditionalFeesCount() async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM additional_fees',
    );
    return result.first['count'] as int;
  }

  // Get unpaid additional fees count
  static Future<int> getUnpaidAdditionalFeesCount() async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM additional_fees WHERE paid = 0',
    );
    return result.first['count'] as int;
  }

  // Get additional fees by type
  static Future<List<AdditionalFeeModel>> getAdditionalFeesByType(
    String feeType,
  ) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      '''
      SELECT af.*, s.name as student_name
      FROM additional_fees af
      LEFT JOIN students s ON af.student_id = s.id
      WHERE af.fee_type = ?
      ORDER BY af.added_at DESC
    ''',
      [feeType],
    );
    return result.map((map) => AdditionalFeeModel.fromMap(map)).toList();
  }

  // Get total additional fees for a student
  static Future<double> getTotalAdditionalFeesByStudent(int studentId) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM additional_fees WHERE student_id = ?',
      [studentId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get paid additional fees for a student
  static Future<double> getPaidAdditionalFeesByStudent(int studentId) async {
    final db = await DbManager.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM additional_fees WHERE student_id = ? AND paid = 1',
      [studentId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
