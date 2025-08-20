class AdditionalFee {
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

  AdditionalFee({
    this.id,
    required this.studentId,
    required this.feeType,
    required this.amount,
    this.paid = false,
    this.paymentDate,
    DateTime? addedAt,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : addedAt = addedAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'fee_type': feeType,
      'amount': amount,
      'paid': paid ? 1 : 0,
      'payment_date': paymentDate?.toIso8601String(),
      'added_at': addedAt.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AdditionalFee.fromMap(Map<String, dynamic> map) {
    return AdditionalFee(
      id: map['id'],
      studentId: map['student_id'],
      feeType: map['fee_type'],
      amount: (map['amount'] as num).toDouble(),
      paid: map['paid'] == 1,
      paymentDate: map['payment_date'] != null
          ? DateTime.parse(map['payment_date'])
          : null,
      addedAt: DateTime.parse(map['added_at']),
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  AdditionalFee copyWith({
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
  }) {
    return AdditionalFee(
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
    );
  }

  @override
  String toString() {
    return 'AdditionalFee{id: $id, studentId: $studentId, feeType: $feeType, amount: $amount, paid: $paid, paymentDate: $paymentDate, addedAt: $addedAt, notes: $notes}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdditionalFee &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          studentId == other.studentId &&
          feeType == other.feeType &&
          amount == other.amount;

  @override
  int get hashCode => id.hashCode ^ studentId.hashCode ^ feeType.hashCode ^ amount.hashCode;
}
