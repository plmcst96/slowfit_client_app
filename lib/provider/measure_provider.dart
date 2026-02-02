import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../model/measure_model.dart';

class BodyPartState extends StateNotifier<List<BodyPart>> {
  BodyPartState() : super([]);

  Future<void> fetchBodyPart() async {
    final url = Uri.parse('${AppConfig.baseUrl}/bodypart');
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
        state = data.map((item) => BodyPart.fromJson(item)).toList();
      } else {
        state = [];
        print('Failed to fetch body part');
      }
    } catch (e) {
      print('Error fetching body part: $e');
      state = [];
    }
  }
}

final bodyPartProvider = StateNotifierProvider<BodyPartState, List<BodyPart>>(
    (ref) => BodyPartState());

class MeasureState extends StateNotifier<List<MeasureAdd>> {
  MeasureState() : super([]);

  Future<void> saveMeasure(MeasureAdd measure) async {
    final url = Uri.parse('${AppConfig.baseUrl}/measure');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': AppConfig.slowKey,
        },
        body: json.encode(measure.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedResponse = json.decode(response.body);

        // Ricreo il training ritornato dal server
        final newMeasure = MeasureAdd.fromJson(decodedResponse);

        // Aggiorno il provider locale
        state = [...state, newMeasure];
      } else {
        throw Exception(
            'Errore nel salvataggio della misura: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore nel salvataggio della misura: $e');
    }
  }
}

final measureProvider = StateNotifierProvider<MeasureState, List<MeasureAdd>>(
    (ref) => MeasureState());

class MeasureAllState extends StateNotifier<List<Measure>> {
  MeasureAllState() : super([]);

  // 🔄 Recupera tutte le misure di un utente
  Future<void> fetchAllMeasure(int userId) async {
    final url = Uri.parse('${AppConfig.baseUrl}/measure/byUser/$userId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': AppConfig.slowKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        state = data.map((item) => Measure.fromJson(item)).toList();
      } else {
        state = [];
        print('Failed to fetch measure');
      }
    } catch (e) {
      print('Error fetching measure: $e');
      state = [];
    }
  }

  // 📌 NUOVA FUNZIONE — range generico
  Future<void> fetchMeasureByDateRange(
      int userId, DateTime start, DateTime end) async {
    final url = Uri.parse(
      '${AppConfig.baseUrl}/measure/byDateRange/$userId'
          '?startDate=${start.toIso8601String().substring(0, 10)}'
          '&endDate=${end.toIso8601String().substring(0, 10)}',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': AppConfig.slowKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        state = data.map((item) => Measure.fromJson(item)).toList();
      } else {
        print("No data in this range");
        state = [];
      }
    } catch (e) {
      print("Error fetching measure range: $e");
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
