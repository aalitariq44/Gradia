class ExternalIncomeModel {
  final int? id;
  final int schoolId;
  final String title;
  final double amount;
  final String category;
  final String incomeType;
  final String? description;
  final DateTime incomeDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields for UI display
  final String? schoolName;

  ExternalIncomeModel({
    this.id,
    required this.schoolId,
    required this.title,
    required this.amount,
    required this.category,
    required this.incomeType,
    this.description,
    required this.incomeDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.schoolName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId,
      'title': title,
      'amount': amount,
      'category': category,
      'income_type': incomeType,
      'description': description,
      'income_date': incomeDate.toIso8601String().split('T')[0],
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ExternalIncomeModel.fromMap(Map<String, dynamic> map) {
    return ExternalIncomeModel(
      id: map['id']?.toInt(),
      schoolId: map['school_id']?.toInt() ?? 0,
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      incomeType: map['income_type'] ?? '',
      description: map['description'],
      incomeDate: DateTime.parse(map['income_date']),
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      schoolName: map['school_name'],
    );
  }

  ExternalIncomeModel copyWith({
    int? id,
    int? schoolId,
    String? title,
    double? amount,
    String? category,
    String? incomeType,
    String? description,
    DateTime? incomeDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? schoolName,
  }) {
    return ExternalIncomeModel(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      incomeType: incomeType ?? this.incomeType,
      description: description ?? this.description,
      incomeDate: incomeDate ?? this.incomeDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      schoolName: schoolName ?? this.schoolName,
    );
  }

  @override
  String toString() {
    return 'ExternalIncomeModel{id: $id, schoolId: $schoolId, title: $title, amount: $amount, category: $category, incomeType: $incomeType, incomeDate: $incomeDate}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExternalIncomeModel &&
        other.id == id &&
        other.schoolId == schoolId &&
        other.title == title &&
        other.amount == amount &&
        other.category == category &&
        other.incomeType == incomeType &&
        other.incomeDate == incomeDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        schoolId.hashCode ^
        title.hashCode ^
        amount.hashCode ^
        category.hashCode ^
        incomeType.hashCode ^
        incomeDate.hashCode;
  }
}
