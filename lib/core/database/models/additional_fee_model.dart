class AdditionalFeeModel {
  final int? id;
  final int studentId;
  final String feeType;
  final double amount;
  final bool paid;
  final DateTime? paymentDate;
  final DateTime addedAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields for UI display
  final String? studentName;

  AdditionalFeeModel({
    this.id,
    required this.studentId,
    required this.feeType,
    required this.amount,
    this.paid = false,
    this.paymentDate,
    required this.addedAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.studentName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'fee_type': feeType,
      'amount': amount,
      'paid': paid ? 1 : 0,
      'payment_date': paymentDate?.toIso8601String().split('T')[0],
      'added_at': addedAt.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AdditionalFeeModel.fromMap(Map<String, dynamic> map) {
    return AdditionalFeeModel(
      id: map['id']?.toInt(),
      studentId: map['student_id']?.toInt() ?? 0,
      feeType: map['fee_type'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      paid: (map['paid'] ?? 0) == 1,
      paymentDate: map['payment_date'] != null
          ? DateTime.parse(map['payment_date'])
          : null,
      addedAt: DateTime.parse(map['added_at']),
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      studentName: map['student_name'],
    );
  }

  AdditionalFeeModel copyWith({
    int? id,
    int? studentId,
    String? feeType,
    double? amount,
    bool? paid,
    DateTime? paymentDate,
    DateTime? addedAt,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? studentName,
  }) {
    return AdditionalFeeModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      feeType: feeType ?? this.feeType,
      amount: amount ?? this.amount,
      paid: paid ?? this.paid,
      paymentDate: paymentDate ?? this.paymentDate,
      addedAt: addedAt ?? this.addedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      studentName: studentName ?? this.studentName,
    );
  }
}
