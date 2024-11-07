import 'package:diet_management_suppport_app/Screens/aiAssistantScreen.dart';
import 'package:diet_management_suppport_app/Screens/calculatorBmi.dart';
import 'package:diet_management_suppport_app/Screens/userProfileScreen.dart';
import 'package:diet_management_suppport_app/models/foodItem.dart';
import 'package:diet_management_suppport_app/models/meal.dart';
import 'package:flutter/material.dart';
import 'AddFoodItemScreen.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  List<Meal> Hours =
      List.generate(24, (hour) => Meal(name: '$hour:00', items: []));
  List<FoodItem> userMeals = [];

  void _addFoodItem(String mealName, FoodItem foodItem) {
    setState(() {
      final meal = Hours.firstWhere((m) => m.name == mealName);
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
        actualScreen = hoursScreen(userMeals);
      } else if (_selectedIndex == 1) {
        actualScreen = BmiHomePage();
      } else if (_selectedIndex == 2) {
        actualScreen = AiAssistantScreen();
      } else if (_selectedIndex == 3) {
        actualScreen = UserProfileScreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // Obsługa wyboru daty
            },
          ),
        ],
      ),
      body: actualScreen,
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer_outlined),
            label: 'Ask AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget hoursScreen(List<FoodItem> userMeals) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ...Hours.map((hour) => MealSection(
              meal: hour,
              onAddFoodItem: (foodItem) => _addFoodItem(hour.name, foodItem),
            )),
        const SizedBox(height: 20),
        // Podsumowanie aktywności
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
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

  MealSection({
    super.key,
    required this.meal,
    required this.onAddFoodItem,
  });

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
