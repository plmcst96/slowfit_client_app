import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config.dart';
import '../service/api_client.dart';
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

    // Messaggio localizzato catturato prima dell'await.
    final String invalidMsg = AppLocalizations.of(context)!.invalid;

    try {
      final response = await ApiClient.post(
        '${AppConfig.baseUrl}/register',
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      // Check if the message is "Login successful!" instead of "status"
      if (data['message'] == 'New user has been added successfully!') {
        state = state.copyWith(
            isRegister: true,
            userId: data['userId'], // Save the userId from response
            message: data['message']);
      } else {
        state = state.copyWith(errorMessage: invalidMsg, isRegister: false);
      }
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message, isRegister: false);
    }
  }
}
