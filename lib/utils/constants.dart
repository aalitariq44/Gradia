// Database constants
class DatabaseConstants {
  static const String databaseName = 'gradia_school_management.db';
  static const int databaseVersion = 1;
}

// Gender options
class GenderConstants {
  static const String male = 'ذكر';
  static const String female = 'أنثى';

  static List<String> get genderOptions => [male, female];
}

// Student status options
class StudentStatusConstants {
  static const String active = 'نشط';
  static const String inactive = 'غير نشط';
  static const String graduated = 'متخرج';
  static const String transferred = 'محول';

  static List<String> get statusOptions => [
    active,
    inactive,
    graduated,
    transferred,
  ];
}

// School types
class SchoolTypesConstants {
  static const String elementary = 'ابتدائي';
  static const String middle = 'متوسطة';
  static const String preparatory = 'إعدادية';

  static List<String> get schoolTypes => [elementary, middle, preparatory];
}

// Grade levels
class GradeLevelsConstants {
  static const List<String> elementaryGrades = [
    'الأول الابتدائي',
    'الثاني الابتدائي',
    'الثالث الابتدائي',
    'الرابع الابتدائي',
    'الخامس الابتدائي',
    'السادس الابتدائي',
  ];

  static const List<String> middleGrades = [
    'الأول المتوسط',
    'الثاني المتوسط',
    'الثالث المتوسط',
  ];

  static const List<String> highGrades = [
    'الأول الثانوي',
    'الثاني الثانوي',
    'الثالث الثانوي',
  ];

  static List<String> get allGrades => [
    ...elementaryGrades,
    ...middleGrades,
    ...highGrades,
  ];
}

// Section names
class SectionConstants {
  static const List<String> sections = [
    'أ',
    'ب',
    'ج',
    'د',
    'هـ',
    'و',
    'ز',
    'ح',
    'ط',
    'ي',
  ];
}

// Additional fee types
class AdditionalFeeTypesConstants {
  static const String transport = 'رسوم النقل';
  static const String books = 'رسوم الكتب';
  static const String uniform = 'رسوم الزي المدرسي';
  static const String activities = 'رسوم الأنشطة';
  static const String examination = 'رسوم الامتحانات';
  static const String late = 'رسوم التأخير';
  static const String other = 'رسوم أخرى';

  static List<String> get feeTypes => [
    transport,
    books,
    uniform,
    activities,
    examination,
    late,
    other,
  ];
}

// Date formats
class DateFormats {
  static const String displayDate = 'dd/MM/yyyy';
  static const String displayDateTime = 'dd/MM/yyyy HH:mm';
  static const String displayTime = 'HH:mm';
  static const String dbDate = 'yyyy-MM-dd';
  static const String dbDateTime = 'yyyy-MM-dd HH:mm:ss';
}

// Currency
class CurrencyConstants {
  static const String currency = 'ر.س';
  static const String currencySymbol = 'SAR';
}

// Validation constants
class ValidationConstants {
  static const int minPasswordLength = 6;
  static const int maxNameLength = 100;
  static const int maxPhoneLength = 15;
  static const int maxAddressLength = 255;
  static const int maxNotesLength = 500;
}

// Academic years
class AcademicYearConstants {
  static List<String> generateAcademicYears() {
    final currentYear = DateTime.now().year;
    final years = <String>[];

    for (int i = currentYear - 5; i <= currentYear + 5; i++) {
      years.add('$i/${i + 1}');
    }

    return years;
  }

  static String getCurrentAcademicYear() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    // If it's before September, use previous year as start
    if (month < 9) {
      return '${year - 1}/$year';
    } else {
      return '$year/${year + 1}';
    }
  }
}

// Navigation constants
class NavigationConstants {
  static const String schools = 'schools';
  static const String students = 'students';
  static const String installments = 'installments';
  static const String additionalFees = 'additional_fees';
  static const String reports = 'reports';
  static const String settings = 'settings';
}

// Limits
class LimitsConstants {
  static const int maxSearchResults = 100;
  static const int itemsPerPage = 50;
  static const double maxFileSize = 5 * 1024 * 1024; // 5MB
}

// File extensions
class FileExtensionsConstants {
  static const List<String> imageExtensions = ['.jpg', '.jpeg', '.png', '.bmp'];
  static const List<String> documentExtensions = ['.pdf', '.doc', '.docx'];
  static const List<String> excelExtensions = ['.xls', '.xlsx'];
}
