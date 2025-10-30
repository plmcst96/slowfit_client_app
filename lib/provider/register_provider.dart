import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config.dart';
import '../l10n/app_localizations.dart';
import '../model/register_model.dart';

final registerProvider =
    StateNotifierProvider<RegisterNotifier, RegisterState>((ref) {
  return RegisterNotifier(ref);
});

class RegisterState {
  final bool isRegister;
  final String? errorMessage;
  final int? userId;
  final String? message;

  RegisterState(
      {required this.isRegister, this.errorMessage, this.userId, this.message});

  RegisterState copyWith(
      {required bool isRegister,
      String? errorMessage,
      int? userId,
      String? message}) {
    return RegisterState(
        isRegister: isRegister,
        errorMessage: errorMessage ?? this.errorMessage,
        userId: userId ?? 0, // Ensure userId is copied
        message: message ?? '');
  }
}

class RegisterNotifier extends StateNotifier<RegisterState> {
  final Ref ref;
  RegisterNotifier(this.ref) : super(RegisterState(isRegister: false));

  Future<void> register(Register body, BuildContext context) async {
    // Start the login process
    state = state.copyWith(errorMessage: null, isRegister: false);

    final url = Uri.parse('${AppConfig.baseUrl}/register');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': '${AppConfig.slowKey}'
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data.toString());

        // Check if the message is "Login successful!" instead of "status"
        if (data['message'] == 'New user has been added successfully!') {
          state = state.copyWith(
              isRegister: true,
              userId: data['userId'], // Save the userId from response
              message: data['message']);
        }
      } else {
        state = state.copyWith(
            errorMessage: AppLocalizations.of(context)!.invalid,
            isRegister: false);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error occurred', isRegister: false);
      print(e);
    }
  }
}
