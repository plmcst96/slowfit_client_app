import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/home/notification_page.dart';
import 'package:slowFit_client/home/trainer_home.dart';
import 'package:slowFit_client/provider/appointment_provider.dart';
import 'package:slowFit_client/provider/bottom_bar_provider.dart';
import 'package:slowFit_client/widget/custom_appbar.dart';
import 'package:slowFit_client/widget/custom_bottom_bar.dart';

import '../appointment/appointment_page.dart';
import '../l10n/app_localizations.dart';
import '../provider/login_provider.dart';
import '../provider/notification_provider.dart';
import '../provider/user_provider.dart';
import '../widget/calendar_horizontal.dart';
import 'home_appointment.dart';

class HomePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    _setupFCMListeners();

    // Aggiorna subito il token sul backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(updateFcmTokenProvider);
    });
  }

  void _setupFCMListeners() {
    // Notifica ricevuta mentre l'app è in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!mounted) return; // 🔹 Check mounted
      final title = message.notification?.title ?? 'Nuova notifica';
      final body = message.notification?.body ?? '';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title\n$body'),
          backgroundColor: Colors.blueAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    });

    // L'utente clicca su una notifica
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (!mounted) return; // 🔹 Check mounted
      final title = message.notification?.title ?? '';
      final body = message.notification?.body ?? '';

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    });
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access providers here instead of initState.
    final login = ref.watch(loginProvider);
    if (login.email != null) {
      ref.read(userProfileProvider.notifier).fetchUserByEmail(login.email!);
      ref
          .read(appointmentGetProvider.notifier)
          .fetchAppointments(login.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomBarProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    return Scaffold(
      appBar: CustomAppBar(
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final notifications = ref.watch(notificationProvider);
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_active_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NotificationsPage()),
                    ),
                  ),
                  if (notifications.isNotEmpty)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          notifications.length.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.12,
                child: HorizontalWeekCalendar(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AppointmentPage(selectedDate: selectedDate!),
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.app,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (selectedDate != null)
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.height *
                              0.16, // Imposta un'altezza adeguata
                          child: HomeAppointment(selectedDate: selectedDate),
                        ),
                      Row(
                        children: [
                          Text(
                            "L'allenamento di oggi",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Spacer(),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.all(
                                Radius.circular(40),
                              ),
                            ),
                            child: Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),
                      TrainerHome(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FloatingBottomBar(currentIndex: selectedIndex),
    );
  }
}
