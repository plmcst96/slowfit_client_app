import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import 'app_messenger.dart';
import 'auth_token.dart';

/// Gestisce il rinnovo proattivo dell'access token JWT (scadenza ~3h).
///
/// Il refresh avviene chiamando POST {baseUrl}/login/refresh con il Bearer del
/// token ANCORA valido; la risposta contiene un nuovo token in `data['token']`.
/// Va quindi schedulato PRIMA della scadenza. Se il token è già scaduto (401),
/// non è più rinnovabile: si torna al login.
class AuthSession {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  static const String _refreshUrl = '${AppConfig.baseUrl}/login/refresh';

  /// Rinnova un po' prima della scadenza reale, per stare al sicuro.
  static const Duration _safetyMargin = Duration(minutes: 5);

  /// Usato se non si riesce a leggere la scadenza (exp) dal token.
  static const Duration _fallbackInterval = Duration(hours: 2, minutes: 45);

  Timer? _timer;
  bool _handlingUnauthorized = false;

  /// (Ri)pianifica il refresh in base alla scadenza del token corrente.
  void start() {
    stop();
    if (!AuthToken.hasToken) return;
    _timer = Timer(_nextRefreshDelay(), _refresh);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Duration _nextRefreshDelay() {
    final expiry = _tokenExpiry();
    if (expiry == null) return _fallbackInterval;
    final remaining = expiry.difference(DateTime.now()) - _safetyMargin;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<void> _refresh() async {
    final token = AuthToken.token;
    if (token == null || token.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(_refreshUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newToken = data['token'] as String?;
        if (newToken != null && newToken.isNotEmpty) {
          await AuthToken.save(newToken);
          start(); // ripianifica sul nuovo token
          return;
        }
      }
    } catch (_) {
      // Errore di rete o risposta inattesa: trattiamo come sessione scaduta.
    }

    // Refresh non riuscito: la sessione non è più valida -> torna al login.
    await handleUnauthorized();
  }

  /// Sessione scaduta (401 o refresh fallito): pulisce il token e riporta al login.
  Future<void> handleUnauthorized() async {
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;
    try {
      stop();
      await AuthToken.clear();
      goToLogin();
    } finally {
      _handlingUnauthorized = false;
    }
  }

  /// Estrae la scadenza (claim `exp`) dal payload del JWT, se presente.
  DateTime? _tokenExpiry() {
    final token = AuthToken.token;
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      final exp = payload['exp'];
      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
    } catch (_) {
      // payload non decodificabile: si userà il fallback
    }
    return null;
  }
}
