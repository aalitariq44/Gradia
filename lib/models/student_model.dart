class Student {
  final int? id;
  final int schoolId;
  final String studentId;
  final String name;
  final String grade;
  final String classSection;
  final String parentName;
  final String parentPhone;
  final String address;
  final DateTime enrollmentDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Student({
    this.id,
    required this.schoolId,
    required this.studentId,
    required this.name,
    this.grade = '',
    this.classSection = '',
    this.parentName = '',
    this.parentPhone = '',
    this.address = '',
    required this.enrollmentDate,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId,
      'student_id': studentId,
      'name': name,
      'grade': grade,
      'class_section': classSection,
      'parent_name': parentName,
      'parent_phone': parentPhone,
      'address': address,
      'enrollment_date': enrollmentDate.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id']?.toInt(),
      schoolId: map['school_id']?.toInt() ?? 0,
      studentId: map['student_id'] ?? '',
      name: map['name'] ?? '',
      grade: map['grade'] ?? '',
      classSection: map['class_section'] ?? '',
      parentName: map['parent_name'] ?? '',
      parentPhone: map['parent_phone'] ?? '',
      address: map['address'] ?? '',
      enrollmentDate: DateTime.parse(map['enrollment_date']),
      isActive: (map['is_active'] ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  Student copyWith({
    int? id,
    int? schoolId,
    String? studentId,
    String? name,
    String? grade,
    String? classSection,
    String? parentName,
    String? parentPhone,
    String? address,
    DateTime? enrollmentDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      classSection: classSection ?? this.classSection,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      address: address ?? this.address,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Student(id: $id, schoolId: $schoolId, studentId: $studentId, name: $name, grade: $grade, classSection: $classSection, parentName: $parentName, parentPhone: $parentPhone, address: $address, enrollmentDate: $enrollmentDate, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Student &&
        other.id == id &&
        other.schoolId == schoolId &&
        other.studentId == studentId &&
        other.name == name &&
        other.grade == grade &&
        other.classSection == classSection &&
        other.parentName == parentName &&
        other.parentPhone == parentPhone &&
        other.address == address &&
        other.enrollmentDate == enrollmentDate &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        schoolId.hashCode ^
        studentId.hashCode ^
        name.hashCode ^
        grade.hashCode ^
        classSection.hashCode ^
        parentName.hashCode ^
        parentPhone.hashCode ^
        address.hashCode ^
        enrollmentDate.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
