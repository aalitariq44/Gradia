import '../models/installment_model.dart';
import 'database_helper.dart';

class InstallmentService {
  static final InstallmentService _instance = InstallmentService._internal();
  factory InstallmentService() => _instance;
  InstallmentService._internal();

  DatabaseHelper get _databaseHelper => DatabaseHelper();

  /// إضافة قسط جديد
  Future<int> insertInstallment(Installment installment) async {
    final db = await _databaseHelper.database;
    try {
      return await db.insert('installments', installment.toMap());
    } catch (e) {
      throw Exception('خطأ في إضافة القسط: $e');
    }
  }

  /// الحصول على جميع أقساط طالب معين
  Future<List<Installment>> getStudentInstallments(int studentId) async {
    final db = await _databaseHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'installments',
        where: 'student_id = ?',
        whereArgs: [studentId],
        orderBy: 'payment_date DESC, payment_time DESC',
      );

      return List.generate(maps.length, (i) {
        return Installment.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('خطأ في جلب أقساط الطالب: $e');
    }
  }

  /// الحصول على جميع الأقساط
  Future<List<Installment>> getAllInstallments() async {
    final db = await _databaseHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'installments',
        orderBy: 'payment_date DESC, payment_time DESC',
      );

      return List.generate(maps.length, (i) {
        return Installment.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('خطأ في جلب جميع الأقساط: $e');
    }
  }

  /// تحديث قسط
  Future<int> updateInstallment(Installment installment) async {
    final db = await _databaseHelper.database;
    try {
      return await db.update(
        'installments',
        installment.toMap(),
        where: 'id = ?',
        whereArgs: [installment.id],
      );
    } catch (e) {
      throw Exception('خطأ في تحديث القسط: $e');
    }
  }

  /// حذف قسط
  Future<int> deleteInstallment(int id) async {
    final db = await _databaseHelper.database;
    try {
      return await db.delete('installments', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('خطأ في حذف القسط: $e');
    }
  }

  /// حساب المبلغ المدفوع لطالب معين
  Future<double> getTotalPaidAmount(int studentId) async {
    final db = await _databaseHelper.database;
    try {
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM installments WHERE student_id = ?',
        [studentId],
      );

      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw Exception('خطأ في حساب المبلغ المدفوع: $e');
    }
  }

  /// حساب عدد الدفعات لطالب معين
  Future<int> getInstallmentCount(int studentId) async {
    final db = await _databaseHelper.database;
    try {
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM installments WHERE student_id = ?',
        [studentId],
      );

      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      throw Exception('خطأ في حساب عدد الدفعات: $e');
    }
  }

  /// الحصول على آخر قسط لطالب معين
  Future<Installment?> getLastInstallment(int studentId) async {
    final db = await _databaseHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'installments',
        where: 'student_id = ?',
        whereArgs: [studentId],
        orderBy: 'payment_date DESC, payment_time DESC',
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return Installment.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('خطأ في جلب آخر قسط: $e');
    }
  }

  /// البحث في الأقساط حسب التاريخ
  Future<List<Installment>> getInstallmentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseHelper.database;
    try {
      final String startDateStr = startDate.toIso8601String().split('T')[0];
      final String endDateStr = endDate.toIso8601String().split('T')[0];

      final List<Map<String, dynamic>> maps = await db.query(
        'installments',
        where: 'payment_date BETWEEN ? AND ?',
        whereArgs: [startDateStr, endDateStr],
        orderBy: 'payment_date DESC, payment_time DESC',
      );

      return List.generate(maps.length, (i) {
        return Installment.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('خطأ في البحث بالتاريخ: $e');
    }
  }

  /// الحصول على إحصائيات الأقساط لطالب معين
  Future<Map<String, dynamic>> getStudentPaymentSummary(int studentId) async {
    try {
      final totalPaid = await getTotalPaidAmount(studentId);
      final installmentCount = await getInstallmentCount(studentId);
      final lastInstallment = await getLastInstallment(studentId);

      return {
        'totalPaid': totalPaid,
        'installmentCount': installmentCount,
        'lastPaymentDate': lastInstallment?.paymentDate,
        'lastPaymentAmount': lastInstallment?.amount ?? 0.0,
      };
    } catch (e) {
      throw Exception('خطأ في جلب ملخص المدفوعات: $e');
    }
  }
}
