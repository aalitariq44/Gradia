import 'package:fluent_ui/fluent_ui.dart';
import '../models/school_model.dart';
import '../services/school_service.dart';

class SchoolsPage extends StatefulWidget {
  const SchoolsPage({Key? key}) : super(key: key);

  @override
  State<SchoolsPage> createState() => _SchoolsPageState();
}

class _SchoolsPageState extends State<SchoolsPage> {
  final SchoolService _schoolService = SchoolService();
  List<School> _schools = [];
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  Future<void> _loadSchools() async {
    setState(() => _isLoading = true);
    try {
      final schools = await _schoolService.getAllSchools();
      setState(() => _schools = schools);
    } catch (e) {
      if (mounted) {
        _showErrorDialog('خطأ في تحميل المدارس: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addSchool() async {
    if (_nameController.text.isEmpty) {
      _showErrorDialog('يرجى إدخال اسم المدرسة');
      return;
    }

    try {
      final school = School(
        name: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        createdAt: DateTime.now(),
      );

      await _schoolService.insertSchool(school);
      _clearForm();
      _loadSchools();
      Navigator.of(context).pop();
      _showSuccessMessage('تم إضافة المدرسة بنجاح');
    } catch (e) {
      _showErrorDialog('خطأ في إضافة المدرسة: $e');
    }
  }

  Future<void> _deleteSchool(int id) async {
    try {
      await _schoolService.deleteSchool(id);
      _loadSchools();
      _showSuccessMessage('تم حذف المدرسة بنجاح');
    } catch (e) {
      _showErrorDialog('خطأ في حذف المدرسة: $e');
    }
  }

  void _clearForm() {
    _nameController.clear();
    _addressController.clear();
    _phoneController.clear();
    _emailController.clear();
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
        title: const Text('نجح'),
        content: Text(message),
        severity: InfoBarSeverity.success,
        onClose: close,
      ),
    );
  }

  void _showAddSchoolDialog() {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('إضافة مدرسة جديدة'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('اسم المدرسة *'),
              const SizedBox(height: 8),
              TextBox(
                controller: _nameController,
                placeholder: 'أدخل اسم المدرسة',
              ),
              const SizedBox(height: 16),
              const Text('العنوان'),
              const SizedBox(height: 8),
              TextBox(
                controller: _addressController,
                placeholder: 'أدخل عنوان المدرسة',
              ),
              const SizedBox(height: 16),
              const Text('الهاتف'),
              const SizedBox(height: 8),
              TextBox(
                controller: _phoneController,
                placeholder: 'أدخل رقم الهاتف',
              ),
              const SizedBox(height: 16),
              const Text('البريد الإلكتروني'),
              const SizedBox(height: 8),
              TextBox(
                controller: _emailController,
                placeholder: 'أدخل البريد الإلكتروني',
              ),
            ],
          ),
        ),
        actions: [
          Button(
            child: const Text('إلغاء'),
            onPressed: () {
              _clearForm();
              Navigator.pop(context);
            },
          ),
          FilledButton(child: const Text('إضافة'), onPressed: _addSchool),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('إدارة المدارس'),
        commandBar: CommandBar(
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.add),
              label: const Text('إضافة مدرسة'),
              onPressed: _showAddSchoolDialog,
            ),
            CommandBarButton(
              icon: const Icon(FluentIcons.refresh),
              label: const Text('تحديث'),
              onPressed: _loadSchools,
            ),
          ],
        ),
      ),
      content: _isLoading
          ? const Center(child: ProgressRing())
          : _schools.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FluentIcons.education,
                    size: 64,
                    color: Color(0xFF0078D4),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد مدارس مسجلة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'انقر على "إضافة مدرسة" لبدء إضافة المدارس',
                    style: TextStyle(fontSize: 14, color: Color(0xFF605E5C)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _schools.length,
              itemBuilder: (context, index) {
                final school = _schools[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0078D4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        FluentIcons.education,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      school.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (school.address.isNotEmpty)
                          Text('العنوان: ${school.address}'),
                        if (school.phone.isNotEmpty)
                          Text('الهاتف: ${school.phone}'),
                        if (school.email.isNotEmpty)
                          Text('البريد: ${school.email}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(FluentIcons.edit),
                          onPressed: () {
                            // TODO: Implement edit functionality
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            FluentIcons.delete,
                            color: Colors.red.normal,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => ContentDialog(
                                title: const Text('تأكيد الحذف'),
                                content: Text(
                                  'هل أنت متأكد من حذف مدرسة "${school.name}"؟',
                                ),
                                actions: [
                                  Button(
                                    child: const Text('إلغاء'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  FilledButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                        Colors.red,
                                      ),
                                    ),
                                    child: const Text('حذف'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteSchool(school.id!);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
