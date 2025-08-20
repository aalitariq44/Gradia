class Installment {
  final int? id;
  final int studentId;
  final double amount;
  final DateTime paymentDate;
  final String paymentTime;
  final String? notes;
  final DateTime createdAt;

  Installment({
    this.id,
    required this.studentId,
    required this.amount,
    required this.paymentDate,
    required this.paymentTime,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String().split(
        'T',
      )[0], // تاريخ بدون وقت
      'payment_time': paymentTime,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Installment.fromMap(Map<String, dynamic> map) {
    return Installment(
      id: map['id']?.toInt(),
      studentId: map['student_id']?.toInt() ?? 0,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: DateTime.parse(map['payment_date']),
      paymentTime: map['payment_time'] ?? '',
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Installment copyWith({
    int? id,
    int? studentId,
    double? amount,
    DateTime? paymentDate,
    String? paymentTime,
    String? notes,
    DateTime? createdAt,
  }) {
    return Installment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentTime: paymentTime ?? this.paymentTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Installment(id: $id, studentId: $studentId, amount: $amount, paymentDate: $paymentDate, paymentTime: $paymentTime, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Installment &&
        other.id == id &&
        other.studentId == studentId &&
        other.amount == amount &&
        other.paymentDate == paymentDate &&
        other.paymentTime == paymentTime &&
        other.notes == notes &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        studentId.hashCode ^
        amount.hashCode ^
        paymentDate.hashCode ^
        paymentTime.hashCode ^
        notes.hashCode ^
        createdAt.hashCode;
  }
}
