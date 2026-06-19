import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../service/api_client.dart';
import '../service/auth_session.dart';
import '../service/auth_token.dart';
import '../l10n/app_localizations.dart';

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(ref);
});

class LoginState {
  final bool isLoggedIn;
  final String? errorMessage;
  final int? userId;
  final String? email;
  final int? roleId;

  LoginState({
    required this.isLoggedIn,
    this.errorMessage,
    this.userId,
    this.email,
    this.roleId,
  });

  LoginState copyWith({
    required bool isLoggedIn,
    int? userId,
    String? errorMessage,
    String? email,
    int? roleId,
  }) {
    return LoginState(
      isLoggedIn: isLoggedIn,
      errorMessage: errorMessage ?? this.errorMessage,
      email: email ?? this.email,
      userId: userId ?? this.userId,
      roleId: roleId ?? this.roleId,
    );
  }
}

class LoginNotifier extends StateNotifier<LoginState> {
  final Ref ref;
  LoginNotifier(this.ref) : super(LoginState(isLoggedIn: false));

  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    state = state.copyWith(errorMessage: null, isLoggedIn: false);
    final String invalidMsg = AppLocalizations.of(context)!.invalid;

    try {
      final response = await ApiClient.post(
        '${AppConfig.baseUrl}/login',
        body: json.encode({'Email': email, 'Password': password}),
      );

      final data = json.decode(response.body);

      if (data['message'] == 'Login successful!') {
        if (data['token'] != null) {
          await AuthToken.save(data['token']);
          AuthSession.instance.start();
        }
        state = state.copyWith(
          isLoggedIn: true,
          email: data['email'],
          userId: data['userId'],
          roleId: data['roleId'],
        );
      } else {
        state = state.copyWith(errorMessage: invalidMsg, isLoggedIn: false);
      }
    } on ApiException catch (e) {
      final msg = (e.statusCode == 400 || e.statusCode == 401)
          ? invalidMsg
          : e.message;
      state = state.copyWith(errorMessage: msg, isLoggedIn: false);
    }
  }

  /// 🔹 LOGOUT: cancella tutto e torna allo stato iniziale
  Future<void> logout() async {
    AuthSession.instance.stop();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await AuthToken.clear();

    // 🔹 Resetta lo stato dell’utente
    state = LoginState(
      isLoggedIn: false,
      email: null,
      userId: null,
      roleId: null,
    );
  }
}
