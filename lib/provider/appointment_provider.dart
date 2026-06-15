import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../config.dart';
import '../service/api_client.dart';
import '../service/app_messenger.dart';
import '../model/appointment_model.dart';


final selectedDateProvider = StateProvider<DateTime?>((ref) {
  return DateTime.now(); // valore iniziale
});

class AppointmentState extends StateNotifier<List<Appointment>> {
  final Ref ref;
  AppointmentState(this.ref) : super([]);

  Future<void> addAppointment(Appointment appointment) async {
    try {
      final response = await ApiClient.post(
        '${AppConfig.baseUrl}/appointment',
        body: json.encode(appointment.toJson()),
      );
      final decodedResponse = json.decode(response.body);
      final newAppointment = Appointment.fromJson(decodedResponse);
      state = [...state, newAppointment];

      ref
          .read(appointmentGetProvider.notifier)
          .fetchAppointments(appointment.ptId);
    } on ApiException catch (e) {
      showAppError('Creazione appuntamento fallita: ${e.message}');
    }
  }

  Future<void> updateAppointment(Appointment appointment) async {
    try {
      final response = await ApiClient.put(
        '${AppConfig.baseUrl}/appointment/${appointment.appointmentId}',
        body: json.encode(appointment.toJson()),
      );
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
    } on ApiException catch (e) {
      showAppError('Aggiornamento appuntamento fallito: ${e.message}');
    }
  }

  Future<void> deleteAppointment(int appointmentId, int ptId) async {
    try {
      await ApiClient.delete(
        '${AppConfig.baseUrl}/appointment/$appointmentId',
      );
      state = state
          .where((appointment) => appointment.appointmentId != appointmentId)
          .toList();
      await ref.read(appointmentGetProvider.notifier).fetchAppointments(ptId);
    } on ApiException catch (e) {
      showAppError('Eliminazione appuntamento fallita: ${e.message}');
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
    try {
      final response = await ApiClient.get(
        '${AppConfig.baseUrl}/appointment/byUser/$userId',
      );
      final List<dynamic> data = json.decode(response.body);
      state = data.map((item) => AppointmentGet.fromJson(item)).toList();
      state.sort((a, b) => a.date.compareTo(b.date));
    } on ApiException catch (e) {
      showAppError('Appuntamenti: ${e.message}');
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
    try {
      final response = await ApiClient.get(
        '${AppConfig.baseUrl}/appointment/$appointmentId',
      );
      final data = json.decode(response.body);
      state = AppointmentGet.fromJson(data);
    } on ApiException catch (e) {
      showAppError('Appuntamento: ${e.message}');
      state = null;
    }
  }
}

// Provider Riverpod
final appointmentSingleProvider =
    StateNotifierProvider<AppointmentSingleState, AppointmentGet?>(
  (ref) => AppointmentSingleState(),
);
