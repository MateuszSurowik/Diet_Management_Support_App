import 'package:diet_management_suppport_app/models/foodItem.dart';
import 'package:diet_management_suppport_app/models/meal.dart';
import 'package:diet_management_suppport_app/models/userLimits.dart';
import 'package:diet_management_suppport_app/services/firebaseClient.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Chart extends StatefulWidget {
  const Chart({super.key});

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  String _selectedPeriod = 'day';
  List<FoodItem> userMeals = [];
  Map<String, double> _gradeCounts = {
    'A': 14,
    'B': 5,
    'C': 6,
    'D': 7,
    'E': 8,
  };
  @override
  void initState() {
    super.initState();
    if (userMealData.isEmpty) {
    } else {
      getAllUserMeals(userMealData);
      calculateGradePercentages(userMeals);
      loadChartData();
    }
  }

  void loadChartData() {
    String id = userId; // Pobierz ID użytkownika z kontekstu aplikacji

    Firebaseclient().loadMealsForPeriod(
      userId: id,
      period: _selectedPeriod,
      onMealsLoaded: (meals) {
        setState(() {
          userMeals = meals.expand((meal) => meal.items).toList();
          calculateGradePercentages(userMeals);
        });
      },
    );
  }

  void getAllUserMeals(List<Meal> userMealData) {
    userMeals = userMealData.expand((meal) => meal.items).toList();
  }

  Map<String, double> getParsedMacros(FoodItem item) {
    final regex = RegExp(
        r'(\d+(?:\.\d+)?)g P \| (\d+(?:\.\d+)?)g F \| (\d+(?:\.\d+)?)g C');
    final match = regex.firstMatch(item.macros);

    if (match != null) {
      return {
        'protein': double.parse(match.group(1)!),
        'fat': double.parse(match.group(2)!),
        'carbs': double.parse(match.group(3)!),
      };
    } else {
      throw FormatException(
          'Niepoprawny format makroskładników: ${item.macros}');
    }
  }

// Funkcje obliczeniowe
  double calculateNegativePoints(FoodItem item) {
    // Parsuj makroskładniki
    final macros = getParsedMacros(item);

    double energyPoints = (item.calories / 335).floor().toDouble().clamp(0, 10);
    double fatPoints = (macros['fat']! / 1).floor().toDouble().clamp(0, 10);

    return energyPoints + fatPoints;
  }

// Oblicz punkty pozytywne tylko na podstawie białka
  double calculatePositivePoints(FoodItem item) {
    // Parsuj makroskładniki
    final macros = getParsedMacros(item);

    double proteinPoints = (macros['protein']! / 1.6)
        .floor()
        .toDouble()
        .clamp(0, 5); // Punkty za białko
    return proteinPoints;
  }

// Oblicz końcowy wynik Nutri-Score
  double calculateNutriScore(FoodItem item) {
    double negativePoints = calculateNegativePoints(item);
    double positivePoints = calculatePositivePoints(item);

    return negativePoints - positivePoints;
  }

// Przydziel literę Nutri-Score
  String getNutriScoreGrade(FoodItem item) {
    double score = calculateNutriScore(item);

    if (score <= -1) {
      return 'A';
    } else if (score <= 2) {
      return 'B';
    } else if (score <= 10) {
      return 'C';
    } else if (score <= 18) {
      return 'D';
    } else {
      return 'E';
    }
  }

  void calculateGradePercentages(List<FoodItem> items) {
    Map<String, double> gradeCounts = {
      'A': 0,
      'B': 0,
      'C': 0,
      'D': 0,
      'E': 0,
    };

    // Liczba wszystkich produktów
    int totalItems = items.length;

    // Przelicz grade'y dla każdego produktu
    for (var item in items) {
      String grade = getNutriScoreGrade(item);
      gradeCounts[grade] = gradeCounts[grade]! + 1;
    }

    // Oblicz procentowy udział
    Map<String, double> gradePercentages = {};
    gradeCounts.forEach((grade, count) {
      gradePercentages[grade] = (count / totalItems) * 100;
    });

    _gradeCounts = gradeCounts;
  }

  @override
  Widget build(BuildContext context) {
    getAllUserMeals(userMealData);
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
      height: 250,
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Your Eating Grade"),
                SizedBox(
                  width: 40,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPeriod = newValue!;
                      });
                      loadChartData();
                    },
                    items: <String>['day', 'week', 'month']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: showingSections5(
                      _gradeCounts['A']!,
                      _gradeCounts['B']!,
                      _gradeCounts['C']!,
                      _gradeCounts['D']!,
                      _gradeCounts['E']!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<PieChartSectionData> showingSections3(
    double val1, double val2, double val3) {
  return List.generate(3, (i) {
    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
    switch (i) {
      case 0:
        return PieChartSectionData(
          color: Colors.blue,
          value: 40,
          title: 'A',
          radius: 20,
          titleStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            shadows: shadows,
          ),
        );
      case 1:
        return PieChartSectionData(
          color: Colors.yellow,
          value: 30,
          title: 'B',
          radius: 20,
          titleStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            shadows: shadows,
          ),
        );
      case 2:
        return PieChartSectionData(
          color: Colors.purple,
          value: 15,
          title: 'C',
          radius: 20,
          titleStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            shadows: shadows,
          ),
        );
      default:
        throw Error();
    }
  });
}

List<PieChartSectionData> showingSections5(
  double val1,
  double val2,
  double val3,
  double val4,
  double val5,
) {
  return List.generate(4, (i) {
    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
    switch (i) {
      case 0:
        return PieChartSectionData(
          color: Colors.blue,
          value: val1,
          title: 'A',
          radius: 20,
          titleStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            shadows: shadows,
          ),
        );
      case 1:
        return PieChartSectionData(
          color: Colors.yellow,
          value: val2,
          title: 'B',
          radius: 20,
          titleStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            shadows: shadows,
          ),
        );
      case 2:
        return PieChartSectionData(
          color: Colors.purple,
          value: val3,
          title: 'C',
          radius: 20,
          titleStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            shadows: shadows,
          ),
        );
      case 3:
        return PieChartSectionData(
          color: Colors.red,
          value: val4,
          title: 'D',
          radius: 20,
          titleStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            shadows: shadows,
          ),
        );
      case 4:
        return PieChartSectionData(
          color: const Color.fromARGB(255, 3, 104, 236),
          value: val5,
          title: 'E',
          radius: 20,
          titleStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            shadows: shadows,
          ),
        );
      default:
        throw Error();
    }
  });
}
