import 'package:diet_management_suppport_app/Screens/addFoodItemScreen.dart';
import 'package:diet_management_suppport_app/models/foodItem.dart';
import 'package:diet_management_suppport_app/models/meal.dart';
import 'package:flutter/material.dart';

class MealSection extends StatefulWidget {
  final Meal meal;
  final Function(FoodItem) onAddFoodItem;
  final Function() chartRefresh;

  MealSection(
      {super.key,
      required this.meal,
      required this.onAddFoodItem,
      required this.chartRefresh});

  @override
  State<MealSection> createState() => _MealSectionState();
}

class _MealSectionState extends State<MealSection> {
  @override
  Widget build(BuildContext context) {
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
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddFoodItemScreen(
                                onAddMeal: (foodItem) =>
                                    widget.onAddFoodItem(foodItem),
                              )),
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
                  print("hello");
                  setState(() {
                    widget.meal.items.remove(item);
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
