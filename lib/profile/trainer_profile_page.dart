import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/profile/client_goal_chart.dart';
import 'package:slowFit_client/profile/weekly_usage_chart.dart';
import 'package:slowFit_client/provider/login_provider.dart';
import 'package:slowFit_client/provider/nutrition_provider.dart';
import 'package:slowFit_client/provider/training_provider.dart';
import 'package:slowFit_client/provider/user_provider.dart';

import '../provider/appointment_provider.dart';
import '../provider/bottom_bar_provider.dart';
import '../widget/custom_bottom_bar.dart';

class TrainerProfilePage extends ConsumerStatefulWidget {
  const TrainerProfilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _TrainerProfilePageState();
  }
}

class _TrainerProfilePageState extends ConsumerState<TrainerProfilePage> {
  bool _initialized = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.microtask(() {
      ref.read(nutritionProvider.notifier).fetchNutritions();
    });

    Future.microtask(() {
      ref.read(trainingProvider.notifier).getAllTrainings();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final user = ref.watch(loginProvider); // usa solo i dati già disponibili
      if (user.email != null) {
        ref.read(userProfileProvider.notifier).fetchUserByEmail(user.email!);
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomBarProvider);
    final user = ref.watch(userProfileProvider);
    final client = ref.watch(userProvider);
    final appointments = ref.watch(appointmentGetProvider);
    final nutrition = ref.watch(nutritionProvider);
    final training = ref.watch(trainingProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/home');
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Colors.black,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.notifications_active_outlined,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0XFFBAFFA5),
                    width: 4,
                  ),
                ),
                child: CircleAvatar(
                  radius: 65,
                  backgroundImage: AssetImage('assets/avatar_pt.jpg'),
                  backgroundColor: Colors.transparent,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                '${user!.firstName} ${user.surname}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {},
                              child: Card(
                                color: Colors.black,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.people_outline,
                                            size: 30,
                                            color: Colors.white,
                                          ),
                                          const Spacer(),
                                          Text(
                                            client.length.toString(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'Clienti',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {},
                              child: Card(
                                color: Color(0XFFC4B7E1),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_month_outlined,
                                            size: 30,
                                            color: Colors.black,
                                          ),
                                          const Spacer(),
                                          Text(
                                            appointments.length.toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'Appuntamenti',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/nutrition');
                                ref
                                    .read(bottomBarProvider.notifier)
                                    .updateIndex(2);
                              },
                              child: Card(
                                color: Color(0XFFBAFFA5),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.emoji_food_beverage_outlined,
                                            size: 30,
                                            color: Colors.black,
                                          ),
                                          const Spacer(),
                                          Text(
                                            nutrition.length.toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'Nutrizione',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {},
                              child: Card(
                                color: Colors.white,
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.sports_gymnastics_outlined,
                                            size: 30,
                                            color: Colors.black,
                                          ),
                                          const Spacer(),
                                          Text(
                                            training.length.toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'Allenamenti',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Frequenza utilizzo App',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            "Mostra l'utilizzo giornaliero e settimanale dell'app."),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      WeeklyUsageChart(
                        data: [
                          UsageData('Lun', 30),
                          UsageData('Mar', 50),
                          UsageData('Mer', 40),
                          UsageData('Gio', 60),
                          UsageData('Ven', 20),
                          UsageData('Sab', 80),
                          UsageData('Dom', 55),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Obiettivi raggiunti',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                          "Vengono mostrati gli utenti che hanno raggiunto l'obiettivo prefissato, e il livello degli altri utenti."),
                      SizedBox(
                        height: 20,
                      ),
                      ClientGoalChart()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: selectedIndex,
      ),
    );
  }
}
