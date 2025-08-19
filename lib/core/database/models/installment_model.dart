class InstallmentModel {
  final int? id;
  final int studentId;
  final double amount;
  final DateTime paymentDate;
  final String paymentTime;
  final String? notes;
  final DateTime createdAt;

  // Additional fields for UI display
  final String? studentName;

  InstallmentModel({
    this.id,
    required this.studentId,
    required this.amount,
    required this.paymentDate,
    required this.paymentTime,
    this.notes,
    required this.createdAt,
    this.studentName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String().split('T')[0],
      'payment_time': paymentTime,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory InstallmentModel.fromMap(Map<String, dynamic> map) {
    return InstallmentModel(
      id: map['id']?.toInt(),
      studentId: map['student_id']?.toInt() ?? 0,
      amount: (map['amount'] ?? 0.0).toDouble(),
      paymentDate: DateTime.parse(map['payment_date']),
      paymentTime: map['payment_time'] ?? '',
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      studentName: map['student_name'],
    );
  }

  InstallmentModel copyWith({
    int? id,
    int? studentId,
    double? amount,
    DateTime? paymentDate,
    String? paymentTime,
    String? notes,
    DateTime? createdAt,
    String? studentName,
  }) {
    return InstallmentModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentTime: paymentTime ?? this.paymentTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      studentName: studentName ?? this.studentName,
    );
  }
}
