import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../l10n/app_localizations.dart';

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(ref);
});

class LoginState {
  final bool isLoggedIn;
  final String? errorMessage;
  final int? userId;
  final String? email; // Add userId to the state
  final int? roleId;

  LoginState({
    required this.isLoggedIn,
    this.errorMessage,
    this.userId,
    this.email, // Initialize userId
    this.roleId,
  });

  LoginState copyWith({
    required bool isLoggedIn,
    int? userId,
    String? errorMessage,
    String? email,
    int? roleId, // Add userId to copyWith method
  }) {
    return LoginState(
      isLoggedIn: isLoggedIn,
      errorMessage: errorMessage ?? this.errorMessage,
      email: email ?? this.email, // Ensure userId is copied
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
    // Start the login process
    state = state.copyWith(errorMessage: null, isLoggedIn: false);

    final url = Uri.parse('${AppConfig.baseUrl}/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': '${AppConfig.slowKey}',
        },
        body: json.encode({'Email': email, 'Password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if the message is "Login successful!" instead of "status"
        if (data['message'] == 'Login successful!') {
          state = state.copyWith(
            isLoggedIn: true,
            email: data['email'], // Save the userId from response
            userId: data['userId'],
            roleId: data['roleId'],
          );
        }
      } else {
        state = state.copyWith(
          errorMessage: AppLocalizations.of(context)!.invalid,
          isLoggedIn: false,
        );
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error occurred', isLoggedIn: false);
      print(e);
    }
  }

  /// 🔹 LOGOUT: cancella tutto e torna allo stato iniziale
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 🔹 Resetta lo stato dell’utente
    state = LoginState(
      isLoggedIn: false,
      email: null,
      userId: null,
      roleId: null,
    );
  }
}
