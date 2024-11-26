import 'package:diet_management_suppport_app/Screens/addFoodItemScreen.dart';
import 'package:diet_management_suppport_app/models/foodItem.dart';
import 'package:diet_management_suppport_app/models/meal.dart';
import 'package:diet_management_suppport_app/models/userLimits.dart';
import 'package:diet_management_suppport_app/services/firebaseClient.dart';
import 'package:flutter/material.dart';

class MealSection extends StatefulWidget {
  final Meal meal;
  final Function(FoodItem) onAddFoodItem;
  final Function() chartRefresh;
  final DateTime date;

  MealSection({
    super.key,
    required this.meal,
    required this.onAddFoodItem,
    required this.chartRefresh,
    required this.date,
  });

  @override
  State<MealSection> createState() => _MealSectionState();
}

class _MealSectionState extends State<MealSection> {
  @override
  Widget build(BuildContext context) {
    // Pobierz bieżącą godzinę i sprawdź, czy jest po godzinie posiłku
    final currentDateTime = DateTime.now();
    final mealDateTime = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      int.parse(widget.meal.name.split(":")[0]), // Godzina
      0, // Minuta ustawiona na 0, bo używamy tylko godziny
    );

    // Zwiększamy godzinę posiłku o 1
    final mealDateTimePlusOneHour = mealDateTime.add(Duration(hours: 0));

    // Sprawdzamy, czy bieżąca godzina +1 jest większa niż godzina posiłku
    final isAddButtonVisible =
        currentDateTime.isBefore(mealDateTimePlusOneHour);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.meal.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (isAddButtonVisible) // Pokazuje przycisk tylko jeśli spełnia warunek
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddFoodItemScreen(
                            onAddMeal: (foodItem) =>
                                widget.onAddFoodItem(foodItem),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
            ...widget.meal.items.map((item) {
              return ListTile(
                title: Text(item.name),
                subtitle: Text('${item.calories} kcal | ${item.macros}'),
                trailing: const Icon(Icons.close),
                onTap: () {
                  setState(() {
                    widget.meal.items.remove(item);
                    Firebaseclient().removeFoodItem(
                        userId: userId,
                        mealDate: widget.date,
                        foodName: item.name,
                        mealTime: widget.meal.name);
                    widget.chartRefresh();
                  });
                },
              );
            }),
            if (widget.meal.items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Brak dodanych posiłków',
                    style: TextStyle(color: Colors.grey)),
              ),
          ],
        ),
      ),
    );
  }
}
