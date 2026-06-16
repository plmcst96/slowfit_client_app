import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slowFit_client/client/add_client.dart';
import 'package:slowFit_client/client/client_detail.dart';
import 'package:slowFit_client/provider/bottom_bar_provider.dart';
import 'package:slowFit_client/provider/user_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../provider/login_provider.dart';

class HomeClient extends ConsumerStatefulWidget {
  const HomeClient({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _HomeClientState();
  }
}

class _HomeClientState extends ConsumerState<HomeClient> {
  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() {
    final login = ref.read(loginProvider);
    if (login.userId != null) {
      ref.read(userProvider.notifier).fetchUserByPtId(login.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(userProvider);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/trainer-clients');
      },
      child: Container(
        padding: EdgeInsets.all(10),
        child: users.isNotEmpty
            ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final List<_ChartData> chartData = <_ChartData>[
                    _ChartData('Allenamenti', 80, Colors.black54),
                    _ChartData('Kg Persi', 50, Color(0XFF9A91AD)),
                    _ChartData('Cm Persi', 40, Color(0XFFC4B7E1)),
                    _ChartData('Gradimento', 90, Colors.pink[300]!),
                  ];

                  return GestureDetector(
                    onTap: () {
                      ref.read(bottomBarProvider.notifier).updateIndex(3);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ClientDetail(clientId: user.userId),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.90,
                      child: Card(
                        color: Color(0XFFE0F6DA),
                        margin:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/illustration_avatar.png',
                                    width: 80,
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${user.firstName} ${user.surname}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        user.email,
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                35),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        user.phone!,
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                35),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(height: 20),
                              Text('Progressi Mensili',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: chartData
                                        .map((data) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4.0),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 12,
                                                    height: 12,
                                                    decoration: BoxDecoration(
                                                      color: data.color,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "${data.x}: ${data.y}%",
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: SizedBox(
                                      width: 100,
                                      height: 150,
                                      child: SfCircularChart(
                                        series: <CircularSeries<_ChartData,
                                            String>>[
                                          RadialBarSeries<_ChartData, String>(
                                            // Evita il crash "disposed RenderObject
                                            // was mutated" quando la card viene
                                            // ricostruita/distrutta durante l'animazione.
                                            animationDuration: 0,
                                            trackColor: Colors.transparent,
                                            maximumValue: 100,
                                            radius: '100%',
                                            gap: '5%',
                                            dataSource: chartData,
                                            cornerStyle: CornerStyle.bothCurve,
                                            xValueMapper:
                                                (_ChartData data, _) => data.x,
                                            yValueMapper:
                                                (_ChartData data, _) => data.y,
                                            pointColorMapper:
                                                (_ChartData data, _) =>
                                                    data.color,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                })
            : Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Nessun utente da seguire!'),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await showModalBottomSheet<void>(
                          context: context,
                          sheetAnimationStyle: const AnimationStyle(
                            duration: Duration(seconds: 3),
                            reverseDuration: Duration(seconds: 1),
                          ),
                          builder: (BuildContext context) {
                            return SizedBox.expand(
                              child: AddClient(),
                            );
                          },
                        );
                        _fetchUsers();
                      },
                      child: Text('Inizia qui'),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}
