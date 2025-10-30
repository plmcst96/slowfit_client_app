import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../model/appointment_model.dart';


final selectedDateProvider = StateProvider<DateTime?>((ref) {
  return DateTime.now(); // valore iniziale
});

class AppointmentState extends StateNotifier<List<Appointment>> {
  final Ref ref;
  AppointmentState(this.ref) : super([]);

  Future<void> addAppointment(Appointment appointment) async {
    final url = Uri.parse('${AppConfig.baseUrl}/appointment');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': '${AppConfig.slowKey}'
        },
        body: json.encode(appointment.toJson()),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        final newAppointment = Appointment.fromJson(decodedResponse);

        state = [...state, newAppointment];

        ref
            .read(appointmentGetProvider.notifier)
            .fetchAppointments(appointment.ptId);
      } else {
        throw Exception('Failed to add appointment');
      }
    } catch (e) {
      print('Error adding appointment: $e');
    }
  }

  Future<void> updateAppointment(Appointment appointment) async {
    final url = Uri.parse(
        '${AppConfig.baseUrl}/appointment/${appointment.appointmentId}'); // Aggiungi l'ID dell'appuntamento nell'URL

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': '${AppConfig.slowKey}'
        },
        body: json.encode(appointment.toJson()),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        final updatedAppointment = Appointment.fromJson(decodedResponse);

        // Sostituiamo l'appuntamento aggiornato nella lista
        state = state.map((apt) {
          return apt.appointmentId == updatedAppointment.appointmentId
              ? updatedAppointment
              : apt;
        }).toList();

        // Ricarichiamo gli appuntamenti dal provider
        await ref
            .read(appointmentGetProvider.notifier)
            .fetchAppointments(appointment.ptId);
      } else {
        throw Exception('Failed to update appointment');
      }
    } catch (e) {
      print('Error updating appointment: $e');
    }
  }

  Future<void> deleteAppointment(int appointmentId, int ptId) async {
    final url = Uri.parse('${AppConfig.baseUrl}/appointment/$appointmentId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': '${AppConfig.slowKey}'
        },
      );

      if (response.statusCode == 200) {
        state = state
            .where((appointment) => appointment.appointmentId != appointmentId)
            .toList();
        await ref.read(appointmentGetProvider.notifier).fetchAppointments(ptId);
      } else {
        throw Exception('Failed to delete appointment');
      }
    } catch (e) {
      print('Error deleting appointment: $e');
    }
  }
}

// Provider Riverpod
final appointmentProvider =
StateNotifierProvider<AppointmentState, List<Appointment>>(
      (ref) => AppointmentState(ref),
);

class AppointmentGetState extends StateNotifier<List<AppointmentGet>> {
  AppointmentGetState() : super([]);

  Future<void> fetchAppointments(int userId) async {
    final url = Uri.parse('${AppConfig.baseUrl}/appointment/byUser/$userId');

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

        state = data.map((item) => AppointmentGet.fromJson(item)).toList();
        state.sort((a, b) => a.date.compareTo(b.date));
      } else {
        state = [];
      }
    } catch (e) {
      print("Errore di rete: $e");
      state = [];
    }
  }
}

// Provider Riverpod
final appointmentGetProvider =
    StateNotifierProvider<AppointmentGetState, List<AppointmentGet>>(
  (ref) => AppointmentGetState(),
);

class AppointmentSingleState extends StateNotifier<AppointmentGet?> {
  AppointmentSingleState() : super(null);

  Future<void> fetchSingleAppointment(int appointmentId) async {
    final url = Uri.parse('${AppConfig.baseUrl}/appointment/$appointmentId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'slowKey': '${AppConfig.slowKey}'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        state = AppointmentGet.fromJson(data);
      } else {
        state = null;
      }
    } catch (e) {
      print("Errore di rete: $e");
      state = null;
    }
  }
}

// Provider Riverpod
final appointmentSingleProvider =
    StateNotifierProvider<AppointmentSingleState, AppointmentGet?>(
  (ref) => AppointmentSingleState(),
);
