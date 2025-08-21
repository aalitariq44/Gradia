
import 'package:fluent_ui/fluent_ui.dart';
import '../../models/school_model.dart';
import '../../services/school_service.dart';
import '../../utils/app_text_styles.dart';

class EditSchoolDialog extends StatefulWidget {
  final School school;
  final VoidCallback onSchoolUpdated;

  const EditSchoolDialog(
      {super.key, required this.school, required this.onSchoolUpdated});

  @override
  State<EditSchoolDialog> createState() => _EditSchoolDialogState();
}

class _EditSchoolDialogState extends State<EditSchoolDialog> {
  final _schoolService = SchoolService();
  final _nameArController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _principalNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameArController.text = widget.school.nameAr;
    _nameEnController.text = widget.school.nameEn ?? '';
    _addressController.text = widget.school.address ?? '';
    _phoneController.text = widget.school.phone ?? '';
    _principalNameController.text = widget.school.principalName ?? '';
  }

  Future<void> _updateSchool() async {
    if (_nameArController.text.isEmpty) {
      _showErrorDialog('يرجى إدخال اسم المدرسة بالعربية');
      return;
    }

    try {
      final updatedSchool = widget.school.copyWith(
        nameAr: _nameArController.text,
        nameEn: _nameEnController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        principalName: _principalNameController.text,
      );

      await _schoolService.updateSchool(updatedSchool);
      widget.onSchoolUpdated();
      Navigator.of(context).pop();
      _showSuccessMessage('تم تحديث بيانات المدرسة بنجاح');
    } catch (e) {
      _showErrorDialog('حدث خطأ أثناء تحديث المدرسة: $e');
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

  void _showSuccessMessage(String message) {
    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: const Text('نجاح'),
        content: Text(message),
        severity: InfoBarSeverity.success,
        onClose: close,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('تعديل بيانات المدرسة'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('اسم المدرسة (عربي) *', style: AppTextStyles.inputLabel),
              const SizedBox(height: 8),
              TextBox(
                controller: _nameArController,
                placeholder: 'أدخل اسم المدرسة بالعربية',
              ),
              const SizedBox(height: 16),
              Text(
                'اسم المدرسة (إنجليزي)',
                style: AppTextStyles.inputLabel,
              ),
              const SizedBox(height: 8),
              TextBox(
                controller: _nameEnController,
                placeholder: 'أدخل اسم المدرسة بالإنجليزية',
              ),
              const SizedBox(height: 16),
              Text('العنوان', style: AppTextStyles.inputLabel),
              const SizedBox(height: 8),
              TextBox(
                controller: _addressController,
                placeholder: 'أدخل عنوان المدرسة',
              ),
              const SizedBox(height: 16),
              Text('رقم الهاتف', style: AppTextStyles.inputLabel),
              const SizedBox(height: 8),
              TextBox(
                controller: _phoneController,
                placeholder: 'أدخل رقم الهاتف',
              ),
              const SizedBox(height: 16),
              Text('اسم المدير', style: AppTextStyles.inputLabel),
              const SizedBox(height: 8),
              TextBox(
                controller: _principalNameController,
                placeholder: 'أدخل اسم مدير المدرسة',
              ),
              const SizedBox(height: 16),
              Text('أنواع المدرسة (لا يمكن تعديلها)',
                  style: AppTextStyles.inputLabel),
              const SizedBox(height: 8),
              Text(
                widget.school.schoolTypesDisplay,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[100]),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Button(
          child: const Text('إلغاء'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        FilledButton(
          onPressed: _updateSchool,
          child: const Text('حفظ التعديلات'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _principalNameController.dispose();
    super.dispose();
  }
}
