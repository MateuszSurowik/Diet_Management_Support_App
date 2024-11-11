import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart'; // Importujemy percent_indicator

import 'package:diet_management_suppport_app/models/foodItem.dart';
import 'package:diet_management_suppport_app/models/meal.dart';
import 'package:diet_management_suppport_app/widgets/mealSection.dart';

class MealSelectionScreen extends StatefulWidget {
  const MealSelectionScreen({super.key});

  @override
  State<MealSelectionScreen> createState() => _MealSelectionScreenState();
}

class _MealSelectionScreenState extends State<MealSelectionScreen> {
  List<Meal> Hours =
      List.generate(24, (hour) => Meal(name: '$hour:00', items: []));
  List<FoodItem> userMeals = [];

  // Funkcja do dodawania posiłków
  void _addFoodItem(String mealName, FoodItem foodItem) {
    setState(() {
      final meal = Hours.firstWhere((m) => m.name == mealName);
      meal.items.add(foodItem);
    });
  }

  void _refresher() {
    setState(() {});
  }

  // Funkcja pomocnicza do parsowania macros
  Map<String, double> _parseMacros(String macros) {
    // Wyciąganie wartości białka, tłuszczu i węglowodanów
    final regex = RegExp(r'(\d+)\s*g\s([A-Za-z])');
    final matches = regex.allMatches(macros);

    double protein = 0.0;
    double fat = 0.0;
    double carbs = 0.0;

    for (var match in matches) {
      final value = double.parse(match.group(1)!);
      final macroType = match.group(2);

      if (macroType == 'P') {
        protein = value;
      } else if (macroType == 'F') {
        fat = value;
      } else if (macroType == 'C') {
        carbs = value;
      }
    }

    return {'protein': protein, 'fat': fat, 'carbs': carbs};
  }

  // Funkcja obliczająca sumę kalorii, tłuszczy, węglowodanów i białka
  double _calculateTotalCalories() {
    double totalCalories = 0.0;
    for (var meal in Hours) {
      for (var food in meal.items) {
        totalCalories += food.calories;
      }
    }
    return totalCalories;
  }

  double _calculateTotalFats() {
    double totalFats = 0.0;
    for (var meal in Hours) {
      for (var food in meal.items) {
        final macros = _parseMacros(food.macros);
        totalFats += macros['fat']!;
      }
    }
    return totalFats;
  }

  double _calculateTotalCarbs() {
    double totalCarbs = 0.0;
    for (var meal in Hours) {
      for (var food in meal.items) {
        final macros = _parseMacros(food.macros);
        totalCarbs += macros['carbs']!;
      }
    }
    return totalCarbs;
  }

  double _calculateTotalProtein() {
    double totalProtein = 0.0;
    for (var meal in Hours) {
      for (var food in meal.items) {
        final macros = _parseMacros(food.macros);
        totalProtein += macros['protein']!;
      }
    }
    return totalProtein;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView(
            children: [
              ...Hours.map((hour) => MealSection(
                  meal: hour,
                  onAddFoodItem: (foodItem) =>
                      _addFoodItem(hour.name, foodItem),
                  chartRefresh: _refresher)),
              const SizedBox(height: 20),
              // Podsumowanie aktywności
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Workout',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Calories burned: 300 kcal'),
                      SizedBox(height: 8),
                      LinearProgressIndicator(value: 0.6),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Dodajemy kontener z wykresami kołowymi w jednym rzędzie
        Container(
          height: 85.0, // Ustalamy maksymalną wysokość kontenera
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCircularChart(
                  'Calories', _calculateTotalCalories(), 1000.0, Colors.green),
              _buildCircularChart(
                  'Fats', _calculateTotalFats(), 100.0, Colors.red),
              _buildCircularChart(
                  'Carbs', _calculateTotalCarbs(), 100.0, Colors.orange),
              _buildCircularChart(
                  'Protein', _calculateTotalProtein(), 100.0, Colors.blue),
            ],
          ),
        ),
      ],
    );
  }

  // Funkcja budująca wykres kołowy
  Widget _buildCircularChart(
      String label, double value, double maxValue, Color progressColor) {
    double percentage = value / maxValue;
    double excessPercentage = percentage > 1
        ? percentage - 1
        : 0; // Obliczamy nadmiarowy procent, jeśli przekracza 100%

    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center, // Wyrównujemy wykresy pionowo
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircularPercentIndicator(
              radius: 24.0, // Promień głównego wykresu
              lineWidth: 6.0, // Grubość linii głównego wykresu
              percent: percentage.clamp(
                  0.0, 1.0), // Główny wykres ograniczony do 100%
              center: Text(
                '${value.toStringAsFixed(0)}', // Wyświetlanie wartości liczbowej
                style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.bold), // Czcionka dla wartości liczbowej
              ),
              progressColor: progressColor, // Kolor głównego postępu
              backgroundColor: Colors.grey[300]!, // Kolor tła wykresu
            ),
            if (excessPercentage > 0)
              CircularPercentIndicator(
                radius:
                    24.0, // Promień dodatkowego wykresu (taki sam jak główny)
                lineWidth: 6.0, // Grubość linii dodatkowego wykresu
                percent: excessPercentage.clamp(0.0, 1.0), // Nadmiarowy procent
                progressColor:
                    Colors.red, // Kolor czerwony dla nadmiarowego wykresu
                backgroundColor:
                    Colors.transparent, // Tło ustawiamy na przezroczyste
              ),
          ],
        ),
        const SizedBox(height: 4), // Przestrzeń pomiędzy wykresem a podpisem
        Text(
          label, // Wyświetlamy podpis
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold), // Stylizacja podpisu
        ),
      ],
    );
  }
}
