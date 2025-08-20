/// نموذج إعدادات الطباعة
class PrintConfig {
  final String title;
  final String subtitle;
  final bool includeHeader;
  final bool includeFooter;
  final bool includeDate;
  final bool includePageNumbers;
  final double fontSize;
  final double headerFontSize;
  final String orientation; // 'portrait' or 'landscape'
  final List<String> columnsToShow;
  final Map<String, String> columnHeaders;

  const PrintConfig({
    required this.title,
    this.subtitle = '',
    this.includeHeader = true,
    this.includeFooter = true,
    this.includeDate = true,
    this.includePageNumbers = true,
    this.fontSize = 10.0,
    this.headerFontSize = 14.0,
    this.orientation = 'portrait',
    this.columnsToShow = const [],
    this.columnHeaders = const {},
  });

  PrintConfig copyWith({
    String? title,
    String? subtitle,
    bool? includeHeader,
    bool? includeFooter,
    bool? includeDate,
    bool? includePageNumbers,
    double? fontSize,
    double? headerFontSize,
    String? orientation,
    List<String>? columnsToShow,
    Map<String, String>? columnHeaders,
  }) {
    return PrintConfig(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      includeHeader: includeHeader ?? this.includeHeader,
      includeFooter: includeFooter ?? this.includeFooter,
      includeDate: includeDate ?? this.includeDate,
      includePageNumbers: includePageNumbers ?? this.includePageNumbers,
      fontSize: fontSize ?? this.fontSize,
      headerFontSize: headerFontSize ?? this.headerFontSize,
      orientation: orientation ?? this.orientation,
      columnsToShow: columnsToShow ?? this.columnsToShow,
      columnHeaders: columnHeaders ?? this.columnHeaders,
    );
  }
}

/// نموذج خيارات المعاينة
class PreviewOptions {
  final bool showPreview;
  final bool allowEdit;
  final bool showPrintButton;
  final bool showSaveButton;

  const PreviewOptions({
    this.showPreview = true,
    this.allowEdit = true,
    this.showPrintButton = true,
    this.showSaveButton = false,
  });
}
