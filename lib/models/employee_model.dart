class Employee {
  final int? id;
  final String name;
  final int schoolId;
  final String jobType;
  final double monthlySalary;
  final String? phone;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Employee({
    this.id,
    required this.name,
    required this.schoolId,
    required this.jobType,
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
      'job_type': jobType,
      'monthly_salary': monthlySalary,
      'phone': phone,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'] ?? '',
      schoolId: map['school_id'] ?? 0,
      jobType: map['job_type'] ?? '',
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

  Employee copyWith({
    int? id,
    String? name,
    int? schoolId,
    String? jobType,
    double? monthlySalary,
    String? phone,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      schoolId: schoolId ?? this.schoolId,
      jobType: jobType ?? this.jobType,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Employee{id: $id, name: $name, schoolId: $schoolId, jobType: $jobType, monthlySalary: $monthlySalary, phone: $phone, notes: $notes}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Employee &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          schoolId == other.schoolId;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ schoolId.hashCode;
}
