import 'package:diet_management_suppport_app/Screens/CalculatorBmiScreen.dart';
import 'package:diet_management_suppport_app/Screens/UserProfileScreen.dart';
import 'package:diet_management_suppport_app/models/FoodItem.dart';
import 'package:diet_management_suppport_app/models/Meal.dart';
import 'package:flutter/material.dart';
import 'AddFoodItemScreen.dart';

class MealScreen extends StatefulWidget {
  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  List<Meal> meals =
      List.generate(24, (hour) => Meal(name: '${hour}:00', items: []));

  void _addFoodItem(String mealName, FoodItem foodItem) {
    setState(() {
      final meal = meals.firstWhere((m) => m.name == mealName);
      meal.items.add(foodItem);
    });
  }

  int _selectedIndex = 0;
  Widget? actualScreen;
  void _onBottomNavTap(int index) {
    // dokonczyc poprawic
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        actualScreen = hoursScreen();
      } else if (_selectedIndex == 1) {
        print("Calculator icon tapped");
        actualScreen = BmiHomePage();
      } else if (_selectedIndex == 2) {
        print("User profile icon tapped");
        actualScreen = UserProfileScreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              // Obsługa wyboru daty
            },
          ),
        ],
      ),
      body: actualScreen,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget hoursScreen() {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        ...meals.map((meal) => MealSection(
              meal: meal,
              onAddFoodItem: (foodItem) => _addFoodItem(meal.name, foodItem),
            )),
        SizedBox(height: 20),
        // Podsumowanie aktywności
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Workout',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Calories burned: 300 kcal'),
                SizedBox(height: 8),
                LinearProgressIndicator(value: 0.6),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MealSection extends StatefulWidget {
  final Meal meal;
  final Function(FoodItem) onAddFoodItem;

  MealSection({required this.meal, required this.onAddFoodItem});

  @override
  State<MealSection> createState() => _MealSectionState();
}

class _MealSectionState extends State<MealSection> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddFoodItemScreen(
                          onAdd: (foodItem) => widget.onAddFoodItem(foodItem),
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
                trailing: Icon(Icons.close),
                onTap: () {
                  print("hello");
                  setState(() {
                    widget.meal.items.remove(item);
                  });
                },
              );
            }).toList(),
            if (widget.meal.items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Brak dodanych produktów',
                    style: TextStyle(color: Colors.grey)),
              ),
          ],
        ),
      ),
    );
  }
}
