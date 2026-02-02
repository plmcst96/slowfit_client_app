import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../appointment/detail_appointment_dialog.dart';
import '../provider/appointment_provider.dart';
import '../provider/login_provider.dart';

class HomeAppointment extends ConsumerStatefulWidget {
  const HomeAppointment({super.key, required this.selectedDate});

  final DateTime selectedDate;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HomeAppointmentState();
}

class _HomeAppointmentState extends ConsumerState<HomeAppointment> {
  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  @override
  void didUpdateWidget(covariant HomeAppointment oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _fetchAppointments();
    }
  }

  void _fetchAppointments() {
    final login = ref.read(loginProvider);
    if (login.userId != null) {
      ref
          .read(appointmentGetProvider.notifier)
          .fetchAppointments(login.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointments = ref.watch(appointmentGetProvider);

    final todayAppointments = appointments.where((appointment) {
      return DateUtils.isSameDay(
        DateTime.parse(appointment.date.toIso8601String()),
        widget.selectedDate,
      );
    }).toList();

    return todayAppointments.isNotEmpty
        ? SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: todayAppointments.length,
              itemBuilder: (context, index) {
                final appointment = todayAppointments[index];
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.70,
                  child: Card(
                    color: Color(0XFFC4B7E1),
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat(
                                  'dd MMM yy',
                                ).format(appointment.date),
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' - ',
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                DateFormat('HH:mm').format(appointment.date),
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),

                              Image.asset('assets/loghi/logo9.png', width: 17),
                            ],
                          ),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    appointment.description!,
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                              Spacer(),
                              if (appointment.date.isAfter(
                                    DateTime.now().subtract(Duration(days: 1)),
                                  ) ||
                                  appointment.date.isAtSameMomentAs(
                                    DateTime.now().subtract(Duration(days: 1)),
                                  ))
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) => AppointmentDetail(
                                        onClose: () {
                                          Navigator.pop(context);
                                          ref.watch(appointmentGetProvider);
                                        },
                                        appointmentId:
                                            appointment.appointmentId,
                                        // Chiude il BottomSheet
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Color(0XFFBAFFA5),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    width: 70,
                                    height: 25,
                                    child: Text(
                                      'More info',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        : Center(
            child: Column(
              children: [
                SizedBox(height: 20),
                Image.asset('assets/Appuntamento.png', width: 180,),
                const Text(
                  'Nessun appuntamento per la giornata selezionata!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
  }
}
