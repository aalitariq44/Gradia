class Teacher {
  final int? id;
  final String name;
  final int schoolId;
  final int classHours;
  final double monthlySalary;
  final String? phone;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Teacher({
    this.id,
    required this.name,
    required this.schoolId,
    required this.classHours,
    required this.monthlySalary,
    this.phone,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'school_id': schoolId,
      'class_hours': classHours,
      'monthly_salary': monthlySalary,
      'phone': phone,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'],
      name: map['name'] ?? '',
      schoolId: map['school_id'] ?? 0,
      classHours: map['class_hours'] ?? 0,
      monthlySalary: (map['monthly_salary'] as num?)?.toDouble() ?? 0.0,
      phone: map['phone'],
      notes: map['notes'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
    );
  }

  Teacher copyWith({
    int? id,
    String? name,
    int? schoolId,
    int? classHours,
    double? monthlySalary,
    String? phone,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Teacher(
      id: id ?? this.id,
      name: name ?? this.name,
      schoolId: schoolId ?? this.schoolId,
      classHours: classHours ?? this.classHours,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Teacher{id: $id, name: $name, schoolId: $schoolId, classHours: $classHours, monthlySalary: $monthlySalary, phone: $phone, notes: $notes}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Teacher &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          schoolId == other.schoolId;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ schoolId.hashCode;
}
