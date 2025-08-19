class StudentModel {
  final int? id;
  final String name;
  final String? nationalIdNumber;
  final int schoolId;
  final String grade;
  final String section;
  final String? academicYear;
  final String gender;
  final String? phone;
  final String? guardianName;
  final String? guardianPhone;
  final double totalFee;
  final DateTime startDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields for UI display
  final String? schoolName;

  StudentModel({
    this.id,
    required this.name,
    this.nationalIdNumber,
    required this.schoolId,
    required this.grade,
    required this.section,
    this.academicYear,
    required this.gender,
    this.phone,
    this.guardianName,
    this.guardianPhone,
    required this.totalFee,
    required this.startDate,
    this.status = 'نشط',
    required this.createdAt,
    required this.updatedAt,
    this.schoolName,
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
      'guardian_name': guardianName,
      'guardian_phone': guardianPhone,
      'total_fee': totalFee,
      'start_date': startDate.toIso8601String().split('T')[0],
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      nationalIdNumber: map['national_id_number'],
      schoolId: map['school_id']?.toInt() ?? 0,
      grade: map['grade'] ?? '',
      section: map['section'] ?? '',
      academicYear: map['academic_year'],
      gender: map['gender'] ?? '',
      phone: map['phone'],
      guardianName: map['guardian_name'],
      guardianPhone: map['guardian_phone'],
      totalFee: (map['total_fee'] ?? 0.0).toDouble(),
      startDate: DateTime.parse(map['start_date']),
      status: map['status'] ?? 'نشط',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      schoolName: map['school_name'],
    );
  }

  StudentModel copyWith({
    int? id,
    String? name,
    String? nationalIdNumber,
    int? schoolId,
    String? grade,
    String? section,
    String? academicYear,
    String? gender,
    String? phone,
    String? guardianName,
    String? guardianPhone,
    double? totalFee,
    DateTime? startDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? schoolName,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nationalIdNumber: nationalIdNumber ?? this.nationalIdNumber,
      schoolId: schoolId ?? this.schoolId,
      grade: grade ?? this.grade,
      section: section ?? this.section,
      academicYear: academicYear ?? this.academicYear,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      guardianName: guardianName ?? this.guardianName,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      totalFee: totalFee ?? this.totalFee,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      schoolName: schoolName ?? this.schoolName,
    );
  }
}
