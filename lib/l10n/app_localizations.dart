import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

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
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @training.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training;

  /// No description provided for @nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @app.
  ///
  /// In en, this message translates to:
  /// **'Weekly Appointment'**
  String get app;

  /// No description provided for @app2.
  ///
  /// In en, this message translates to:
  /// **'Request Appointment'**
  String get app2;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @splash.
  ///
  /// In en, this message translates to:
  /// **'Start your transformation today'**
  String get splash;

  /// No description provided for @page_welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Personalized Training Plans'**
  String get page_welcome_title;

  /// No description provided for @page_welcome_text.
  ///
  /// In en, this message translates to:
  /// **'Tailored Nutrition Plan'**
  String get page_welcome_text;

  /// No description provided for @page_welcome_text_1.
  ///
  /// In en, this message translates to:
  /// **'Live Coaching Sessions'**
  String get page_welcome_text_1;

  /// No description provided for @button_welcome.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get button_welcome;

  /// No description provided for @button_welcome_1.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get button_welcome_1;

  /// No description provided for @button_welcome_2.
  ///
  /// In en, this message translates to:
  /// **'Register now!'**
  String get button_welcome_2;

  /// No description provided for @text_1.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get text_1;

  /// No description provided for @text_2.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account yet?'**
  String get text_2;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @welcome_1.
  ///
  /// In en, this message translates to:
  /// **'Log in to your account now!'**
  String get welcome_1;

  /// No description provided for @no_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get no_password;

  /// No description provided for @register_success.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get register_success;

  /// No description provided for @insert_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get insert_email;

  /// No description provided for @insert_email_1.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get insert_email_1;

  /// No description provided for @insert_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get insert_password;

  /// No description provided for @insert_password_1.
  ///
  /// In en, this message translates to:
  /// **'The password does not meet all the requirements'**
  String get insert_password_1;

  /// No description provided for @insert_password_2.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get insert_password_2;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get name;

  /// No description provided for @insert_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get insert_name;

  /// No description provided for @surname.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get surname;

  /// No description provided for @insert_surname.
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name'**
  String get insert_surname;

  /// No description provided for @password_text.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get password_text;

  /// No description provided for @password_text_1.
  ///
  /// In en, this message translates to:
  /// **'At least one uppercase letter'**
  String get password_text_1;

  /// No description provided for @password_text_2.
  ///
  /// In en, this message translates to:
  /// **'At least one special character'**
  String get password_text_2;

  /// No description provided for @password_text_3.
  ///
  /// In en, this message translates to:
  /// **'At least one number'**
  String get password_text_3;

  /// No description provided for @text_span.
  ///
  /// In en, this message translates to:
  /// **'By selecting I agree and continue, I accept the '**
  String get text_span;

  /// No description provided for @text_span_1.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get text_span_1;

  /// No description provided for @text_span_2.
  ///
  /// In en, this message translates to:
  /// **', i '**
  String get text_span_2;

  /// No description provided for @text_span_3.
  ///
  /// In en, this message translates to:
  /// **'Payment Terms of Service'**
  String get text_span_3;

  /// No description provided for @text_span_4.
  ///
  /// In en, this message translates to:
  /// **'and the'**
  String get text_span_4;

  /// No description provided for @text_span_5.
  ///
  /// In en, this message translates to:
  /// **'Notification Policy'**
  String get text_span_5;

  /// No description provided for @text_span_6.
  ///
  /// In en, this message translates to:
  /// **'and I acknowledge the'**
  String get text_span_6;

  /// No description provided for @text_span_7.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy.'**
  String get text_span_7;

  /// No description provided for @text_span_8.
  ///
  /// In en, this message translates to:
  /// **'Accept and Continue'**
  String get text_span_8;

  /// No description provided for @welcome_span.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Pilates at Home App!'**
  String get welcome_span;

  /// No description provided for @welcome_span_1.
  ///
  /// In en, this message translates to:
  /// **'Discover the perfect Pilates workout for you by answering 10 simple questions.'**
  String get welcome_span_1;

  /// No description provided for @start_test.
  ///
  /// In en, this message translates to:
  /// **'Start the test'**
  String get start_test;

  /// No description provided for @heigth.
  ///
  /// In en, this message translates to:
  /// **'Heigth'**
  String get heigth;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @invalid.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get invalid;

  /// No description provided for @error_register.
  ///
  /// In en, this message translates to:
  /// **'Error registering a new user'**
  String get error_register;
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
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
