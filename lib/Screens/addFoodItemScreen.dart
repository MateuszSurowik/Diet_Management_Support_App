import 'package:flutter/material.dart';
import 'package:diet_management_suppport_app/models/foodItem.dart';
import '../services/openFoodFactsService.dart';

class AddFoodItemScreen extends StatefulWidget {
  final Function(FoodItem) onAddMeal;

  AddFoodItemScreen({required this.onAddMeal});

  @override
  _AddFoodItemScreenState createState() => _AddFoodItemScreenState();
}

class _AddFoodItemScreenState extends State<AddFoodItemScreen> {
  final OpenFoodFactsApi api = OpenFoodFactsApi();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();

  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  String _searchType = 'Nazwa';

  /// Wyszukiwanie produktów według wybranego typu
  void _searchProducts() async {
    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    final query = _searchController.text.trim();
    if (_searchType == 'Kod kreskowy') {
      final product = await api.getProductByBarcode(query);
      setState(() {
        _searchResults = product != null ? [product] : [];
        if (product == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nie znaleziono produktu')),
          );
        }
        _isSearching = false;
      });
    } else {
      final results = await api.searchProductsByName(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  /// Funkcja ustawiająca pola na podstawie wybranego produktu
  void _selectProduct(Map<String, dynamic> product) {
    setState(() {
      _nameController.text = product['product_name'] ?? '';
      _caloriesController.text =
          (product['nutriments']['energy-kcal_100g'] ?? 0).toString();
      _proteinController.text =
          (product['nutriments']['proteins_100g'] ?? 0).toString();
      _fatController.text = (product['nutriments']['fat_100g'] ?? 0).toString();
      _carbsController.text =
          (product['nutriments']['carbohydrates_100g'] ?? 0).toString();
      _searchResults = []; // Ukryj wyniki po wyborze produktu
    });
  }

  void _submitMeal() {
    final name = _nameController.text;
    final calories = int.tryParse(_caloriesController.text) ?? 0;
    final protein = _proteinController.text;
    final fat = _fatController.text;
    final carbs = _carbsController.text;

    if (name.isEmpty || calories == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wprowadź nazwę posiłku i kaloryczność')),
      );
      return;
    }

    final newFoodItem = FoodItem(
      name: name,
      calories: calories,
      macros: '${protein}g P | ${fat}g F | ${carbs}g C',
    );

    widget.onAddMeal(newFoodItem);
    Navigator.pop(context);
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Wyszukaj produkt',
                      suffixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _searchProducts(),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _searchType,
                  items: const [
                    DropdownMenuItem(
                      value: 'Nazwa',
                      child: Text('Nazwa'),
                    ),
                    DropdownMenuItem(
                      value: 'Kod kreskowy',
                      child: Text('Kod kreskowy'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _searchType = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_isSearching) const CircularProgressIndicator(),
            if (_searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final product = _searchResults[index];
                    final name = product['product_name'] ?? 'Brak nazwy';
                    return ListTile(
                      title: Text(name),
                      subtitle: Text(
                          'Kalorie: ${(product['nutriments']['energy-kcal_100g'] ?? 'Brak danych')} kcal/100g | '
                          '${(product['nutriments']['proteins_100g'] ?? 'Brak danych')} proteins/100g | '
                          '${(product['nutriments']['carbohydrates_100g'] ?? 'Brak danych')} carbohydrates/100g | '
                          '${(product['nutriments']['fat_100g'] ?? 'Brak danych')} fat/100g'),
                      onTap: () => _selectProduct(product),
                    );
                  },
                ),
              ),
            const SizedBox(height: 10),
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
