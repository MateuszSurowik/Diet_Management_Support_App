import 'package:flutter/material.dart';

class AddFoodItemScreen extends StatefulWidget {
  final Function onAddMeal;

  AddFoodItemScreen({required this.onAddMeal});

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
      // Pokaż błąd jeśli nazwa lub kalorie są puste
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wprowadź nazwę posiłku i kaloryczność')),
      );
      return;
    }

    final newMeal = {
      'name': name,
      'calories': calories,
      'macros': '${protein}g P | ${fat}g F | ${carbs}g C'
    };

    widget.onAddMeal(newMeal);
    Navigator.pop(context); // Powrót do ekranu głównego
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dodaj Posiłek'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nazwa posiłku'),
            ),
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Kalorie'),
            ),
            TextField(
              controller: _proteinController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Białka (g)'),
            ),
            TextField(
              controller: _fatController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Tłuszcze (g)'),
            ),
            TextField(
              controller: _carbsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Węglowodany (g)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitMeal,
              child: Text('Dodaj Posiłek'),
            ),
          ],
        ),
      ),
    );
  }
}
