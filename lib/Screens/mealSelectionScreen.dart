import 'package:diet_management_suppport_app/main.dart';
import 'package:diet_management_suppport_app/models/userLimits.dart';
import 'package:diet_management_suppport_app/services/firebaseClient.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart'; // Importujemy percent_indicator
import 'package:diet_management_suppport_app/models/foodItem.dart';
import 'package:diet_management_suppport_app/models/meal.dart';
import 'package:diet_management_suppport_app/widgets/mealSection.dart';

class MealSelectionScreen extends StatefulWidget {
  MealSelectionScreen({super.key, required this.track, required this.date});
  bool track = false;
  DateTime date;

  @override
  State<MealSelectionScreen> createState() => _MealSelectionScreenState();
}

class _MealSelectionScreenState extends State<MealSelectionScreen> {
  List<Meal> Hours = userMealData;
  List<FoodItem> userMeals = [];

  @override
  void initState() {
    super.initState();
    // Ładowanie posiłków z Firebase po starcie ekranu
    Firebaseclient().loadMealsForDate(
      userId: userId,
      date: widget.date,
      onMealsLoaded: (meals) {
        setState(() {
          // Sprawdzanie godzin w bazie danych
          final mealHours = meals.map((meal) => meal.name).toSet();
          final allHours = List.generate(
              24, (index) => '$index:00'); // Lista godzin 0:00 - 23:00
          Hours = allHours.map((hour) {
            // Jeśli godzina jest w bazie danych, użyj danych z Firebase, w przeciwnym razie przypisz pustą listę
            return meals.firstWhere(
              (meal) => meal.name == hour,
              orElse: () => Meal(name: hour, items: []),
            );
          }).toList();
        });
      },
    );
    Firebaseclient().loadGlassesForDate(
      userId: userId,
      date: widget.date,
      onGlassesLoaded: (glasses) {
        setState(() {
          userGlasses = glasses;
        });
      },
    );
  }

  void _addWaterGlass() {
    setState(() {
      userGlasses.add(false); // Dodanie nowej szarej szklanki
    });
  }

  void _toggleGlass(int index) {
    setState(() {
      userGlasses[index] = !userGlasses[index];
      Firebaseclient().updateGlassesAndSaveToDatabase(
          userId: userId,
          glasses: userGlasses,
          date: widget.date); // Zmiana stanu szklanki
    });
  }

  // Funkcja do dodawania posiłków
  void _addFoodItem(String mealName, FoodItem foodItem) {
    setState(() {
      final hour = Hours.firstWhere((m) => m.name == mealName);
      hour.items.add(foodItem);
      userMealData = Hours;
      Firebaseclient().addMeal(
          userId: userId, mealDate: DateTime.now(), foodItem: foodItem);
    });
  }

  void _refresher() {
    setState(() {});
  }

  // Funkcja pomocnicza do parsowania macros
  Map<String, double> _parseMacros(String macros) {
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
          child: track
              ? Center(
                  child: Text(
                    "Today, forget about tracking your diet. Enjoy this break, indulge without guilt, and savor every moment.",
                    style: TextStyle(
                      fontSize: 16,
                      color: kIsDark ? Colors.white : Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : ListView(
                  children: [
                    ...Hours.map((hour) => MealSection(
                          meal: hour,
                          onAddFoodItem: (foodItem) =>
                              _addFoodItem(hour.name, foodItem),
                          chartRefresh: _refresher,
                          date: widget.date,
                        )),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: kIsDark
                            ? const Color.fromARGB(255, 124, 124, 124)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Water Intake',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: kIsDark ? Colors.white : Colors.black),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8.0,
                            children: userGlasses.asMap().entries.map((entry) {
                              int index = entry.key;
                              bool isFilled = entry.value;
                              return GestureDetector(
                                onTap: () => _toggleGlass(index),
                                child: Icon(
                                  Icons.local_drink,
                                  size: 40,
                                  color: isFilled ? Colors.blue : Colors.grey,
                                ),
                              );
                            }).toList()
                              ..add(
                                GestureDetector(
                                  onTap: _addWaterGlass,
                                  child: Icon(
                                    Icons.add_circle,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 85.0,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 124, 124, 124),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCircularChart('Calories', _calculateTotalCalories(),
                  calories, Colors.green),
              _buildCircularChart(
                  'Fats', _calculateTotalFats(), fat, Colors.red),
              _buildCircularChart(
                  'Carbs', _calculateTotalCarbs(), carbs, Colors.orange),
              _buildCircularChart(
                  'Protein', _calculateTotalProtein(), protein, Colors.blue),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

Widget _buildCircularChart(
    String label, double value, double maxValue, Color progressColor) {
  double percentage = value / maxValue;
  double excessPercentage = percentage > 1
      ? percentage - 1
      : 0; // Obliczamy nadmiarowy procent, jeśli przekracza 100%

  return Column(
    mainAxisAlignment: MainAxisAlignment.center, // Wyrównujemy wykresy pionowo
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          CircularPercentIndicator(
            radius: 24.0, // Promień głównego wykresu
            lineWidth: 6.0, // Grubość linii głównego wykresu
            percent:
                percentage.clamp(0.0, 1.0), // Główny wykres ograniczony do 100%
            center: Text(
              '${value.toStringAsFixed(0)}', // Wyświetlanie wartości liczbowej
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kIsDark
                    ? Colors.white
                    : Colors.black, // Kolor tekstu zależny od trybu
              ),
            ),
            progressColor: progressColor, // Kolor głównego postępu
            backgroundColor: Colors.grey[300]!, // Kolor tła wykresu
          ),
          if (excessPercentage > 0)
            CircularPercentIndicator(
              radius: 24.0, // Promień dodatkowego wykresu (taki sam jak główny)
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
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: kIsDark
              ? Colors.white
              : Colors.black, // Kolor podpisu zależny od trybu
        ),
      ),
    ],
  );
}
