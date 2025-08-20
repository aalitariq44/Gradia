import '../models/additional_fee_model.dart';
import 'database_helper.dart';

class AdditionalFeeService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// إدراج رسم إضافي جديد
  Future<int> insertAdditionalFee(AdditionalFee fee) async {
    final db = await _dbHelper.database;
    return await db.insert('additional_fees', fee.toMap());
  }

  /// تحديث رسم إضافي موجود
  Future<int> updateAdditionalFee(AdditionalFee fee) async {
    final db = await _dbHelper.database;
    final updatedFee = fee.copyWith(updatedAt: DateTime.now());
    return await db.update(
      'additional_fees',
      updatedFee.toMap(),
      where: 'id = ?',
      whereArgs: [fee.id],
    );
  }

  /// حذف رسم إضافي
  Future<int> deleteAdditionalFee(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'additional_fees',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// الحصول على رسم إضافي بالمعرف
  Future<AdditionalFee?> getAdditionalFeeById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'additional_fees',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return AdditionalFee.fromMap(maps.first);
    }
    return null;
  }

  /// الحصول على جميع الرسوم الإضافية لطالب
  Future<List<AdditionalFee>> getStudentAdditionalFees(int studentId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'additional_fees',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'added_at DESC',
    );

    return List.generate(maps.length, (i) {
      return AdditionalFee.fromMap(maps[i]);
    });
  }

  /// الحصول على الرسوم المدفوعة للطالب
  Future<List<AdditionalFee>> getPaidFees(int studentId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'additional_fees',
      where: 'student_id = ? AND paid = 1',
      whereArgs: [studentId],
      orderBy: 'payment_date DESC',
    );

    return List.generate(maps.length, (i) {
      return AdditionalFee.fromMap(maps[i]);
    });
  }

  /// الحصول على الرسوم غير المدفوعة للطالب
  Future<List<AdditionalFee>> getUnpaidFees(int studentId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'additional_fees',
      where: 'student_id = ? AND paid = 0',
      whereArgs: [studentId],
      orderBy: 'added_at DESC',
    );

    return List.generate(maps.length, (i) {
      return AdditionalFee.fromMap(maps[i]);
    });
  }

  /// حساب إجمالي الرسوم الإضافية للطالب
  Future<double> getTotalFeesAmount(int studentId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM additional_fees WHERE student_id = ?',
      [studentId],
    );

    return (result.first['total'] as double?) ?? 0.0;
  }

  /// حساب إجمالي المبلغ المدفوع من الرسوم الإضافية
  Future<double> getTotalPaidAmount(int studentId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM additional_fees WHERE student_id = ? AND paid = 1',
      [studentId],
    );

    return (result.first['total'] as double?) ?? 0.0;
  }

  /// حساب إجمالي المبلغ غير المدفوع من الرسوم الإضافية
  Future<double> getTotalUnpaidAmount(int studentId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM additional_fees WHERE student_id = ? AND paid = 0',
      [studentId],
    );

    return (result.first['total'] as double?) ?? 0.0;
  }

  /// عدد الرسوم الإضافية للطالب
  Future<int> getFeesCount(int studentId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM additional_fees WHERE student_id = ?',
      [studentId],
    );

    return (result.first['count'] as int?) ?? 0;
  }

  /// تسديد رسم إضافي
  Future<int> payFee(int feeId, DateTime paymentDate) async {
    final db = await _dbHelper.database;
    return await db.update(
      'additional_fees',
      {
        'paid': 1,
        'payment_date': paymentDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [feeId],
    );
  }

  /// إلغاء تسديد رسم إضافي
  Future<int> unpayFee(int feeId) async {
    final db = await _dbHelper.database;
    return await db.update(
      'additional_fees',
      {
        'paid': 0,
        'payment_date': null,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [feeId],
    );
  }

  /// البحث في الرسوم الإضافية
  Future<List<AdditionalFee>> searchAdditionalFees(
    int studentId,
    String query,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'additional_fees',
      where: '''
        student_id = ? AND 
        (fee_type LIKE ? OR notes LIKE ?)
      ''',
      whereArgs: [studentId, '%$query%', '%$query%'],
      orderBy: 'added_at DESC',
    );

    return List.generate(maps.length, (i) {
      return AdditionalFee.fromMap(maps[i]);
    });
  }

  /// الحصول على الرسوم الإضافية مع تصفية
  Future<List<AdditionalFee>> getFilteredFees(
    int studentId, {
    bool? paid,
    String? feeType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final db = await _dbHelper.database;
    
    String whereClause = 'student_id = ?';
    List<dynamic> whereArgs = [studentId];

    if (paid != null) {
      whereClause += ' AND paid = ?';
      whereArgs.add(paid ? 1 : 0);
    }

    if (feeType != null && feeType.isNotEmpty) {
      whereClause += ' AND fee_type = ?';
      whereArgs.add(feeType);
    }

    if (fromDate != null) {
      whereClause += ' AND added_at >= ?';
      whereArgs.add(fromDate.toIso8601String());
    }

    if (toDate != null) {
      whereClause += ' AND added_at <= ?';
      whereArgs.add(toDate.toIso8601String());
    }

    final maps = await db.query(
      'additional_fees',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'added_at DESC',
    );

    return List.generate(maps.length, (i) {
      return AdditionalFee.fromMap(maps[i]);
    });
  }

  /// الحصول على أنواع الرسوم المستخدمة
  Future<List<String>> getUsedFeeTypes() async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT fee_type FROM additional_fees ORDER BY fee_type',
    );

    return maps.map((map) => map['fee_type'] as String).toList();
  }

  /// حذف جميع الرسوم الإضافية لطالب
  Future<int> deleteAllStudentFees(int studentId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'additional_fees',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
  }
}
