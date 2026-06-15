import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';

import '../config.dart';
import '../service/api_client.dart';
import '../service/app_messenger.dart';
import '../model/measure_model.dart';

class BodyPartState extends StateNotifier<List<BodyPart>> {
  BodyPartState() : super([]);

  Future<void> fetchBodyPart() async {
    try {
      final response = await ApiClient.get('${AppConfig.baseUrl}/bodypart');
      final List<dynamic> data = json.decode(response.body);
      state = data.map((item) => BodyPart.fromJson(item)).toList();
    } on ApiException catch (e) {
      showAppError('Parti del corpo: ${e.message}');
      state = [];
    }
  }
}

final bodyPartProvider = StateNotifierProvider<BodyPartState, List<BodyPart>>(
    (ref) => BodyPartState());

class MeasureState extends StateNotifier<List<MeasureAdd>> {
  MeasureState() : super([]);

  Future<void> saveMeasure(MeasureAdd measure) async {
    try {
      final response = await ApiClient.post(
        '${AppConfig.baseUrl}/measure',
        body: json.encode(measure.toJson()),
      );
      final decodedResponse = json.decode(response.body);
      // Ricreo la misura ritornata dal server
      final newMeasure = MeasureAdd.fromJson(decodedResponse);
      // Aggiorno il provider locale
      state = [...state, newMeasure];
    } on ApiException catch (e) {
      showAppError('Salvataggio misura fallito: ${e.message}');
    }
  }
}

final measureProvider = StateNotifierProvider<MeasureState, List<MeasureAdd>>(
    (ref) => MeasureState());

class MeasureAllState extends StateNotifier<List<Measure>> {
  MeasureAllState() : super([]);

  // 🔄 Recupera tutte le misure di un utente
  Future<void> fetchAllMeasure(int userId) async {
    try {
      final response =
          await ApiClient.get('${AppConfig.baseUrl}/measure/byUser/$userId');
      final List<dynamic> data = json.decode(response.body);
      state = data.map((item) => Measure.fromJson(item)).toList();
    } on ApiException catch (e) {
      showAppError('Misure: ${e.message}');
      state = [];
    }
  }

  // 📌 NUOVA FUNZIONE — range generico
  Future<void> fetchMeasureByDateRange(
      int userId, DateTime start, DateTime end) async {
    final url = '${AppConfig.baseUrl}/measure/byDateRange/$userId'
        '?startDate=${start.toIso8601String().substring(0, 10)}'
        '&endDate=${end.toIso8601String().substring(0, 10)}';

    try {
      final response = await ApiClient.get(url);
      final List<dynamic> data = json.decode(response.body);
      state = data.map((item) => Measure.fromJson(item)).toList();
    } on ApiException catch (e) {
      showAppError('Misure: ${e.message}');
      state = [];
    }
  }

  // 🟣 DALL'INIZIO — (recuperiamo tutto)
  Future<void> fetchMeasureFromStart(int userId) async {
    await fetchAllMeasure(userId);
  }

  // 🟡 SOLO QUESTO MESE
  Future<void> fetchMeasureFromMonth(int userId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);

    await fetchMeasureByDateRange(userId, start, end);
  }

  // 🟢 SOLO QUESTA SETTIMANA
  Future<void> fetchMeasureFromWeek(int userId) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1)); // Lunedì
    final end = start.add(Duration(days: 6)); // Domenica

    await fetchMeasureByDateRange(userId, start, end);
  }
}

final measureAllProvider =
    StateNotifierProvider<MeasureAllState, List<Measure>>(
        (ref) => MeasureAllState());
