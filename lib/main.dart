import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart' hide Colors;
import 'generated/app_localizations.dart';
import 'pages/schools/schools_page.dart';
import 'pages/students/students_page.dart';
import 'pages/fees/installments_page.dart';
import 'pages/fees/additional_fees_page.dart';
import 'pages/teachers/teachers_page.dart';
import 'pages/employees/employees_page.dart';
import 'pages/finance/external_income_page.dart';
import 'pages/expenses/expenses_page.dart';
import 'pages/demo/font_demo_page.dart';
import 'utils/font_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Gradia - إدارة المدارس الأهلية',

      // Custom theme with Cairo font
      theme: FontConfig.createLightTheme(),
      darkTheme: FontConfig.createDarkTheme(),

      // Arabic localization support
      locale: const Locale('ar', 'SA'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'SA'), // Arabic
        Locale('en', 'US'), // English (fallback)
      ],
      builder: (context, child) => ScaffoldMessenger(child: child!),

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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final List<NavigationPaneItem> items = [
      PaneItem(
        icon: const Icon(FluentIcons.education),
        title: Text(localizations.schools),
        body: const SchoolsPage(),
      ),
      PaneItem(
        icon: const Icon(FluentIcons.people),
        title: Text(localizations.students),
        body: const StudentsPage(),
      ),
      PaneItem(
        icon: const Icon(FluentIcons.money),
        title: Text(localizations.tuitions),
        body: const TuitionsPage(),
      ),
      PaneItem(
        icon: const Icon(FluentIcons.receipt_processing),
        title: Text(localizations.additionalFees),
        body: const AdditionalFeesPage(),
      ),
      PaneItem(
        icon: const Icon(FluentIcons.people),
        title: const Text('المعلمين'),
        body: const TeachersPage(),
      ),
      PaneItem(
        icon: const Icon(FluentIcons.people),
        title: const Text('الموظفين'),
        body: const EmployeesPage(),
      ),
      PaneItem(
        icon: const Icon(FluentIcons.import),
        title: const Text('الواردات الخارجية'),
        body: const ExternalIncomePage(),
      ),
      PaneItem(
        icon: const Icon(FluentIcons.receipt_processing),
        title: const Text('المصروفات'),
        body: const ExpensesPage(),
      ),
      PaneItem(
        icon: const Icon(FluentIcons.money),
        title: const Text('الرواتب'),
        body: Center(child: const Text('صفحة الرواتب قيد التطوير')),
      ),
      PaneItem(
        icon: const Icon(FluentIcons.refresh),
        title: const Text('النسخ الاحتياطي'),
        body: Center(child: const Text('صفحة النسخ الاحتياطي قيد التطوير')),
      ),
      PaneItem(
        icon: const Icon(FluentIcons.font_size),
        title: const Text('عرض الخطوط'),
        body: const FontDemoPage(),
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl, // Force RTL layout
      child: NavigationView(
        appBar: NavigationAppBar(
          title: Text(localizations.appTitle),
          backgroundColor: Colors.transparent,
        ),
        pane: NavigationPane(
          selected: _selectedIndex,
          onChanged: (index) => setState(() => _selectedIndex = index),
          displayMode: PaneDisplayMode.open,
          items: items,
          footerItems: [
            PaneItemSeparator(),
            PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: Text(localizations.settings),
              body: Center(child: Text(localizations.settingsPage)),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.sign_out),
              title: const Text('تسجيل الخروج'),
              body: Center(child: const Text('تسجيل الخروج')),
            ),
          ],
        ),
      ),
    );
  }
}
