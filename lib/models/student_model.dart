class Student {
  final int? id;
  final String name;
  final String? nationalIdNumber;
  final int schoolId;
  final String grade;
  final String section;
  final String? academicYear;
  final String gender;
  final String? phone;
  final double totalFee;
  final DateTime startDate;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Student({
    this.id,
    required this.name,
    this.nationalIdNumber,
    required this.schoolId,
    required this.grade,
    required this.section,
    this.academicYear,
    required this.gender,
    this.phone,
    required this.totalFee,
    required this.startDate,
    this.status = 'نشط',
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'national_id_number': nationalIdNumber,
      'school_id': schoolId,
      'grade': grade,
      'section': section,
      'academic_year': academicYear,
      'gender': gender,
      'phone': phone,
      'total_fee': totalFee,
      'start_date': startDate.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      nationalIdNumber: map['national_id_number'],
      schoolId: map['school_id']?.toInt() ?? 0,
      grade: map['grade'] ?? '',
      section: map['section'] ?? '',
      academicYear: map['academic_year'],
      gender: map['gender'] ?? '',
      phone: map['phone'],
      totalFee: (map['total_fee'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.parse(map['start_date']),
      status: map['status'] ?? 'نشط',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  Student copyWith({
    int? id,
    String? name,
    String? nationalIdNumber,
    int? schoolId,
    String? grade,
    String? section,
    String? academicYear,
    String? gender,
    String? phone,
    double? totalFee,
    DateTime? startDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      nationalIdNumber: nationalIdNumber ?? this.nationalIdNumber,
      schoolId: schoolId ?? this.schoolId,
      grade: grade ?? this.grade,
      section: section ?? this.section,
      academicYear: academicYear ?? this.academicYear,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      totalFee: totalFee ?? this.totalFee,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Student(id: $id, name: $name, nationalIdNumber: $nationalIdNumber, schoolId: $schoolId, grade: $grade, section: $section, academicYear: $academicYear, gender: $gender, phone: $phone, totalFee: $totalFee, startDate: $startDate, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Student &&
        other.id == id &&
        other.name == name &&
        other.nationalIdNumber == nationalIdNumber &&
        other.schoolId == schoolId &&
        other.grade == grade &&
        other.section == section &&
        other.academicYear == academicYear &&
        other.gender == gender &&
        other.phone == phone &&
        other.totalFee == totalFee &&
        other.startDate == startDate &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        nationalIdNumber.hashCode ^
        schoolId.hashCode ^
        grade.hashCode ^
        section.hashCode ^
        academicYear.hashCode ^
        gender.hashCode ^
        phone.hashCode ^
        totalFee.hashCode ^
        startDate.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
