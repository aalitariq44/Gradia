import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar')];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'Gradia - إدارة المدارس الأهلية'**
  String get appTitle;

  /// No description provided for @schools.
  ///
  /// In ar, this message translates to:
  /// **'المدارس'**
  String get schools;

  /// No description provided for @students.
  ///
  /// In ar, this message translates to:
  /// **'الطلاب'**
  String get students;

  /// No description provided for @tuitions.
  ///
  /// In ar, this message translates to:
  /// **'الأقساط'**
  String get tuitions;

  /// No description provided for @additionalFees.
  ///
  /// In ar, this message translates to:
  /// **'الرسوم الإضافية'**
  String get additionalFees;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @tuitionsPageDev.
  ///
  /// In ar, this message translates to:
  /// **'صفحة الأقساط - قيد التطوير'**
  String get tuitionsPageDev;

  /// No description provided for @additionalFeesPageDev.
  ///
  /// In ar, this message translates to:
  /// **'صفحة الرسوم الإضافية - قيد التطوير'**
  String get additionalFeesPageDev;

  /// No description provided for @settingsPage.
  ///
  /// In ar, this message translates to:
  /// **'صفحة الإعدادات'**
  String get settingsPage;

  /// No description provided for @schoolName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المدرسة'**
  String get schoolName;

  /// No description provided for @address.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get address;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// No description provided for @emailAddress.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get emailAddress;

  /// No description provided for @directorName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المدير'**
  String get directorName;

  /// No description provided for @addSchool.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مدرسة'**
  String get addSchool;

  /// No description provided for @editSchool.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المدرسة'**
  String get editSchool;

  /// No description provided for @deleteSchool.
  ///
  /// In ar, this message translates to:
  /// **'حذف المدرسة'**
  String get deleteSchool;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @studentName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الطالب'**
  String get studentName;

  /// No description provided for @studentId.
  ///
  /// In ar, this message translates to:
  /// **'رقم الطالب'**
  String get studentId;

  /// No description provided for @grade.
  ///
  /// In ar, this message translates to:
  /// **'الصف'**
  String get grade;

  /// No description provided for @dateOfBirth.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الميلاد'**
  String get dateOfBirth;

  /// No description provided for @guardianName.
  ///
  /// In ar, this message translates to:
  /// **'اسم ولي الأمر'**
  String get guardianName;

  /// No description provided for @guardianPhone.
  ///
  /// In ar, this message translates to:
  /// **'هاتف ولي الأمر'**
  String get guardianPhone;

  /// No description provided for @addStudent.
  ///
  /// In ar, this message translates to:
  /// **'إضافة طالب'**
  String get addStudent;

  /// No description provided for @editStudent.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الطالب'**
  String get editStudent;

  /// No description provided for @deleteStudent.
  ///
  /// In ar, this message translates to:
  /// **'حذف الطالب'**
  String get deleteStudent;

  /// No description provided for @searchSchools.
  ///
  /// In ar, this message translates to:
  /// **'البحث في المدارس...'**
  String get searchSchools;

  /// No description provided for @searchStudents.
  ///
  /// In ar, this message translates to:
  /// **'البحث في الطلاب...'**
  String get searchStudents;

  /// No description provided for @noSchoolsFound.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مدارس'**
  String get noSchoolsFound;

  /// No description provided for @noStudentsFound.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد طلاب'**
  String get noStudentsFound;

  /// No description provided for @pleaseSelectSchool.
  ///
  /// In ar, this message translates to:
  /// **'يرجى اختيار مدرسة أولاً'**
  String get pleaseSelectSchool;

  /// No description provided for @confirmDeleteSchool.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذه المدرسة؟'**
  String get confirmDeleteSchool;

  /// No description provided for @confirmDeleteStudent.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا الطالب؟'**
  String get confirmDeleteStudent;

  /// No description provided for @schoolAdded.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة المدرسة بنجاح'**
  String get schoolAdded;

  /// No description provided for @schoolUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث المدرسة بنجاح'**
  String get schoolUpdated;

  /// No description provided for @schoolDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المدرسة بنجاح'**
  String get schoolDeleted;

  /// No description provided for @studentAdded.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة الطالب بنجاح'**
  String get studentAdded;

  /// No description provided for @studentUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الطالب بنجاح'**
  String get studentUpdated;

  /// No description provided for @studentDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الطالب بنجاح'**
  String get studentDeleted;

  /// No description provided for @error.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get error;

  /// No description provided for @success.
  ///
  /// In ar, this message translates to:
  /// **'نجح'**
  String get success;

  /// No description provided for @fieldRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني غير صحيح'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف غير صحيح'**
  String get invalidPhone;

  /// No description provided for @schoolManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المدارس'**
  String get schoolManagement;

  /// No description provided for @refresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get refresh;

  /// No description provided for @noSchoolsRegistered.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مدارس مسجلة'**
  String get noSchoolsRegistered;

  /// No description provided for @clickAddSchoolToStart.
  ///
  /// In ar, this message translates to:
  /// **'انقر على \"إضافة مدرسة\" لبدء إضافة المدارس'**
  String get clickAddSchoolToStart;

  /// No description provided for @addNewSchool.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مدرسة جديدة'**
  String get addNewSchool;

  /// No description provided for @enterSchoolName.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم المدرسة'**
  String get enterSchoolName;

  /// No description provided for @enterSchoolAddress.
  ///
  /// In ar, this message translates to:
  /// **'أدخل عنوان المدرسة'**
  String get enterSchoolAddress;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم الهاتف'**
  String get enterPhoneNumber;

  /// No description provided for @enterEmail.
  ///
  /// In ar, this message translates to:
  /// **'أدخل البريد الإلكتروني'**
  String get enterEmail;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @confirmDelete.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحذف'**
  String get confirmDelete;

  /// No description provided for @phone.
  ///
  /// In ar, this message translates to:
  /// **'الهاتف'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد'**
  String get email;

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'موافق'**
  String get ok;

  /// No description provided for @errorLoadingSchools.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل المدارس'**
  String get errorLoadingSchools;

  /// No description provided for @pleaseEnterSchoolName.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال اسم المدرسة'**
  String get pleaseEnterSchoolName;

  /// No description provided for @errorAddingSchool.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في إضافة المدرسة'**
  String get errorAddingSchool;

  /// No description provided for @errorDeletingSchool.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في حذف المدرسة'**
  String get errorDeletingSchool;

  /// No description provided for @areYouSureDeleteSchool.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف مدرسة \"{schoolName}\"?'**
  String areYouSureDeleteSchool(String schoolName);

  /// No description provided for @studentManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الطلاب'**
  String get studentManagement;

  /// No description provided for @addNewStudent.
  ///
  /// In ar, this message translates to:
  /// **'إضافة طالب جديد'**
  String get addNewStudent;

  /// No description provided for @classSection.
  ///
  /// In ar, this message translates to:
  /// **'الشعبة'**
  String get classSection;

  /// No description provided for @parentName.
  ///
  /// In ar, this message translates to:
  /// **'اسم ولي الأمر'**
  String get parentName;

  /// No description provided for @parentPhone.
  ///
  /// In ar, this message translates to:
  /// **'هاتف ولي الأمر'**
  String get parentPhone;

  /// No description provided for @chooseSchool.
  ///
  /// In ar, this message translates to:
  /// **'اختر المدرسة'**
  String get chooseSchool;

  /// No description provided for @enterStudentId.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم الطالب'**
  String get enterStudentId;

  /// No description provided for @enterStudentName.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم الطالب'**
  String get enterStudentName;

  /// No description provided for @enterParentName.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم ولي الأمر'**
  String get enterParentName;

  /// No description provided for @enterParentPhone.
  ///
  /// In ar, this message translates to:
  /// **'أدخل هاتف ولي الأمر'**
  String get enterParentPhone;

  /// No description provided for @enterAddress.
  ///
  /// In ar, this message translates to:
  /// **'أدخل العنوان'**
  String get enterAddress;

  /// No description provided for @noStudentsRegistered.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد طلاب مسجلون'**
  String get noStudentsRegistered;

  /// No description provided for @clickAddStudentToStart.
  ///
  /// In ar, this message translates to:
  /// **'انقر على \"إضافة طالب\" لبدء إضافة الطلاب'**
  String get clickAddStudentToStart;

  /// No description provided for @school.
  ///
  /// In ar, this message translates to:
  /// **'المدرسة'**
  String get school;

  /// No description provided for @guardian.
  ///
  /// In ar, this message translates to:
  /// **'ولي الأمر'**
  String get guardian;

  /// No description provided for @undefined.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get undefined;

  /// No description provided for @errorLoadingData.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل البيانات'**
  String get errorLoadingData;

  /// No description provided for @pleaseEnterAllRequiredData.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال جميع البيانات المطلوبة'**
  String get pleaseEnterAllRequiredData;

  /// No description provided for @errorAddingStudent.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في إضافة الطالب'**
  String get errorAddingStudent;

  /// No description provided for @errorDeletingStudent.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في حذف الطالب'**
  String get errorDeletingStudent;

  /// No description provided for @areYouSureDeleteStudent.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف الطالب \"{studentName}\"?'**
  String areYouSureDeleteStudent(String studentName);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
