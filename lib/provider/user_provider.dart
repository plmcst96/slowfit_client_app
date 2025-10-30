import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../model/user_model.dart';

class UserProfileState extends StateNotifier<UserProfile?> {
  UserProfileState() : super(null); // Stato iniziale nullo

  Future<void> fetchUserByEmail(String email) async {
    final url = Uri.parse('${AppConfig.baseUrl}/user/byEmail/$email');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': '${AppConfig.slowKey}'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        state = UserProfile.fromJson(data); // Assegna il singolo oggetto User
      } else {
        state = null;
      }
    } catch (e) {
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
    final url = Uri.parse('${AppConfig.baseUrl}/user/pt/$ptId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': '${AppConfig.slowKey}'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Mapping the fetched data to a list of User objects
        state = data.map((item) => User.fromJson(item)).toList();
      } else {
        state = [];
        print('Failed to fetch users');
      }
    } catch (e) {
      print('Error fetching users: $e');
      state = [];
    }
  }

  Future<void> fetchUserById(int clientId) async {
    final url = Uri.parse('${AppConfig.baseUrl}/user/$clientId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': '${AppConfig.slowKey}'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Mapping the fetched data to a list of User objects
        state = data.map((item) => User.fromJson(item)).toList();
      } else {
        state = [];
        print('Failed to fetch users');
      }
    } catch (e) {
      print('Error fetching users: $e');
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
    final url = Uri.parse('${AppConfig.baseUrl}/user/$clientId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': '${AppConfig.slowKey}'
        },
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        state = User.fromJson(data);
        ;
      } else {
        state = null;
        print('Failed to fetch users');
      }
    } catch (e) {
      print('Error fetching users: $e');
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
    final url = Uri.parse('${AppConfig.baseUrl}/user/profile/$userId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': '${AppConfig.slowKey}'
        },
        body: jsonEncode(profile.toJson()),
      );

      if (response.statusCode == 200) {
        return response.body; // ritorna la risposta del server
      } else {
        return 'Errore ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      print('Error post profile: $e');
      state = null;
    }
    return null;
  }
}

final addProfileUserProvider =
    StateNotifierProvider<UserAddProfileState, AddProfile?>(
        (ref) => UserAddProfileState());

