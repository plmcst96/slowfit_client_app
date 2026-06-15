import 'package:shared_preferences/shared_preferences.dart';
class AuthToken {
  static const String _prefsKey = 'jwt';

  static String? _token;
  static String? get token => _token;

  /// Salva il token in memoria e su disco (dopo il login).
  static Future<void> save(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, token);
  }

  /// Carica il token persistito in memoria (es. all'avvio dell'app).
  static Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_prefsKey);
    return _token;
  }

  /// Cancella il token (al logout).
  static Future<void> clear() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
