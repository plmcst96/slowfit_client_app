import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:slowFit_client/provider/user_provider.dart';

class ClientGoalChart extends ConsumerWidget {
  const ClientGoalChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(userProvider);

    // Generiamo valori fittizi casuali per i progressi
    final randomProgress = clients.map((client) {
      final progress = (50 + (client.hashCode % 50)).toDouble(); // tra 50 e 100
      return ClientGoalData(
        name: client.firstName,
        progress: progress,
      );
    }).toList();

    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  maximum: 100,
                  interval: 20,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),

                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  // mostra % nel tooltip
                  format: 'point.y%',
                ),
                series: <CartesianSeries>[
                  ColumnSeries<ClientGoalData, String>(
                    // Evita gli errori "disposed RenderObject"/"deactivated ancestor"
                    // quando si naviga via mentre l'animazione del chart è attiva.
                    animationDuration: 0,
                    dataSource: randomProgress,
                    xValueMapper: (ClientGoalData data, _) => data.name,
                    yValueMapper: (ClientGoalData data, _) => data.progress,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      // aggiunge il simbolo % ai valori nelle barre
                      builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                        return Text("${data.progress.toInt()}%");
                      },
                    ),
                    color: const Color(0XFFBAFFA5),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClientGoalData {
  final String name;
  final double progress;

  ClientGoalData({
    required this.name,
    required this.progress,
  });
}
