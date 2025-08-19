import 'package:fluent_ui/fluent_ui.dart';
import '../models/school_model.dart';
import '../services/school_service.dart';
import '../generated/app_localizations.dart';

class SchoolsPage extends StatefulWidget {
  const SchoolsPage({Key? key}) : super(key: key);

  @override
  State<SchoolsPage> createState() => _SchoolsPageState();
}

class _SchoolsPageState extends State<SchoolsPage> {
  final SchoolService _schoolService = SchoolService();
  List<School> _schools = [];
  bool _isLoading = false;
  final TextEditingController _nameArController = TextEditingController();
  final TextEditingController _nameEnController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _principalNameController =
      TextEditingController();
  List<String> _selectedSchoolTypes = [];

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
        final localizations = AppLocalizations.of(context)!;
        _showErrorDialog('${localizations.errorLoadingSchools}: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addSchool() async {
    final localizations = AppLocalizations.of(context)!;

    if (_nameArController.text.isEmpty) {
      _showErrorDialog('يرجى إدخال اسم المدرسة بالعربية');
      return;
    }

    if (_selectedSchoolTypes.isEmpty) {
      _showErrorDialog('يرجى اختيار نوع المدرسة على الأقل');
      return;
    }

    try {
      final school = School(
        nameAr: _nameArController.text,
        nameEn: _nameEnController.text.isEmpty ? null : _nameEnController.text,
        address: _addressController.text.isEmpty
            ? null
            : _addressController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        principalName: _principalNameController.text.isEmpty
            ? null
            : _principalNameController.text,
        schoolTypes: _selectedSchoolTypes,
        createdAt: DateTime.now(),
      );

      await _schoolService.insertSchool(school);
      _clearForm();
      _loadSchools();
      Navigator.of(context).pop();
      _showSuccessMessage(localizations.schoolAdded);
    } catch (e) {
      _showErrorDialog('${localizations.errorAddingSchool}: $e');
    }
  }

  Future<void> _deleteSchool(int id) async {
    final localizations = AppLocalizations.of(context)!;

    try {
      await _schoolService.deleteSchool(id);
      _loadSchools();
      _showSuccessMessage(localizations.schoolDeleted);
    } catch (e) {
      _showErrorDialog('${localizations.errorDeletingSchool}: $e');
    }
  }

  void _clearForm() {
    _nameArController.clear();
    _nameEnController.clear();
    _addressController.clear();
    _phoneController.clear();
    _principalNameController.clear();
    _selectedSchoolTypes.clear();
  }

  void _showErrorDialog(String message) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(localizations.error),
        content: Text(message),
        actions: [
          FilledButton(
            child: Text(localizations.ok),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    final localizations = AppLocalizations.of(context)!;

    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: Text(localizations.success),
        content: Text(message),
        severity: InfoBarSeverity.success,
        onClose: close,
      ),
    );
  }

  void _showAddSchoolDialog() {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(localizations.addNewSchool),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اسم المدرسة (عربي) *'),
                const SizedBox(height: 8),
                TextBox(
                  controller: _nameArController,
                  placeholder: 'أدخل اسم المدرسة بالعربية',
                ),
                const SizedBox(height: 16),
                Text('اسم المدرسة (إنجليزي)'),
                const SizedBox(height: 8),
                TextBox(
                  controller: _nameEnController,
                  placeholder: 'أدخل اسم المدرسة بالإنجليزية',
                ),
                const SizedBox(height: 16),
                Text('العنوان'),
                const SizedBox(height: 8),
                TextBox(
                  controller: _addressController,
                  placeholder: 'أدخل عنوان المدرسة',
                ),
                const SizedBox(height: 16),
                Text('رقم الهاتف'),
                const SizedBox(height: 8),
                TextBox(
                  controller: _phoneController,
                  placeholder: 'أدخل رقم الهاتف',
                ),
                const SizedBox(height: 16),
                Text('اسم المدير'),
                const SizedBox(height: 8),
                TextBox(
                  controller: _principalNameController,
                  placeholder: 'أدخل اسم مدير المدرسة',
                ),
                const SizedBox(height: 16),
                Text('أنواع المدرسة *'),
                const SizedBox(height: 8),
                ...School.availableSchoolTypes
                    .map(
                      (type) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Checkbox(
                          checked: _selectedSchoolTypes.contains(type),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedSchoolTypes.add(type);
                              } else {
                                _selectedSchoolTypes.remove(type);
                              }
                            });
                          },
                          content: Text(type),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ),
        actions: [
          Button(
            child: Text(localizations.cancel),
            onPressed: () {
              _clearForm();
              Navigator.pop(context);
            },
          ),
          FilledButton(child: Text(localizations.add), onPressed: _addSchool),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ScaffoldPage(
        header: PageHeader(
          title: Text(localizations.schoolManagement),
          commandBar: CommandBar(
            primaryItems: [
              CommandBarButton(
                icon: const Icon(FluentIcons.add),
                label: Text(localizations.addSchool),
                onPressed: _showAddSchoolDialog,
              ),
              CommandBarButton(
                icon: const Icon(FluentIcons.refresh),
                label: Text(localizations.refresh),
                onPressed: _loadSchools,
              ),
            ],
          ),
        ),
        content: _isLoading
            ? const Center(child: ProgressRing())
            : _schools.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      FluentIcons.education,
                      size: 64,
                      color: Color(0xFF0078D4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations.noSchoolsRegistered,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.clickAddSchoolToStart,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF605E5C),
                      ),
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
                        school.nameAr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (school.nameEn != null &&
                              school.nameEn!.isNotEmpty)
                            Text('الاسم الإنجليزي: ${school.nameEn}'),
                          if (school.address != null &&
                              school.address!.isNotEmpty)
                            Text('العنوان: ${school.address}'),
                          if (school.phone != null && school.phone!.isNotEmpty)
                            Text('الهاتف: ${school.phone}'),
                          if (school.principalName != null &&
                              school.principalName!.isNotEmpty)
                            Text('المدير: ${school.principalName}'),
                          Text('نوع المدرسة: ${school.schoolTypesDisplay}'),
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
                                  title: Text(localizations.confirmDelete),
                                  content: Text(
                                    'هل أنت متأكد من حذف مدرسة ${school.nameAr}؟',
                                  ),
                                  actions: [
                                    Button(
                                      child: Text(localizations.cancel),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    FilledButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(Colors.red),
                                      ),
                                      child: Text(localizations.delete),
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
      ),
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
