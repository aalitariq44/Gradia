import 'package:fluent_ui/fluent_ui.dart';

class SchoolsPage extends StatelessWidget {
  const SchoolsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(title: Text('إدارة المدارس')),
      content: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FluentIcons.education, size: 64, color: Color(0xFF0078D4)),
            SizedBox(height: 16),
            Text(
              'صفحة إدارة المدارس',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'هنا يمكنك إدارة جميع المدارس في النظام',
              style: TextStyle(fontSize: 16, color: Color(0xFF605E5C)),
            ),
          ],
        ),
      ),
    );
  }
}
