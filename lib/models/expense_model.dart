class ExpenseModel {
  final int? id;
  final int schoolId;
  final String expenseType;
  final double amount;
  final DateTime expenseDate;
  final String? description;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Navigation properties
  final String? schoolName;

  const ExpenseModel({
    this.id,
    required this.schoolId,
    required this.expenseType,
    required this.amount,
    required this.expenseDate,
    this.description,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.schoolName,
  });

  // Convert from database map
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      schoolId: map['school_id'] as int,
      expenseType: map['expense_type'] as String,
      amount: (map['amount'] as num).toDouble(),
      expenseDate: DateTime.parse(map['expense_date'] as String),
      description: map['description'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      schoolName: map['school_name'] as String?,
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId,
      'expense_type': expenseType,
      'amount': amount,
      'expense_date': expenseDate.toIso8601String().split('T')[0],
      'description': description,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Convert to database map for insertion (without id)
  Map<String, dynamic> toInsertMap() {
    final map = toMap();
    map.remove('id');
    map['created_at'] = DateTime.now().toIso8601String();
    map['updated_at'] = DateTime.now().toIso8601String();
    return map;
  }

  // Convert to database map for update
  Map<String, dynamic> toUpdateMap() {
    final map = toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    return map;
  }

  // Create a copy with updated fields
  ExpenseModel copyWith({
    int? id,
    int? schoolId,
    String? expenseType,
    double? amount,
    DateTime? expenseDate,
    String? description,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? schoolName,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      expenseType: expenseType ?? this.expenseType,
      amount: amount ?? this.amount,
      expenseDate: expenseDate ?? this.expenseDate,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      schoolName: schoolName ?? this.schoolName,
    );
  }

  @override
  String toString() {
    return 'ExpenseModel(id: $id, schoolId: $schoolId, expenseType: $expenseType, '
           'amount: $amount, expenseDate: $expenseDate, description: $description, '
           'notes: $notes, schoolName: $schoolName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseModel &&
        other.id == id &&
        other.schoolId == schoolId &&
        other.expenseType == expenseType &&
        other.amount == amount &&
        other.expenseDate == expenseDate &&
        other.description == description &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      schoolId,
      expenseType,
      amount,
      expenseDate,
      description,
      notes,
    );
  }
}

// Constants for expense types
class ExpenseTypes {
  static const String salaries = 'رواتب';
  static const String utilities = 'خدمات ومرافق';
  static const String maintenance = 'صيانة';
  static const String supplies = 'مستلزمات';
  static const String transport = 'نقل ومواصلات';
  static const String equipment = 'معدات';
  static const String rent = 'إيجارات';
  static const String insurance = 'تأمينات';
  static const String marketing = 'تسويق وإعلان';
  static const String training = 'تدريب وتطوير';
  static const String legal = 'استشارات قانونية';
  static const String technology = 'تكنولوجيا';
  static const String other = 'أخرى';

  static const List<String> allTypes = [
    salaries,
    utilities,
    maintenance,
    supplies,
    transport,
    equipment,
    rent,
    insurance,
    marketing,
    training,
    legal,
    technology,
    other,
  ];
}
