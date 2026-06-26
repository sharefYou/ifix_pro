import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'آي فيكس برو'**
  String get appName;

  /// No description provided for @selectLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get selectLanguage;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @continueBtn.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continueBtn;

  /// No description provided for @welcome.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك شريكنا'**
  String get welcome;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'انضم لأفضل الفنيين وقدم خدماتك لآلاف العملاء بكل سهولة'**
  String get welcomeSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get getStarted;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @register.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل كمقدم خدمة'**
  String get register;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get phone;

  /// No description provided for @city.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get city;

  /// No description provided for @specialty.
  ///
  /// In ar, this message translates to:
  /// **'التخصص'**
  String get specialty;

  /// No description provided for @bankName.
  ///
  /// In ar, this message translates to:
  /// **'اسم البنك'**
  String get bankName;

  /// No description provided for @iban.
  ///
  /// In ar, this message translates to:
  /// **'رقم الآيبان'**
  String get iban;

  /// No description provided for @uploadID.
  ///
  /// In ar, this message translates to:
  /// **'رفع صورة الإقامة/الهوية'**
  String get uploadID;

  /// No description provided for @uploadPhoto.
  ///
  /// In ar, this message translates to:
  /// **'رفع الصورة الشخصية'**
  String get uploadPhoto;

  /// No description provided for @pendingApproval.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get pendingApproval;

  /// No description provided for @pendingMessage.
  ///
  /// In ar, this message translates to:
  /// **'طلبك قيد المراجعة من قبل الإدارة، سيتم إشعارك فور القبول'**
  String get pendingMessage;

  /// No description provided for @online.
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get offline;

  /// No description provided for @availability.
  ///
  /// In ar, this message translates to:
  /// **'حالة التواجد'**
  String get availability;

  /// No description provided for @newOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلبات جديدة'**
  String get newOrders;

  /// No description provided for @orderDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الطلب'**
  String get orderDetails;

  /// No description provided for @acceptOrder.
  ///
  /// In ar, this message translates to:
  /// **'قبول الطلب'**
  String get acceptOrder;

  /// No description provided for @rejectOrder.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get rejectOrder;

  /// No description provided for @totalAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ الإجمالي'**
  String get totalAmount;

  /// No description provided for @netAmount.
  ///
  /// In ar, this message translates to:
  /// **'صافي الربح'**
  String get netAmount;

  /// No description provided for @appCommission.
  ///
  /// In ar, this message translates to:
  /// **'عمولة التطبيق'**
  String get appCommission;

  /// No description provided for @completeOrder.
  ///
  /// In ar, this message translates to:
  /// **'إكمال الطلب'**
  String get completeOrder;

  /// No description provided for @customOrders.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات الخاصة'**
  String get customOrders;

  /// No description provided for @submitOffer.
  ///
  /// In ar, this message translates to:
  /// **'تقديم عرض سعر'**
  String get submitOffer;

  /// No description provided for @wallet.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get wallet;

  /// No description provided for @dues.
  ///
  /// In ar, this message translates to:
  /// **'المبالغ المستحقة للتطبيق'**
  String get dues;

  /// No description provided for @earnings.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأرباح'**
  String get earnings;

  /// No description provided for @payout.
  ///
  /// In ar, this message translates to:
  /// **'طلب تحويل رصيد'**
  String get payout;

  /// No description provided for @uploadReceipt.
  ///
  /// In ar, this message translates to:
  /// **'رفع إيصال التحويل'**
  String get uploadReceipt;

  /// No description provided for @suspended.
  ///
  /// In ar, this message translates to:
  /// **'الحساب موقوف'**
  String get suspended;

  /// No description provided for @suspendedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم إيقاف حسابك لتجاوز حد المديونية، يرجى السداد لفك الحظر'**
  String get suspendedMessage;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @sar.
  ///
  /// In ar, this message translates to:
  /// **'ل.س'**
  String get sar;

  /// No description provided for @km.
  ///
  /// In ar, this message translates to:
  /// **'كم'**
  String get km;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
