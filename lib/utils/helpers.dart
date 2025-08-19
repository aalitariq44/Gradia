import 'package:intl/intl.dart';
import 'constants.dart';

class Helpers {
  // Date formatting helpers
  static String formatDate(DateTime date) {
    return DateFormat(DateFormats.displayDate).format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat(DateFormats.displayDateTime).format(dateTime);
  }

  static String formatTime(DateTime time) {
    return DateFormat(DateFormats.displayTime).format(time);
  }

  static String formatDbDate(DateTime date) {
    return DateFormat(DateFormats.dbDate).format(date);
  }

  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Currency formatting
  static String formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'ar');
    return '${formatter.format(amount)} ${CurrencyConstants.currency}';
  }

  static String formatCurrencyCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}م ${CurrencyConstants.currency}';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}ألف ${CurrencyConstants.currency}';
    } else {
      return formatCurrency(amount);
    }
  }

  // Number formatting
  static String formatNumber(num number) {
    final formatter = NumberFormat('#,##0', 'ar');
    return formatter.format(number);
  }

  // Validation helpers
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    // Saudi phone number validation
    return RegExp(r'^(05|009665|9665|\+9665)[0-9]{8}$').hasMatch(phone);
  }

  static bool isValidNationalId(String nationalId) {
    // Saudi national ID validation (10 digits starting with 1 or 2)
    return RegExp(r'^[12][0-9]{9}$').hasMatch(nationalId);
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!isValidEmail(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }
    if (!isValidPhone(value)) {
      return 'رقم الهاتف غير صحيح';
    }
    return null;
  }

  static String? validateNationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // National ID is optional
    }
    if (!isValidNationalId(value)) {
      return 'رقم الهوية غير صحيح';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < ValidationConstants.minPasswordLength) {
      return 'كلمة المرور يجب أن تكون على الأقل ${ValidationConstants.minPasswordLength} أحرف';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'المبلغ مطلوب';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'المبلغ يجب أن يكون رقم موجب';
    }
    return null;
  }

  // String helpers
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String removeArabicDiacritics(String text) {
    // Remove Arabic diacritics for better search
    return text.replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0671]'), '');
  }

  static String normalizeArabicText(String text) {
    return removeArabicDiacritics(text.trim().toLowerCase());
  }

  // Search helpers
  static bool searchMatch(String text, String query) {
    final normalizedText = normalizeArabicText(text);
    final normalizedQuery = normalizeArabicText(query);
    return normalizedText.contains(normalizedQuery);
  }

  // Color helpers
  static String getStatusColor(String status) {
    switch (status) {
      case StudentStatusConstants.active:
        return 'success';
      case StudentStatusConstants.inactive:
        return 'warning';
      case StudentStatusConstants.graduated:
        return 'info';
      case StudentStatusConstants.transferred:
        return 'secondary';
      default:
        return 'primary';
    }
  }

  // File helpers
  static bool isImageFile(String fileName) {
    final extension = fileName.toLowerCase().substring(
      fileName.lastIndexOf('.'),
    );
    return FileExtensionsConstants.imageExtensions.contains(extension);
  }

  static bool isDocumentFile(String fileName) {
    final extension = fileName.toLowerCase().substring(
      fileName.lastIndexOf('.'),
    );
    return FileExtensionsConstants.documentExtensions.contains(extension);
  }

  static String getFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Math helpers
  static double percentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  static double calculateRemainingAmount(double totalFee, double paidAmount) {
    return totalFee - paidAmount;
  }

  static double calculatePaymentPercentage(double paidAmount, double totalFee) {
    return percentage(paidAmount, totalFee);
  }

  // Date helpers
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  // Export helpers
  static Map<String, dynamic> prepareForExport<T>(
    List<T> items,
    Map<String, dynamic> Function(T) mapper,
  ) {
    return {
      'data': items.map(mapper).toList(),
      'exportDate': DateTime.now().toIso8601String(),
      'count': items.length,
    };
  }

  // Error handling
  static String getErrorMessage(dynamic error) {
    if (error.toString().contains('UNIQUE constraint failed')) {
      return 'هذا السجل موجود مسبقاً';
    } else if (error.toString().contains('FOREIGN KEY constraint failed')) {
      return 'لا يمكن حذف هذا السجل لأنه مرتبط بسجلات أخرى';
    } else if (error.toString().contains('database is locked')) {
      return 'قاعدة البيانات مشغولة، يرجى المحاولة مرة أخرى';
    } else {
      return 'حدث خطأ غير متوقع: ${error.toString()}';
    }
  }
}
