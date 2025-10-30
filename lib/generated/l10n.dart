// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Exercise`
  String get training {
    return Intl.message('Exercise', name: 'training', desc: '', args: []);
  }

  /// `Nutrition`
  String get nutrition {
    return Intl.message('Nutrition', name: 'nutrition', desc: '', args: []);
  }

  /// `Client`
  String get client {
    return Intl.message('Client', name: 'client', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Welcome`
  String get welcome {
    return Intl.message('Welcome', name: 'welcome', desc: '', args: []);
  }

  /// `Weekly Appointment`
  String get app {
    return Intl.message('Weekly Appointment', name: 'app', desc: '', args: []);
  }

  /// `Appointment`
  String get app2 {
    return Intl.message('Appointment', name: 'app2', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Start your transformation today`
  String get splash {
    return Intl.message(
      'Start your transformation today',
      name: 'splash',
      desc: '',
      args: [],
    );
  }

  /// `Personalized Training Plans`
  String get page_welcome_title {
    return Intl.message(
      'Personalized Training Plans',
      name: 'page_welcome_title',
      desc: '',
      args: [],
    );
  }

  /// `Tailored Nutrition Plan`
  String get page_welcome_text {
    return Intl.message(
      'Tailored Nutrition Plan',
      name: 'page_welcome_text',
      desc: '',
      args: [],
    );
  }

  /// `Live Coaching Sessions`
  String get page_welcome_text_1 {
    return Intl.message(
      'Live Coaching Sessions',
      name: 'page_welcome_text_1',
      desc: '',
      args: [],
    );
  }

  /// `Learn more`
  String get button_welcome {
    return Intl.message(
      'Learn more',
      name: 'button_welcome',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get button_welcome_1 {
    return Intl.message('Start', name: 'button_welcome_1', desc: '', args: []);
  }

  /// `Register now!`
  String get button_welcome_2 {
    return Intl.message(
      'Register now!',
      name: 'button_welcome_2',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account? `
  String get text_1 {
    return Intl.message(
      'Already have an account? ',
      name: 'text_1',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account yet?`
  String get text_2 {
    return Intl.message(
      'Don\'t have an account yet?',
      name: 'text_2',
      desc: '',
      args: [],
    );
  }

  /// `Sign in`
  String get login {
    return Intl.message('Sign in', name: 'login', desc: '', args: []);
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `Log in to your account now!`
  String get welcome_1 {
    return Intl.message(
      'Log in to your account now!',
      name: 'welcome_1',
      desc: '',
      args: [],
    );
  }

  /// `Forgot your password?`
  String get no_password {
    return Intl.message(
      'Forgot your password?',
      name: 'no_password',
      desc: '',
      args: [],
    );
  }

  /// `Registration successful!`
  String get register_success {
    return Intl.message(
      'Registration successful!',
      name: 'register_success',
      desc: '',
      args: [],
    );
  }

  /// `Please enter an email`
  String get insert_email {
    return Intl.message(
      'Please enter an email',
      name: 'insert_email',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email`
  String get insert_email_1 {
    return Intl.message(
      'Please enter a valid email',
      name: 'insert_email_1',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a password`
  String get insert_password {
    return Intl.message(
      'Please enter a password',
      name: 'insert_password',
      desc: '',
      args: [],
    );
  }

  /// `The password does not meet all the requirements`
  String get insert_password_1 {
    return Intl.message(
      'The password does not meet all the requirements',
      name: 'insert_password_1',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect password`
  String get insert_password_2 {
    return Intl.message(
      'Incorrect password',
      name: 'insert_password_2',
      desc: '',
      args: [],
    );
  }

  /// `First name`
  String get name {
    return Intl.message('First name', name: 'name', desc: '', args: []);
  }

  /// `Please enter your first name`
  String get insert_name {
    return Intl.message(
      'Please enter your first name',
      name: 'insert_name',
      desc: '',
      args: [],
    );
  }

  /// `Last name`
  String get surname {
    return Intl.message('Last name', name: 'surname', desc: '', args: []);
  }

  /// `Please enter your last name`
  String get insert_surname {
    return Intl.message(
      'Please enter your last name',
      name: 'insert_surname',
      desc: '',
      args: [],
    );
  }

  /// `At least 8 characters`
  String get password_text {
    return Intl.message(
      'At least 8 characters',
      name: 'password_text',
      desc: '',
      args: [],
    );
  }

  /// `At least one uppercase letter`
  String get password_text_1 {
    return Intl.message(
      'At least one uppercase letter',
      name: 'password_text_1',
      desc: '',
      args: [],
    );
  }

  /// `At least one special character`
  String get password_text_2 {
    return Intl.message(
      'At least one special character',
      name: 'password_text_2',
      desc: '',
      args: [],
    );
  }

  /// `At least one number`
  String get password_text_3 {
    return Intl.message(
      'At least one number',
      name: 'password_text_3',
      desc: '',
      args: [],
    );
  }

  /// `By selecting I agree and continue, I accept the `
  String get text_span {
    return Intl.message(
      'By selecting I agree and continue, I accept the ',
      name: 'text_span',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Service`
  String get text_span_1 {
    return Intl.message(
      'Terms of Service',
      name: 'text_span_1',
      desc: '',
      args: [],
    );
  }

  /// `, i `
  String get text_span_2 {
    return Intl.message(', i ', name: 'text_span_2', desc: '', args: []);
  }

  /// `Payment Terms of Service`
  String get text_span_3 {
    return Intl.message(
      'Payment Terms of Service',
      name: 'text_span_3',
      desc: '',
      args: [],
    );
  }

  /// `and the`
  String get text_span_4 {
    return Intl.message('and the', name: 'text_span_4', desc: '', args: []);
  }

  /// `Notification Policy`
  String get text_span_5 {
    return Intl.message(
      'Notification Policy',
      name: 'text_span_5',
      desc: '',
      args: [],
    );
  }

  /// `and I acknowledge the`
  String get text_span_6 {
    return Intl.message(
      'and I acknowledge the',
      name: 'text_span_6',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy.`
  String get text_span_7 {
    return Intl.message(
      'Privacy Policy.',
      name: 'text_span_7',
      desc: '',
      args: [],
    );
  }

  /// `Accept and Continue`
  String get text_span_8 {
    return Intl.message(
      'Accept and Continue',
      name: 'text_span_8',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to the Pilates at Home App!`
  String get welcome_span {
    return Intl.message(
      'Welcome to the Pilates at Home App!',
      name: 'welcome_span',
      desc: '',
      args: [],
    );
  }

  /// `Discover the perfect Pilates workout for you by answering 10 simple questions.`
  String get welcome_span_1 {
    return Intl.message(
      'Discover the perfect Pilates workout for you by answering 10 simple questions.',
      name: 'welcome_span_1',
      desc: '',
      args: [],
    );
  }

  /// `Start the test`
  String get start_test {
    return Intl.message(
      'Start the test',
      name: 'start_test',
      desc: '',
      args: [],
    );
  }

  /// `Heigth`
  String get heigth {
    return Intl.message('Heigth', name: 'heigth', desc: '', args: []);
  }

  /// `Weight`
  String get weight {
    return Intl.message('Weight', name: 'weight', desc: '', args: []);
  }

  /// `Incorrect email or password`
  String get invalid {
    return Intl.message(
      'Incorrect email or password',
      name: 'invalid',
      desc: '',
      args: [],
    );
  }

  /// `Error registering a new user`
  String get error_register {
    return Intl.message(
      'Error registering a new user',
      name: 'error_register',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'it'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
