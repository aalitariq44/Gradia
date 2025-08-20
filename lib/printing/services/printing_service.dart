import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import '../models/print_config.dart';

/// خدمة الطباعة الرئيسية التي تدير جميع عمليات الطباعة في التطبيق
class PrintingService {
  static final PrintingService _instance = PrintingService._internal();
  factory PrintingService() => _instance;
  PrintingService._internal();

  // خط Cairo للنصوص العربية
  pw.Font? _arabicFont;

  /// تحميل خط Cairo
  Future<void> _loadArabicFont() async {
    if (_arabicFont == null) {
      try {
        final fontData = await rootBundle.load('fonts/Cairo-Regular.ttf');
        _arabicFont = pw.Font.ttf(fontData);
      } catch (e) {
        print('خطأ في تحميل الخط العربي: $e');
        // استخدام خط افتراضي في حالة فشل التحميل
      }
    }
  }

  /// طباعة جدول عام مع إعدادات قابلة للتخصيص
  Future<void> printTable({
    required List<Map<String, dynamic>> data,
    required PrintConfig config,
    PreviewOptions previewOptions = const PreviewOptions(),
  }) async {
    await _loadArabicFont();

    final pdf = pw.Document();

    // تحديد اتجاه الصفحة
    final pageFormat = config.orientation == 'landscape'
        ? PdfPageFormat.a4.landscape
        : PdfPageFormat.a4;

    // تصفية البيانات بناءً على الأعمدة المختارة
    final filteredData = _filterDataByColumns(data, config.columnsToShow);

    // إنشاء الصفحات
    final pages = _buildTablePages(filteredData, config);

    for (int i = 0; i < pages.length; i++) {
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          textDirection: pw.TextDirection.rtl,
          build: (pw.Context context) {
            return pw.Column(
              children: [
                // رأس الصفحة
                if (config.includeHeader)
                  _buildHeader(config, i + 1, pages.length),

                pw.SizedBox(height: 20),

                // محتوى الجدول
                pages[i],

                pw.Spacer(),

                // تذييل الصفحة
                if (config.includeFooter)
                  _buildFooter(config, i + 1, pages.length),
              ],
            );
          },
        ),
      );
    }

    // عرض المعاينة أو الطباعة مباشرة
    if (previewOptions.showPreview) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: config.title,
      );
    } else {
      // طباعة مباشرة باستخدام الطابعة الافتراضية
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: config.title,
      );
    }
  }

  /// تصفية البيانات بناءً على الأعمدة المختارة
  List<Map<String, dynamic>> _filterDataByColumns(
    List<Map<String, dynamic>> data,
    List<String> columnsToShow,
  ) {
    if (data.isEmpty || columnsToShow.isEmpty) {
      return data;
    }

    return data.map((row) {
      final filteredRow = <String, dynamic>{};
      for (final column in columnsToShow) {
        if (row.containsKey(column)) {
          filteredRow[column] = row[column];
        }
      }
      return filteredRow;
    }).toList();
  }

  /// بناء رأس الصفحة
  pw.Widget _buildHeader(PrintConfig config, int currentPage, int totalPages) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // العنوان الرئيسي
          pw.Center(
            child: pw.Text(
              config.title,
              style: pw.TextStyle(
                font: _arabicFont,
                fontSize: config.headerFontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          // العنوان الفرعي
          if (config.subtitle.isNotEmpty) ...[
            pw.SizedBox(height: 5),
            pw.Center(
              child: pw.Text(
                config.subtitle,
                style: pw.TextStyle(
                  font: _arabicFont,
                  fontSize: config.fontSize,
                ),
              ),
            ),
          ],

          pw.SizedBox(height: 10),

          // معلومات إضافية
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // التاريخ
              if (config.includeDate)
                pw.Text(
                  'تاريخ الطباعة: ${_formatDate(DateTime.now())}',
                  style: pw.TextStyle(
                    font: _arabicFont,
                    fontSize: config.fontSize - 2,
                  ),
                ),

              // رقم الصفحة
              if (config.includePageNumbers)
                pw.Text(
                  'صفحة $currentPage من $totalPages',
                  style: pw.TextStyle(
                    font: _arabicFont,
                    fontSize: config.fontSize - 2,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// بناء تذييل الصفحة
  pw.Widget _buildFooter(PrintConfig config, int currentPage, int totalPages) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'نظام إدارة مدارس Gradia',
            style: pw.TextStyle(
              font: _arabicFont,
              fontSize: config.fontSize - 2,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            'تم الطباعة في ${_formatDateTime(DateTime.now())}',
            style: pw.TextStyle(
              font: _arabicFont,
              fontSize: config.fontSize - 2,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء صفحات الجدول
  List<pw.Widget> _buildTablePages(
    List<Map<String, dynamic>> data,
    PrintConfig config,
  ) {
    if (data.isEmpty) {
      return [
        pw.Center(
          child: pw.Text(
            'لا توجد بيانات للطباعة',
            style: pw.TextStyle(
              font: _arabicFont,
              fontSize: config.fontSize + 2,
            ),
          ),
        ),
      ];
    }

    List<pw.Widget> pages = [];
    const int rowsPerPage = 25; // عدد الصفوف في كل صفحة

    for (int i = 0; i < data.length; i += rowsPerPage) {
      final pageData = data.skip(i).take(rowsPerPage).toList();
      pages.add(_buildTableWidget(pageData, config, i == 0));
    }

    return pages;
  }

  /// بناء جدول واحد
  pw.Widget _buildTableWidget(
    List<Map<String, dynamic>> data,
    PrintConfig config,
    bool includeHeaders,
  ) {
    // تحديد الأعمدة المراد عرضها
    final columns = config.columnsToShow.isNotEmpty
        ? config.columnsToShow
        : data.first.keys.toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      children: [
        // رأس الجدول
        if (includeHeaders)
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey200),
            children: columns.map((column) {
              final headerText = config.columnHeaders[column] ?? column;
              return pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  headerText,
                  style: pw.TextStyle(
                    font: _arabicFont,
                    fontSize: config.fontSize,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              );
            }).toList(),
          ),

        // صفوف البيانات
        ...data
            .map(
              (row) => pw.TableRow(
                children: columns.map((column) {
                  final cellValue = _formatCellValue(row[column]);
                  return pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      cellValue,
                      style: pw.TextStyle(
                        font: _arabicFont,
                        fontSize: config.fontSize,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
            )
            .toList(),
      ],
    );
  }

  /// تنسيق قيم الخلايا
  String _formatCellValue(dynamic value) {
    if (value == null) return '-';
    if (value is DateTime) return _formatDate(value);
    if (value is double) return value.toStringAsFixed(2);
    return value.toString();
  }

  /// تنسيق التاريخ
  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  /// تنسيق التاريخ والوقت
  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// طباعة سريعة بإعدادات افتراضية
  Future<void> quickPrint({
    required String title,
    required List<Map<String, dynamic>> data,
    String subtitle = '',
    bool showPreview = true,
  }) async {
    final config = PrintConfig(title: title, subtitle: subtitle);

    await printTable(
      data: data,
      config: config,
      previewOptions: PreviewOptions(showPreview: showPreview),
    );
  }

  /// إنشاء ملف PDF كبايتات
  Future<Uint8List> generatePdfBytes({
    required List<Map<String, dynamic>> data,
    required PrintConfig config,
  }) async {
    await _loadArabicFont();

    final pdf = pw.Document();

    // تحديد اتجاه الصفحة
    final pageFormat = config.orientation == 'landscape'
        ? PdfPageFormat.a4.landscape
        : PdfPageFormat.a4;

    // تصفية البيانات بناءً على الأعمدة المختارة
    final filteredData = _filterDataByColumns(data, config.columnsToShow);

    // إنشاء الصفحات
    final pages = _buildTablePages(filteredData, config);

    for (int i = 0; i < pages.length; i++) {
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          textDirection: pw.TextDirection.rtl,
          build: (pw.Context context) {
            return pw.Column(
              children: [
                // رأس الصفحة
                if (config.includeHeader)
                  _buildHeader(config, i + 1, pages.length),

                pw.SizedBox(height: 20),

                // محتوى الجدول
                pages[i],

                pw.Spacer(),

                // تذييل الصفحة
                if (config.includeFooter)
                  _buildFooter(config, i + 1, pages.length),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }
}
