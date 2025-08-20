import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart' as flutter_widgets show TextDirection;
import '../models/print_config.dart';

/// نافذة معاينة إعدادات الطباعة
class PrintPreviewDialog extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final PrintConfig initialConfig;
  final Function(PrintConfig config) onPrint;
  final VoidCallback? onCancel;

  const PrintPreviewDialog({
    Key? key,
    required this.title,
    required this.data,
    required this.initialConfig,
    required this.onPrint,
    this.onCancel,
  }) : super(key: key);

  @override
  State<PrintPreviewDialog> createState() => _PrintPreviewDialogState();
}

class _PrintPreviewDialogState extends State<PrintPreviewDialog> {
  late PrintConfig _config;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: flutter_widgets.TextDirection.rtl,
      child: ContentDialog(
        title: Text('معاينة الطباعة - ${widget.title}'),
        content: SizedBox(
          width: 800,
          height: 600,
          child: Row(
            children: [
              // لوحة الإعدادات
              Expanded(
                flex: 1,
                child: _buildSettingsPanel(),
              ),
              
              Container(
                width: 1,
                height: double.infinity,
                color: Colors.grey[200],
              ),
              
              // معاينة المحتوى
              Expanded(
                flex: 2,
                child: _buildPreviewPanel(),
              ),
            ],
          ),
        ),
        actions: [
          Button(
            child: const Text('إلغاء'),
            onPressed: widget.onCancel ?? () => Navigator.pop(context),
          ),
          FilledButton(
            onPressed: _isLoading ? null : _handlePrint,
            child: _isLoading
                ? const SizedBox(width: 16, height: 16, child: ProgressRing())
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(FluentIcons.print),
                      SizedBox(width: 4),
                      Text('طباعة'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // إعدادات العنوان
            const Text(
              'إعدادات العنوان',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            InfoLabel(
              label: 'العنوان الرئيسي',
              child: TextBox(
                controller: TextEditingController(text: _config.title),
                onChanged: (value) {
                  setState(() {
                    _config = _config.copyWith(title: value);
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            
            InfoLabel(
              label: 'العنوان الفرعي',
              child: TextBox(
                controller: TextEditingController(text: _config.subtitle),
                onChanged: (value) {
                  setState(() {
                    _config = _config.copyWith(subtitle: value);
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // إعدادات التخطيط
            const Text(
              'إعدادات التخطيط',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            InfoLabel(
              label: 'اتجاه الصفحة',
              child: ComboBox<String>(
                value: _config.orientation,
                items: const [
                  ComboBoxItem(value: 'portrait', child: Text('عمودي')),
                  ComboBoxItem(value: 'landscape', child: Text('أفقي')),
                ],
                onChanged: (value) {
                  setState(() {
                    _config = _config.copyWith(orientation: value);
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            
            InfoLabel(
              label: 'حجم الخط',
              child: NumberBox<double>(
                value: _config.fontSize,
                min: 6.0,
                max: 20.0,
                mode: SpinButtonPlacementMode.inline,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _config = _config.copyWith(fontSize: value);
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            
            InfoLabel(
              label: 'حجم خط العنوان',
              child: NumberBox<double>(
                value: _config.headerFontSize,
                min: 10.0,
                max: 24.0,
                mode: SpinButtonPlacementMode.inline,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _config = _config.copyWith(headerFontSize: value);
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // إعدادات المحتوى
            const Text(
              'إعدادات المحتوى',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            Checkbox(
              checked: _config.includeHeader,
              onChanged: (value) {
                setState(() {
                  _config = _config.copyWith(includeHeader: value ?? false);
                });
              },
              content: const Text('إظهار رأس الصفحة'),
            ),
            
            Checkbox(
              checked: _config.includeFooter,
              onChanged: (value) {
                setState(() {
                  _config = _config.copyWith(includeFooter: value ?? false);
                });
              },
              content: const Text('إظهار تذييل الصفحة'),
            ),
            
            Checkbox(
              checked: _config.includeDate,
              onChanged: (value) {
                setState(() {
                  _config = _config.copyWith(includeDate: value ?? false);
                });
              },
              content: const Text('إظهار التاريخ'),
            ),
            
            Checkbox(
              checked: _config.includePageNumbers,
              onChanged: (value) {
                setState(() {
                  _config = _config.copyWith(includePageNumbers: value ?? false);
                });
              },
              content: const Text('إظهار أرقام الصفحات'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'معاينة المحتوى',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[100]),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معاينة رأس الصفحة
                    if (_config.includeHeader) _buildHeaderPreview(),
                    
                    const SizedBox(height: 20),
                    
                    // معاينة البيانات
                    _buildDataPreview(),
                    
                    const SizedBox(height: 20),
                    
                    // معاينة التذييل
                    if (_config.includeFooter) _buildFooterPreview(),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // معلومات إضافية
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: FluentTheme.of(context).micaBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('إجمالي السجلات: ${widget.data.length}'),
                const SizedBox(height: 4),
                Text('اتجاه الصفحة: ${_config.orientation == 'portrait' ? 'عمودي' : 'أفقي'}'),
                const SizedBox(height: 4),
                Text('حجم الخط: ${_config.fontSize.toStringAsFixed(1)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]),
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey[50],
      ),
      child: Column(
        children: [
          Text(
            _config.title,
            style: TextStyle(
              fontSize: _config.headerFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (_config.subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _config.subtitle,
              style: TextStyle(fontSize: _config.fontSize),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_config.includeDate)
                Text(
                  'تاريخ الطباعة: ${_formatDate(DateTime.now())}',
                  style: TextStyle(fontSize: _config.fontSize - 2),
                ),
              if (_config.includePageNumbers)
                Text(
                  'صفحة 1 من 1',
                  style: TextStyle(fontSize: _config.fontSize - 2),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataPreview() {
    if (widget.data.isEmpty) {
      return const Center(
        child: Text('لا توجد بيانات للمعاينة'),
      );
    }

    // عرض أول 5 صفوف فقط للمعاينة
    final previewData = widget.data.take(5).toList();
    final columns = _config.columnsToShow.isNotEmpty 
        ? _config.columnsToShow 
        : widget.data.first.keys.toList();

    return Table(
      border: TableBorder.all(color: Colors.grey[300]),
      children: [
        // رأس الجدول
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[200]),
          children: columns.map((column) {
            final headerText = _config.columnHeaders[column] ?? column;
            return Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                headerText,
                style: TextStyle(
                  fontSize: _config.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
        ),
        
        // صفوف البيانات
        ...previewData.map((row) => TableRow(
          children: columns.map((column) {
            final cellValue = _formatCellValue(row[column]);
            return Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                cellValue,
                style: TextStyle(fontSize: _config.fontSize),
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
        )).toList(),
      ],
    );
  }

  Widget _buildFooterPreview() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300])),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'نظام إدارة مدارس Gradia',
            style: TextStyle(
              fontSize: _config.fontSize - 2,
              color: Colors.grey[600],
            ),
          ),
          Text(
            'تم الطباعة في ${_formatDateTime(DateTime.now())}',
            style: TextStyle(
              fontSize: _config.fontSize - 2,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePrint() async {
    setState(() => _isLoading = true);
    
    try {
      await widget.onPrint(_config);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorDialog('خطأ في الطباعة: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          FilledButton(
            child: const Text('موافق'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  String _formatCellValue(dynamic value) {
    if (value == null) return '-';
    if (value is DateTime) return _formatDate(value);
    if (value is double) return value.toStringAsFixed(2);
    return value.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
