import 'package:diet_management_suppport_app/models/userLimits.dart';
import 'package:flutter/material.dart';
import 'package:diet_management_suppport_app/models/foodItem.dart';
import 'package:diet_management_suppport_app/services/firebaseClient.dart';

class UserAddedMealsScreen extends StatefulWidget {
  const UserAddedMealsScreen({super.key});

  @override
  State<UserAddedMealsScreen> createState() => _UserAddedMealsScreenState();
}

class _UserAddedMealsScreenState extends State<UserAddedMealsScreen> {
  late Future<List<FoodItem>> userMealsFuture;

  @override
  void initState() {
    super.initState();
    userMealsFuture = Firebaseclient().getFavouriteList(userId: userId);
  }

  void _removeMeal(
      String userId, String foodName, int index, List<FoodItem> meals) async {
    // Sprawdzenie, czy lista posiłków nie jest pusta
    if (meals.isNotEmpty && index >= 0 && index < meals.length) {
      // Usuń element z Firebase
      await Firebaseclient().removeFavouriteItem(
        userId: userId,
        foodName: foodName,
      );

      // Usuń element z lokalnej listy i odśwież widok
      setState(() {
        meals.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$foodName usunięto z listy.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje Dodane Posiłki'),
      ),
      body: FutureBuilder<List<FoodItem>>(
        future: userMealsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Wystąpił błąd: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Brak dodanych posiłków.'),
            );
          } else {
            final meals = snapshot.data!;
            return ListView.builder(
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return Dismissible(
                  key: Key(meal.name),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _removeMeal(userId, meal.name, index, meals);
                  },
                  child: ListTile(
                    title: Text(meal.name),
                    subtitle: Text(
                      'Kalorie: ${meal.calories} kcal | Makroskładniki: ${meal.macros}',
                    ),
                    onTap: () {
                      // Sprawdź, czy indeks jest prawidłowy przed próbą nawigacji
                      if (index >= 0 && index < meals.length) {
                        Navigator.pop(context, index);
                      } else {
                        // Dodaj obsługę błędu, jeśli indeks jest nieprawidłowy
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Nieprawidłowy indeks!')),
                        );
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
