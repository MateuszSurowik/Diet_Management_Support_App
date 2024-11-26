import 'package:diet_management_suppport_app/models/userLimits.dart';
import 'package:diet_management_suppport_app/services/firebaseClient.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({super.key});

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  double val1 = 0;
  double val2 = 0;
  double val3 = 0;
  double val4 = 0;
  double val5 = 0;
  double val6 = 0;
  double val7 = 0;

  bool dataLoaded = false;

  List<Color> gradientColors = [Colors.blue, Colors.cyan, Colors.green];
  bool showAvg = false;

  double waterCalculation(List<bool> water) {
    double liters = 0;
    water.forEach((item) {
      if (item == true) {
        liters += 0.25;
      }
    });
    return liters;
  }

  void loadGlassesForLast7Days(String userId) async {
    Firebaseclient firebaseClient = Firebaseclient();

    void onGlassesLoaded(int dayIndex, List<bool> glasses) {
      double val = waterCalculation(glasses);
      print('Day $dayIndex, Water: $val');

      switch (dayIndex) {
        case 0:
          val1 = val;
          break;
        case 1:
          val2 = val;
          break;
        case 2:
          val3 = val;
          break;
        case 3:
          val4 = val;
          break;
        case 4:
          val5 = val;
          break;
        case 5:
          val6 = val;
          break;
        case 6:
          val7 = val;
          break;
      }

      if (dayIndex == 6) {
        setState(() {
          dataLoaded = true;
        });
        print('Values after loading all days:');
        print(
            'Val1: $val1, Val2: $val2, Val3: $val3, Val4: $val4, Val5: $val5, Val6: $val6, Val7: $val7');
      }
    }

    for (int i = 0; i < 7; i++) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      await firebaseClient.loadGlassesForDate(
        userId: userId,
        date: date,
        onGlassesLoaded: (List<bool> glasses) {
          onGlassesLoaded(i, glasses);
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadGlassesForLast7Days(userId); // Load data on start
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.70,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 18,
                left: 12,
                top: 24,
                bottom: 12,
              ),
              child: dataLoaded
                  ? LineChart(
                      showAvg ? avgData() : mainData(),
                    )
                  : Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData mainData() {
    List<FlSpot> exampleData = [
      FlSpot(0, val1),
      FlSpot(1, val2),
      FlSpot(2, val3),
      FlSpot(3, val4),
      FlSpot(4, val5),
      FlSpot(5, val6),
      FlSpot(6, val7),
    ];
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.blue,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.cyan,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 5,
      lineBarsData: [
        LineChartBarData(
          spots: exampleData,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return mainData();
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    DateTime currentDate = DateTime.now();
    int currentWeekday = currentDate.weekday; // 1 = Monday, 7 = Sunday

    DateTime dayOfWeek = currentDate
        .subtract(Duration(days: currentWeekday - 1 - value.toInt()));

    String dayOfWeekStr =
        getDayName(dayOfWeek.weekday); // Get the name of the day

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(dayOfWeekStr, style: style),
    );
  }

  String getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    return Text('${value.toStringAsFixed(1)}l', style: style);
  }
}
