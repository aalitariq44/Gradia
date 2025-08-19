import 'package:fluent_ui/fluent_ui.dart';
import 'pages/schools_page.dart';
import 'pages/students_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Gradia - إدارة المدارس الأهلية',
      theme: FluentThemeData.light(),
      darkTheme: FluentThemeData.dark(),
      home: const MainNavigationPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<NavigationPaneItem> _items = [
    PaneItem(
      icon: const Icon(FluentIcons.education),
      title: const Text('المدارس'),
      body: const SchoolsPage(),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.people),
      title: const Text('الطلاب'),
      body: const StudentsPage(),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.money),
      title: const Text('الأقساط'),
      body: const Center(child: Text('صفحة الأقساط - قيد التطوير')),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.receipt_processing),
      title: const Text('الرسوم الإضافية'),
      body: const Center(child: Text('صفحة الرسوم الإضافية - قيد التطوير')),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: const Text('Gradia - إدارة المدارس الأهلية'),
        backgroundColor: Colors.transparent,
      ),
      pane: NavigationPane(
        selected: _selectedIndex,
        onChanged: (index) => setState(() => _selectedIndex = index),
        displayMode: PaneDisplayMode.open,
        items: _items,
        footerItems: [
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('الإعدادات'),
            body: const Center(child: Text('صفحة الإعدادات')),
          ),
        ],
      ),
    );
  }
}
