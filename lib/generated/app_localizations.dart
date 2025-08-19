import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
/// Please make sure to update your pubspec.yaml file to include the following
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
/// To configure the locales supported by your app, you'll need to edit this
/// file.
///
/// First, open your project's ios/Runner/Info.plist file and modify the
/// CFBundleLocalizations array to include the language code of the locales
/// you want to support.
///
/// Next, update your application's Localizable.strings files to include the
/// new translations for your supported locales.
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

  /// A list of locales this localizations delegate supports.
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
  String get schoolName;

  /// No description provided for @address.
  String get address;

  /// No description provided for @phoneNumber.
  String get phoneNumber;

  /// No description provided for @emailAddress.
  String get emailAddress;

  /// No description provided for @addSchool.
  String get addSchool;

  /// No description provided for @editSchool.
  String get editSchool;

  /// No description provided for @deleteSchool.
  String get deleteSchool;

  /// No description provided for @save.
  String get save;

  /// No description provided for @cancel.
  String get cancel;

  /// No description provided for @edit.
  String get edit;

  /// No description provided for @delete.
  String get delete;

  /// No description provided for @error.
  String get error;

  /// No description provided for @success.
  String get success;

  /// No description provided for @schoolManagement.
  String get schoolManagement;

  /// No description provided for @refresh.
  String get refresh;

  /// No description provided for @noSchoolsRegistered.
  String get noSchoolsRegistered;

  /// No description provided for @clickAddSchoolToStart.
  String get clickAddSchoolToStart;

  /// No description provided for @addNewSchool.
  String get addNewSchool;

  /// No description provided for @enterSchoolName.
  String get enterSchoolName;

  /// No description provided for @enterSchoolAddress.
  String get enterSchoolAddress;

  /// No description provided for @enterPhoneNumber.
  String get enterPhoneNumber;

  /// No description provided for @enterEmail.
  String get enterEmail;

  /// No description provided for @add.
  String get add;

  /// No description provided for @confirmDelete.
  String get confirmDelete;

  /// No description provided for @phone.
  String get phone;

  /// No description provided for @email.
  String get email;

  /// No description provided for @ok.
  String get ok;

  /// No description provided for @errorLoadingSchools.
  String get errorLoadingSchools;

  /// No description provided for @pleaseEnterSchoolName.
  String get pleaseEnterSchoolName;

  /// No description provided for @errorAddingSchool.
  String get errorAddingSchool;

  /// No description provided for @errorDeletingSchool.
  String get errorDeletingSchool;

  /// No description provided for @schoolAdded.
  String get schoolAdded;

  /// No description provided for @schoolDeleted.
  String get schoolDeleted;

  /// No description provided for @areYouSureDeleteSchool.
  String areYouSureDeleteSchool(String schoolName);

  /// No description provided for @studentManagement.
  String get studentManagement;

  /// No description provided for @addStudent.
  String get addStudent;

  /// No description provided for @addNewStudent.
  String get addNewStudent;

  /// No description provided for @studentId.
  String get studentId;

  /// No description provided for @studentName.
  String get studentName;

  /// No description provided for @grade.
  String get grade;

  /// No description provided for @classSection.
  String get classSection;

  /// No description provided for @parentName.
  String get parentName;

  /// No description provided for @parentPhone.
  String get parentPhone;

  /// No description provided for @chooseSchool.
  String get chooseSchool;

  /// No description provided for @enterStudentId.
  String get enterStudentId;

  /// No description provided for @enterStudentName.
  String get enterStudentName;

  /// No description provided for @enterParentName.
  String get enterParentName;

  /// No description provided for @enterParentPhone.
  String get enterParentPhone;

  /// No description provided for @enterAddress.
  String get enterAddress;

  /// No description provided for @noStudentsRegistered.
  String get noStudentsRegistered;

  /// No description provided for @clickAddStudentToStart.
  String get clickAddStudentToStart;

  /// No description provided for @school.
  String get school;

  /// No description provided for @guardian.
  String get guardian;

  /// No description provided for @undefined.
  String get undefined;

  /// No description provided for @studentAdded.
  String get studentAdded;

  /// No description provided for @studentDeleted.
  String get studentDeleted;

  /// No description provided for @errorLoadingData.
  String get errorLoadingData;

  /// No description provided for @pleaseEnterAllRequiredData.
  String get pleaseEnterAllRequiredData;

  /// No description provided for @errorAddingStudent.
  String get errorAddingStudent;

  /// No description provided for @errorDeletingStudent.
  String get errorDeletingStudent;

  /// No description provided for @areYouSureDeleteStudent.
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
    'an issue with the localizations generation tool. Please file an issue on GitHub with '
    'a reproducible sample app and the gen-l10n configuration that was used.',
  );
}
