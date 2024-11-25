import 'package:diet_management_suppport_app/models/meal.dart';
import 'package:diet_management_suppport_app/models/userLimits.dart';
import 'package:diet_management_suppport_app/services/firebaseClient.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _BarChart extends StatefulWidget {
  const _BarChart();

  @override
  State<_BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<_BarChart> {
  List<Meal> day1 = [];
  List<Meal> day2 = [];
  List<Meal> day3 = [];
  List<Meal> day4 = [];
  List<Meal> day5 = [];
  List<Meal> day6 = [];
  List<Meal> day7 = [];

  List<double> dailyCalories = []; // Kalorie dla każdego dnia
  List<String> weekDays = []; // Etykiety dni tygodnia

  Future<void> loadLastWeekMeals(String userId) async {
    // Daty dla każdego dnia tygodnia - zaczynamy od wczoraj
    DateTime now = DateTime.now();
    // Poczatek tygodnia to poniedziałek (będziemy wstecz od dzisiaj)
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    List<DateTime> lastWeekDates = List.generate(
      7,
      (i) => startOfWeek.subtract(Duration(days: i)),
    );

    // Inicjalizacja etykiet dni tygodnia
    weekDays = lastWeekDates
        .map((date) =>
            DateFormat.E().format(date)) // Zmieniamy format na 'E' (skrót dnia)
        .toList();

    List<List<Meal>> dayLists = [day1, day2, day3, day4, day5, day6, day7];

    // Iteracja przez dni i wczytywanie danych
    for (int i = 0; i < lastWeekDates.length; i++) {
      DateTime date = lastWeekDates[i];
      List<Meal> dayList = dayLists[i];

      await Firebaseclient().loadMealsForDate(
        userId: userId,
        date: date,
        onMealsLoaded: (List<Meal> meals) {
          dayList.addAll(meals); // Dodajemy posiłki do odpowiedniej listy
        },
      );

      // Oblicz kalorie dla każdego dnia
      double dailyTotal = calculateDailyCalories(dayList);
      dailyCalories.add(dailyTotal);
    }

    // Zaktualizuj widok po załadowaniu danych
    setState(() {});
  }

  double calculateDailyCalories(List<Meal> meals) {
    return meals.fold(0, (sum, meal) => sum + meal.calculateTotalCalories());
  }

  @override
  void initState() {
    super.initState();
    loadLastWeekMeals(userId); // Przekaż odpowiednie ID użytkownika
  }

  @override
  Widget build(BuildContext context) {
    List<double> data = dailyCalories.isEmpty
        ? []
        : dailyCalories.map((e) => e / 1000).toList();

    return Container(
      height: 150,
      width: 300,
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
      child: BarChart(
        BarChartData(
          barTouchData: barTouchData,
          titlesData: titlesData,
          borderData: borderData,
          barGroups: generateBarGroups(data),
          gridData: const FlGridData(show: false),
          alignment: BarChartAlignment.spaceAround,
          maxY: 20,
        ),
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              '${rod.toY.toString()}k',
              const TextStyle(
                color: Colors.cyan,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    if (value >= 0 && value < weekDays.length) {
      text = weekDays[value.toInt()];
    } else {
      text = '';
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  LinearGradient get _barsGradient => LinearGradient(
        colors: [Colors.blue, Colors.cyan],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  List<BarChartGroupData> generateBarGroups(List<double> values) {
    return List<BarChartGroupData>.generate(
      values.length,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: values[index],
            gradient: _barsGradient,
          ),
        ],
        showingTooltipIndicators: [0],
      ),
    );
  }
}

class BarChartSample3 extends StatefulWidget {
  const BarChartSample3({super.key});

  @override
  State<StatefulWidget> createState() => BarChartSample3State();
}

class BarChartSample3State extends State<BarChartSample3> {
  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
      aspectRatio: 1.6,
      child: _BarChart(),
    );
  }
}
