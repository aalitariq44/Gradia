import '../utils/constants.dart';

class School {
  final int? id;
  final String nameAr;
  final String? nameEn;
  final String? logoPath;
  final String? address;
  final String? phone;
  final String? principalName;
  final List<String> schoolTypes; // ابتدائي، متوسطة، إعدادية
  final DateTime createdAt;
  final DateTime? updatedAt;

  School({
    this.id,
    required this.nameAr,
    this.nameEn,
    this.logoPath,
    this.address,
    this.phone,
    this.principalName,
    required this.schoolTypes,
    required this.createdAt,
    this.updatedAt,
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
      'school_types': schoolTypes.join(','), // حفظ الأنواع كنص مفصول بفواصل
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory School.fromMap(Map<String, dynamic> map) {
    return School(
      id: map['id']?.toInt(),
      nameAr: map['name_ar'] ?? '',
      nameEn: map['name_en'],
      logoPath: map['logo_path'],
      address: map['address'],
      phone: map['phone'],
      principalName: map['principal_name'],
      schoolTypes: map['school_types'] != null
          ? (map['school_types'] as String)
                .split(',')
                .where((s) => s.isNotEmpty)
                .toList()
          : [],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  School copyWith({
    int? id,
    String? nameAr,
    String? nameEn,
    String? logoPath,
    String? address,
    String? phone,
    String? principalName,
    List<String>? schoolTypes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return School(
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

  @override
  String toString() {
    return 'School(id: $id, nameAr: $nameAr, nameEn: $nameEn, logoPath: $logoPath, address: $address, phone: $phone, principalName: $principalName, schoolTypes: $schoolTypes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is School &&
        other.id == id &&
        other.nameAr == nameAr &&
        other.nameEn == nameEn &&
        other.logoPath == logoPath &&
        other.address == address &&
        other.phone == phone &&
        other.principalName == principalName &&
        _listEquals(other.schoolTypes, schoolTypes) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nameAr.hashCode ^
        nameEn.hashCode ^
        logoPath.hashCode ^
        address.hashCode ^
        phone.hashCode ^
        principalName.hashCode ^
        schoolTypes.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  // أنواع المدارس المتاحة
  static List<String> get availableSchoolTypes =>
      SchoolTypesConstants.schoolTypes;

  // للحصول على أنواع المدرسة كنص مقروء
  String get schoolTypesDisplay => schoolTypes.join(' - ');
}
