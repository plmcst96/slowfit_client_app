import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import '../config.dart';
import '../service/api_client.dart';
import '../service/app_messenger.dart';
import '../model/user_model.dart';

class UserProfileState extends StateNotifier<UserProfile?> {
  UserProfileState() : super(null); // Stato iniziale nullo

  Future<void> fetchUserByEmail(String email) async {
    try {
      final response =
          await ApiClient.get('${AppConfig.baseUrl}/user/byEmail/$email');
      final Map<String, dynamic> data = json.decode(response.body);
      state = UserProfile.fromJson(data); // Assegna il singolo oggetto User
    } on ApiException catch (e) {
      showAppError('Profilo utente: ${e.message}');
      state = null;
    }
  }
}

// Provider Riverpod
final userProfileProvider =
    StateNotifierProvider<UserProfileState, UserProfile?>(
  (ref) => UserProfileState(),
);

class UserState extends StateNotifier<List<User>> {
  UserState() : super([]); // Stato iniziale vuoto

  Future<void> fetchUserByPtId(int ptId) async {
    try {
      final response =
          await ApiClient.get('${AppConfig.baseUrl}/user/pt/$ptId');
      final List<dynamic> data = json.decode(response.body);
      state = data.map((item) => User.fromJson(item)).toList();
    } on ApiException catch (e) {
      showAppError('Utenti: ${e.message}');
      state = [];
    }
  }

  Future<void> fetchUserById(int clientId) async {
    try {
      final response =
          await ApiClient.get('${AppConfig.baseUrl}/user/$clientId');
      final List<dynamic> data = json.decode(response.body);
      state = data.map((item) => User.fromJson(item)).toList();
    } on ApiException catch (e) {
      showAppError('Utenti: ${e.message}');
      state = [];
    }
  }
}

// Provider Riverpod
final userProvider = StateNotifierProvider<UserState, List<User>>(
  (ref) => UserState(),
);

class UserSingleState extends StateNotifier<User?> {
  UserSingleState() : super(null); // Stato iniziale vuoto

  Future<void> fetchUserById(int clientId) async {
    try {
      final response =
          await ApiClient.get('${AppConfig.baseUrl}/user/$clientId');
      final dynamic data = json.decode(response.body);
      state = User.fromJson(data);
    } on ApiException catch (e) {
      showAppError('Utente: ${e.message}');
      state = null;
    }
  }
}

// Provider Riverpod
final userSingleProvider = StateNotifierProvider<UserSingleState, User?>(
  (ref) => UserSingleState(),
);

class UserAddProfileState extends StateNotifier<AddProfile?> {
  UserAddProfileState() : super(null);

  Future<String?> addProfile(int userId, AddProfile profile) async {
    try {
      final response = await ApiClient.post(
        '${AppConfig.baseUrl}/user/profile/$userId',
        body: jsonEncode(profile.toJson()),
      );
      return response.body; // ritorna la risposta del server
    } on ApiException catch (e) {
      showAppError('Salvataggio profilo fallito: ${e.message}');
      state = null;
      return null;
    }
  }
}

final addProfileUserProvider =
    StateNotifierProvider<UserAddProfileState, AddProfile?>(
        (ref) => UserAddProfileState());
