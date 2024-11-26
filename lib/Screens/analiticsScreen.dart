import 'package:diet_management_suppport_app/widgets/barChart.dart';
import 'package:diet_management_suppport_app/widgets/circuralChart.dart';
import 'package:diet_management_suppport_app/widgets/linearChart.dart';
import 'package:flutter/material.dart';

class AnaliticsScreen extends StatefulWidget {
  const AnaliticsScreen({super.key});

  @override
  State<AnaliticsScreen> createState() => _AnaliticsScreenState();
}

class _AnaliticsScreenState extends State<AnaliticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Chart(), BarChartSample3(), LineChartSample2()],
          ),
        ),
      ),
    );
  }
}
