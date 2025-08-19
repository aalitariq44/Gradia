import 'package:fluent_ui/fluent_ui.dart';
import '../../../core/database/models/school_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';

class AddSchoolDialog extends StatefulWidget {
  const AddSchoolDialog({Key? key}) : super(key: key);

  @override
  State<AddSchoolDialog> createState() => _AddSchoolDialogState();
}

class _AddSchoolDialogState extends State<AddSchoolDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameArController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _principalNameController = TextEditingController();

  String _selectedSchoolType = SchoolTypesConstants.elementary;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _principalNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final now = DateTime.now();
      final school = SchoolModel(
        nameAr: _nameArController.text.trim(),
        nameEn: _nameEnController.text.trim().isEmpty
            ? null
            : _nameEnController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        principalName: _principalNameController.text.trim().isEmpty
            ? null
            : _principalNameController.text.trim(),
        schoolTypes: _selectedSchoolType,
        createdAt: now,
        updatedAt: now,
      );

      Navigator.of(context).pop(school);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('إضافة مدرسة جديدة'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  label: 'اسم المدرسة (بالعربية) *',
                  placeholder: 'أدخل اسم المدرسة بالعربية',
                  controller: _nameArController,
                  validator: (value) =>
                      Helpers.validateRequired(value, 'اسم المدرسة'),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'اسم المدرسة (بالإنجليزية)',
                  placeholder: 'أدخل اسم المدرسة بالإنجليزية',
                  controller: _nameEnController,
                ),
                const SizedBox(height: 16),

                CustomDropdown<String>(
                  label: 'نوع المدرسة *',
                  value: _selectedSchoolType,
                  items: SchoolTypesConstants.schoolTypes,
                  itemBuilder: (type) => type,
                  onChanged: (value) {
                    setState(() {
                      _selectedSchoolType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'اسم المدير',
                  placeholder: 'أدخل اسم مدير المدرسة',
                  controller: _principalNameController,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'رقم الهاتف',
                  placeholder: 'أدخل رقم هاتف المدرسة',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: Helpers.validatePhone,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'العنوان',
                  placeholder: 'أدخل عنوان المدرسة',
                  controller: _addressController,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Button(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        CustomButton(text: 'إضافة', onPressed: _submit, isLoading: _isLoading),
      ],
    );
  }
}
