import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WeeklyUsageChart extends StatelessWidget {
  final List<UsageData> data;

  const WeeklyUsageChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250, // Altezza del grafico
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            primaryYAxis: NumericAxis(
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries>[
              ColumnSeries<UsageData, String>(
                // Evita gli errori "disposed RenderObject"/"deactivated ancestor"
                // quando si naviga via mentre l'animazione del chart è attiva.
                animationDuration: 0,
                dataSource: data,
                xValueMapper: (UsageData usage, _) => usage.day,
                yValueMapper: (UsageData usage, _) => usage.usage,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
                color: Color(0XFFC4B7E1),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class UsageData {
  final String day;
  final double usage;

  UsageData(this.day, this.usage);
}
