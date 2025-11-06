import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../model/appointment_model.dart';
import '../provider/appointment_provider.dart';
import '../provider/bottom_bar_provider.dart';
import '../widget/custom_bottom_bar.dart';
import 'bottom_sheet_appointment.dart';
import 'detail_appointment_dialog.dart';

class AppointmentPage extends ConsumerStatefulWidget {
  const AppointmentPage({super.key, required this.selectedDate});
  final DateTime selectedDate;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AppointmentPageState();
  }
}

class _AppointmentPageState extends ConsumerState<AppointmentPage> {
  bool isOpen = false;
  bool _isToday = true;

  void toggleBottomSheet() {
    setState(() {
      isOpen = true;
    });
    if (isOpen) {
      showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => BottomSheetAppointment(
          onClose: () {
            setState(() {
              isOpen = false;
            });
            ref.watch(appointmentGetProvider);
          },
          // Chiude il BottomSheet
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomBarProvider);
    final appointments = ref.watch(appointmentGetProvider);

    final today = DateTime.now();

    final todayAppointments = appointments.where((appointment) {
      return DateUtils.isSameDay(
        DateTime.parse(appointment.date.toIso8601String()),
        widget.selectedDate,
      );
    }).toList();

    //Group today appointments
    final morningAppointments = todayAppointments
        .where((a) => a.date.hour < 12)
        .toList();
    final afternoonAppointments = todayAppointments
        .where((a) => a.date.hour >= 12 && a.date.hour < 18)
        .toList();
    final eveningAppointments = todayAppointments
        .where((a) => a.date.hour >= 18)
        .toList();

    // Filter out past appointments
    final filteredAppointments = appointments.where((appointment) {
      return appointment.date.isAfter(today.subtract(Duration(days: 1))) ||
          DateUtils.isSameDay(appointment.date, today);
    }).toList();

    // Group appointments by date for non-today dates
    Map<String, List<AppointmentGet>> groupedAppointments = {};
    if (!_isToday) {
      for (var appointment in filteredAppointments) {
        final dateString = DateFormat('dd/MM/yyyy').format(appointment.date);
        if (!groupedAppointments.containsKey(dateString)) {
          groupedAppointments[dateString] = [];
        }
        groupedAppointments[dateString]!.add(appointment);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
                icon: Icon(Icons.arrow_back_ios),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isToday = true;
                        });
                      },
                      child: Card(
                        color: Colors.black,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                  const Spacer(),
                                  Text(
                                    todayAppointments.length.toString(),
                                    style: TextStyle(
                                      color: Color(0XFFBAFFA5),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Oggi',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isToday = false;
                        });
                      },
                      child: Card(
                        color: Colors.black,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                  const Spacer(),
                                  Text(
                                    filteredAppointments.length.toString(),
                                    style: TextStyle(
                                      color: Color(0XFFBAFFA5),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Programmati',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              GestureDetector(
                onTap: toggleBottomSheet,
                child: Container(
                  padding: EdgeInsets.all(7),
                  width: MediaQuery.of(context).size.width * 0.60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0XFFC4B7E1), width: 1.5),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline_outlined,
                        color: Color(0XFFC4B7E1),
                      ),
                      SizedBox(width: 15),
                      Text(
                        AppLocalizations.of(context)!.app2,
                        style: TextStyle(
                          color: Color(0XFFC4B7E1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Text(
                    _isToday
                        ? 'Appuntamenti di Oggi'
                        : 'Appuntamenti Programmati',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _isToday
                  ? Expanded(
                      child: ListView(
                        children: [
                          _buildAppointmentSection(
                            "Mattina",
                            morningAppointments,
                          ),
                          _buildAppointmentSection(
                            "Pomeriggio",
                            afternoonAppointments,
                          ),
                          _buildAppointmentSection("Sera", eveningAppointments),
                        ],
                      ),
                    )
                  : Expanded(
                      child: ListView(
                        children: groupedAppointments.entries.map((entry) {
                          final dateStr = entry.key;
                          final grouped = entry.value;
                          final morning = grouped
                              .where((a) => a.date.hour < 12)
                              .toList();
                          final afternoon = grouped
                              .where(
                                (a) => a.date.hour >= 12 && a.date.hour < 18,
                              )
                              .toList();
                          final evening = grouped
                              .where((a) => a.date.hour >= 18)
                              .toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateStr,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0XFF9A91AD),
                                ),
                              ),
                              SizedBox(height: 20),
                              _buildAppointmentSection("Mattina", morning),
                              _buildAppointmentSection("Pomeriggio", afternoon),
                              _buildAppointmentSection("Sera", evening),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FloatingBottomBar(currentIndex: selectedIndex),
    );
  }

  Widget _buildAppointmentSection(String title, List appointments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        if (appointments.isEmpty) const Text("Nessun appuntamento"),
        ...appointments.map(
          (appointment) => GestureDetector(
            onTap: () {
              showModalBottomSheet(
                backgroundColor: Colors.white,
                context: context,
                isScrollControlled: true,
                builder: (context) => AppointmentDetail(
                  onClose: () {
                    Navigator.pop(context);
                    ref.watch(appointmentGetProvider);
                  },
                  appointmentId: appointment.appointmentId,
                  // Chiude il BottomSheet
                ),
              );
            },
            child: ListTile(
              title: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.circleCheck,
                    color: Color(0XFFBAFFA5),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(appointment.description),
                ],
              ),
              subtitle: Text(
                DateFormat('HH:mm').format(appointment.date).padLeft(2),
              ),
            ),
          ),
        ),
        if (appointments.isEmpty) SizedBox(height: 10),
        const Divider(),
      ],
    );
  }
}
