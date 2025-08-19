class SchoolModel {
  final int? id;
  final String nameAr;
  final String? nameEn;
  final String? logoPath;
  final String? address;
  final String? phone;
  final String? principalName;
  final String schoolTypes;
  final DateTime createdAt;
  final DateTime updatedAt;

  SchoolModel({
    this.id,
    required this.nameAr,
    this.nameEn,
    this.logoPath,
    this.address,
    this.phone,
    this.principalName,
    required this.schoolTypes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'logo_path': logoPath,
      'address': address,
      'phone': phone,
      'principal_name': principalName,
      'school_types': schoolTypes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SchoolModel.fromMap(Map<String, dynamic> map) {
    return SchoolModel(
      id: map['id']?.toInt(),
      nameAr: map['name_ar'] ?? '',
      nameEn: map['name_en'],
      logoPath: map['logo_path'],
      address: map['address'],
      phone: map['phone'],
      principalName: map['principal_name'],
      schoolTypes: map['school_types'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  SchoolModel copyWith({
    int? id,
    String? nameAr,
    String? nameEn,
    String? logoPath,
    String? address,
    String? phone,
    String? principalName,
    String? schoolTypes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SchoolModel(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      logoPath: logoPath ?? this.logoPath,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      principalName: principalName ?? this.principalName,
      schoolTypes: schoolTypes ?? this.schoolTypes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
