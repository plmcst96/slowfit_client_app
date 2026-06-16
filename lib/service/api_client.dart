import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'auth_session.dart';
import 'auth_token.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  static const Duration _timeout = Duration(seconds: 15);

  static Map<String, String> _headers([Map<String, String>? extra]) {
    final token = AuthToken.token;
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      if (extra != null) ...extra,
    };
  }

  static Future<http.Response> get(String url, {Map<String, String>? headers}) =>
      _send(() => http.get(Uri.parse(url), headers: _headers(headers)));

  static Future<http.Response> post(
    String url, {
    Object? body,
    Map<String, String>? headers,
  }) =>
      _send(() => http.post(Uri.parse(url), headers: _headers(headers), body: body));

  static Future<http.Response> put(
    String url, {
    Object? body,
    Map<String, String>? headers,
  }) =>
      _send(() => http.put(Uri.parse(url), headers: _headers(headers), body: body));

  static Future<http.Response> delete(
    String url, {
    Object? body,
    Map<String, String>? headers,
  }) =>
      _send(() => http.delete(Uri.parse(url), headers: _headers(headers), body: body));

  static Future<http.Response> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request().timeout(_timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }
      if (response.statusCode == 401) {
        // Sessione scaduta/non valida: pulisce il token e riporta al login.
        unawaited(AuthSession.instance.handleUnauthorized());
      }
      throw ApiException(
        _messageFromResponse(response),
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException(
        'Impossibile contattare il server. Verifica la connessione e che il backend sia attivo.',
      );
    } on TimeoutException {
      throw ApiException('Il server non risponde (timeout). Riprova più tardi.');
    } on http.ClientException catch (e) {
      throw ApiException('Errore di rete: ${e.message}');
    } on FormatException {
      throw ApiException('Risposta del server non valida.');
    } catch (e) {
      throw ApiException('Errore imprevisto: $e');
    }
  }

  /// Decodifica il body come lista, gestendo body vuoto.
  static List<dynamic> decodeList(http.Response response) {
    final body = response.body.trim();
    if (body.isEmpty) return const [];
    final decoded = jsonDecode(body);
    return decoded is List ? decoded : const [];
  }

  /// Decodifica il body come oggetto, gestendo body vuoto / oggetto vuoto.
  /// Restituisce null se il body è vuoto (nessun risultato).
  static Map<String, dynamic>? decodeMap(http.Response response) {
    final body = response.body.trim();
    if (body.isEmpty) return null;
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded.isEmpty ? null : decoded;
    }
    return null;
  }

  static String _messageForStatus(int code) {
    switch (code) {
      case 400:
        return 'Richiesta non valida (400).';
      case 401:
        return 'Non autorizzato (401). Effettua di nuovo il login.';
      case 403:
        return 'Accesso negato (403).';
      case 404:
        return 'Risorsa non trovata (404).';
      case 500:
        return 'Errore interno del server (500).';
      default:
        return 'Errore del server ($code).';
    }
  }

  static String _messageFromResponse(http.Response response) {
    final body = response.body.trim();
    if (body.isEmpty) return _messageForStatus(response.statusCode);

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }

        final title = decoded['title'];
        if (title is String && title.trim().isNotEmpty) {
          return title.trim();
        }

        final errors = decoded['errors'];
        if (errors is Map<String, dynamic> && errors.isNotEmpty) {
          final messages = errors.values
              .expand((value) => value is List ? value : [value])
              .whereType<String>()
              .where((value) => value.trim().isNotEmpty)
              .toList();
          if (messages.isNotEmpty) return messages.join('\n');
        }
      }

      if (decoded is String && decoded.trim().isNotEmpty) {
        return decoded.trim();
      }
    } catch (_) {
      if (!body.startsWith('<') && body.length <= 200) return body;
    }

    return _messageForStatus(response.statusCode);
  }
}
