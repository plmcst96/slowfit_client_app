import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:slowFit_client/model/measure_model.dart';
import 'package:slowFit_client/provider/measure_provider.dart';
import 'package:slowFit_client/training/measure_page.dart';
import 'package:slowFit_client/training/tab_item.dart';
import 'package:slowFit_client/widget/custom_bottom_bar.dart';

import '../home/notification_page.dart';
import '../provider/bottom_bar_provider.dart';
import '../provider/login_provider.dart';
import '../provider/notification_provider.dart';
import '../provider/user_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with TickerProviderStateMixin {
  bool _initialized = false;
  double progress = 0.00;
  late TabController _tabController;
  late TabController _tabController1;
  bool expanded = false;
  late int userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController1 = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {}); // aggiorna UI quando cambi tab
    });

    _tabController1.addListener(() {
      final userId = ref.read(loginProvider).userId!;
      final measureNotifier = ref.read(measureAllProvider.notifier);

      if (_tabController1.index == 0) {
        measureNotifier.fetchMeasureFromStart(userId);
      } else if (_tabController1.index == 1) {
        measureNotifier.fetchMeasureFromMonth(userId);
      } else if (_tabController1.index == 2) {
        measureNotifier.fetchMeasureFromWeek(userId);
      }
    });

    Future.microtask(() {
      ref.read(bodyPartProvider.notifier).fetchBodyPart();
      ref.read(measureAllProvider.notifier).fetchAllMeasure(userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabController1.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final login = ref.watch(loginProvider);

      if (login.email != null) {
        ref.read(userProfileProvider.notifier).fetchUserByEmail(login.email!);
      }

      if (login.userId != null) {
        userId = login.userId!; //  <-- SALVA QUI LO USER ID
      }

      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomBarProvider);
    final user = ref.watch(userProfileProvider);
    final measure = ref.watch(measureAllProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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
                  Text(
                    'Profilo',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Spacer(),
                  Consumer(
                    builder: (context, ref, _) {
                      final notifications = ref.watch(notificationsProvider);
                      return Stack(
                        children: [
                          IconButton(
                            icon: Icon(Icons.notifications_active_outlined),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NotificationsPage(),
                              ),
                            ),
                          ),
                          if (notifications.isNotEmpty)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                width: 20,
                                height: 20,
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  notifications.length.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.pink, width: 4),
                        ),
                        child: CircleAvatar(
                          radius: 65,
                          backgroundImage: AssetImage('assets/avatar_pt.jpg'),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${user!.firstName} ${user.surname}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 20),
                      GridView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 3 / 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        children: [
                          Card(
                            color: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.dumbbell,
                                        color: Colors.pink[300],
                                        size: 20,
                                      ),
                                      Spacer(),

                                      SizedBox(
                                        height: 45,
                                        width: 45,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              value: progress,
                                              strokeWidth: 4,
                                              backgroundColor:
                                                  Colors.grey.shade300,
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                    Color
                                                  >(Colors.pink),
                                            ),
                                            Text(
                                              '${(progress * 100).toInt()}%',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Vedi i tuoi',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    'progressi di allenamento',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            color: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.appleWhole,
                                        color: Colors.pink[300],
                                        size: 20,
                                      ),
                                      Spacer(),

                                      SizedBox(
                                        height: 45,
                                        width: 45,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              value: progress,
                                              strokeWidth: 4,
                                              backgroundColor:
                                                  Colors.grey.shade300,
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                    Color
                                                  >(Colors.pink),
                                            ),
                                            Text(
                                              '${(progress * 100).toInt()}%',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Vedi il tuo',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: Text(
                                      'progresso nutrizionale',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          color: Colors.white,
                          elevation: 4,
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Statistiche',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    height: 40,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.pink[200],
                                    ),
                                    child: TabBar(
                                      controller:
                                          _tabController, // <- collega il TabController
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      dividerColor: Colors.transparent,
                                      indicator: BoxDecoration(
                                        color: Colors.pink,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      labelColor: Colors.white,
                                      labelStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      unselectedLabelColor: Colors.black,
                                      tabs: [
                                        TabItem(title: "Dall'inizio"),
                                        TabItem(title: 'Mese'),
                                        TabItem(title: 'Settimana'),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                SizedBox(
                                  height: 120,
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      _buildStatsGrid(0), // tab "Dall'inizio"
                                      _buildStatsGrid(1), // tab "Mese"
                                      _buildStatsGrid(2), // tab "Settimana"
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Card(
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            // HEADER CON FRECCIA
                            GestureDetector(
                              onTap: () {
                                setState(() => expanded = !expanded);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Le tue misure',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: expanded ? 18 : 14,
                                        ),
                                      ),
                                    ),
                                    AnimatedRotation(
                                      turns: expanded ? 0.5 : 0,
                                      duration: Duration(milliseconds: 5),
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // CONTENUTO ESPANDIBILE
                            AnimatedCrossFade(
                              firstChild: SizedBox.shrink(),
                              secondChild: Padding(
                                padding: EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        height: 40,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          color: Colors.pink[200],
                                        ),
                                        child: TabBar(
                                          controller:
                                              _tabController1, // <- collega il TabController
                                          indicatorSize:
                                              TabBarIndicatorSize.tab,
                                          dividerColor: Colors.transparent,
                                          indicator: BoxDecoration(
                                            color: Colors.pink,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          labelColor: Colors.white,
                                          labelStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          unselectedLabelColor: Colors.black,
                                          tabs: [
                                            TabItem(title: "Dall'inizio"),
                                            TabItem(title: 'Mese'),
                                            TabItem(title: 'Settimana'),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight:
                                            250, // massimo spazio verticale che vuoi dare
                                      ),
                                      child: TabBarView(
                                        controller: _tabController1,
                                        children: [
                                          _buildStatsGridMeasure(
                                            0,
                                            measure,
                                            ref,
                                          ), // Dall’inizio
                                          _buildStatsGridMeasure(
                                            1,
                                            measure,
                                            ref,
                                          ), // Mese
                                          _buildStatsGridMeasure(
                                            2,
                                            measure,
                                            ref,
                                          ), // Settimana
                                        ],
                                      ),
                                    ),
                                    Card(
                                      color: Colors.white,
                                      elevation: 3,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MeasurePage(
                                                measure: measure,
                                                userId: user.userId,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(15),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Aggiorna le misure',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Spacer(),
                                              Icon(
                                                Icons
                                                    .arrow_forward_ios_outlined,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              crossFadeState: expanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: Duration(milliseconds: 5),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Card(
                        color: Colors.white,
                        elevation: 3,
                        child: GestureDetector(
                          onTap: () {
                            ref.read(loginProvider.notifier).logout();
                          },
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Row(
                              children: [
                                Text(
                                  'Esci',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                Spacer(),
                                Icon(Icons.logout_outlined, color: Colors.red),
                              ],
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildStatsGrid(int index) {
    List<Map<String, String>> data;

    if (index == 0) {
      data = [
        {"value": "0", "label": "Allenamenti completati"},
        {"value": "1", "label": "Pasti mangiati"},
        {"value": "1", "label": "Giorni di accesso"},
      ];
    } else if (index == 1) {
      data = [
        {"value": "2", "label": "Allenamenti del mese"},
        {"value": "15", "label": "Pasti del mese"},
        {"value": "20", "label": "Giorni attivi"},
      ];
    } else {
      data = [
        {"value": "1", "label": "Allenamenti settimana"},
        {"value": "5", "label": "Pasti settimana"},
        {"value": "6", "label": "Giorni attivi"},
      ];
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: data.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3 / 2.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) {
        return Card(
          color: Colors.white,
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data[i]["value"]!,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 7),
                Text(
                  data[i]["label"]!,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildStatsGridMeasure(int index, List<Measure> data, WidgetRef ref) {
  final bodyPart = ref.watch(bodyPartProvider);

  if (data.isEmpty) {
    return Center(
      child: Text(
        "Nessun dato disponibile",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  // In base al tab scegli quali misure prendere
  // Puoi filtrare per data se vuoi
  List<Measure> filtered = data; // per ora tutte

  return GridView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: filtered.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      childAspectRatio: 3 / 2.8,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
    ),
    itemBuilder: (_, i) {
      if (bodyPart.isEmpty || index >= bodyPart.length) {
        return Center(
          child: Text(
            "Nessuna parte del corpo disponibile",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        );
      }
      final body = bodyPart[i];

      final m = filtered[i];

      return Card(
        color: Colors.white,
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${m.cm} ${body.bodyPartId == 13 ? 'kg' : 'cm'}", // valore della misura
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 7),
              Text(
                body.bodyPartName, // nome misura es: "Circonferenza vita"
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    },
  );
}
