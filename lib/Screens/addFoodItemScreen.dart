import 'package:flutter/material.dart';
import 'package:diet_management_suppport_app/models/foodItem.dart';

class AddFoodItemScreen extends StatefulWidget {
  final Function(FoodItem) onAddMeal;

  const AddFoodItemScreen({super.key, required this.onAddMeal});

  @override
  _AddFoodItemScreenState createState() => _AddFoodItemScreenState();
}

class _AddFoodItemScreenState extends State<AddFoodItemScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();

  void _submitMeal() {
    final name = _nameController.text;
    final calories = int.tryParse(_caloriesController.text) ?? 0;
    final protein = _proteinController.text;
    final fat = _fatController.text;
    final carbs = _carbsController.text;

    if (name.isEmpty || calories == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Wprowadź nazwę posiłku oraz kaloryczność')),
      );
      return;
    }

    // Utwórz obiekt FoodItem zamiast mapy
    final newFoodItem = FoodItem(
      name: name,
      calories: calories,
      macros: '${protein}g P | ${fat}g F | ${carbs}g C',
    );

    widget.onAddMeal(newFoodItem); // Przekaż FoodItem do onAddMeal
    Navigator.pop(context); // Powrót do ekranu głównego
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj Posiłek'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nazwa posiłku'),
            ),
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Kalorie'),
            ),
            TextField(
              controller: _proteinController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Białka (g)'),
            ),
            TextField(
              controller: _fatController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tłuszcze (g)'),
            ),
            TextField(
              controller: _carbsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Węglowodany (g)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitMeal,
              child: const Text('Dodaj Posiłek'),
            ),
          ],
        ),
      ),
    );
  }
}
