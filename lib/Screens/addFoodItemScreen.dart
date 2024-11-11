import 'package:diet_management_suppport_app/Screens/userAddedMealsScreen';
import 'package:diet_management_suppport_app/models/userFavMeals.dart';
import 'package:flutter/material.dart';
import 'package:diet_management_suppport_app/models/foodItem.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../services/openFoodFactsService.dart';

class AddFoodItemScreen extends StatefulWidget {
  final Function(FoodItem) onAddMeal;

  const AddFoodItemScreen({super.key, required this.onAddMeal});

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
  double totalProteins = 0;
  double totalCarbohydrates = 0;
  double totalFat = 0;
  double totalCalories = 0;
  final List<dynamic> _productsAddedToMeal = [];
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  String _searchType = 'Nazwa';
  int _selectedTab = 1;

  void _navigateToUserMealsScreen() {
    Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => UserAddedMealsScreen(),
      ),
    ).then((index) {
      if (index != null) {
        List<String> macros = userFavProducts[index].macros.trim().split('|');
        _nameController.text = userFavProducts[index].name;
        _caloriesController.text = userFavProducts[index].calories.toString();
        _proteinController.text =
            macros[0].substring(0, macros[0].indexOf('g'));
        _fatController.text = macros[1].substring(1, macros[1].indexOf('g'));
        _carbsController.text = macros[2].substring(2, macros[2].indexOf('g'));
      }
    });
  }

  double _calculateTotalNutrient(String key) {
    return _productsAddedToMeal.fold(
      0,
      (sum, product) => sum + (product['calculated_nutrients'][key] ?? 0),
    );
  }

  double _calculateTotalCalories() {
    return _productsAddedToMeal.fold(
      0.0,
      (sum, product) {
        double energyKcal =
            product['calculated_nutrients']['energy-kcal'] ?? 0.0;

        return sum + energyKcal;
      },
    );
  }

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

  void _quickAddToUserMeals() {
    if (_selectedTab == 1) {
      final name = _nameController.text;
      final calories = double.tryParse(_caloriesController.text) ?? 0;
      final protein = _proteinController.text;
      final fat = _fatController.text;
      final carbs = _carbsController.text;

      if (name.isEmpty || calories == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wprowadź nazwę posiłku i kaloryczność')),
        );
        return;
      }
      userFavProducts.add(FoodItem(
          name: name,
          calories: calories,
          macros: '${protein}g P | ${fat}g F | ${carbs}g C'));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Posiłek dodany do moich posiłków')),
      );
    } else {
      userFavProducts.add(FoodItem(
          name: _nameController.text,
          calories: _calculateTotalCalories(),
          macros:
              '${totalProteins}g P | ${totalFat}g F | ${totalCarbohydrates}g C'));
    }
  }

  Map<String, dynamic> _calculateNutrients(
      Map<String, dynamic> product, double grams) {
    final nutriments = product['nutriments'];

    double getNutrient(String key) =>
        (double.tryParse(nutriments[key].toString()) ?? 0.00) * (grams / 100.0);

    return {
      'energy-kcal': getNutrient('energy-kcal_100g'),
      'proteins': getNutrient('proteins_100g'),
      'carbohydrates': getNutrient('carbohydrates_100g'),
      'fat': getNutrient('fat_100g'),
    };
  }

  void _selectProduct(Map<String, dynamic> product) {
    setState(() {
      if (_selectedTab == 0) {
        showDialog(
          context: context,
          builder: (context) {
            final TextEditingController gramsController =
                TextEditingController();

            return AlertDialog(
              title: Text('Ile gramów chcesz dodać?'),
              content: TextField(
                controller: gramsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Gramatura'),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Anuluj'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final double grams =
                        double.tryParse(gramsController.text) ?? 0;
                    if (grams > 0) {
                      final productCopy = Map<String, dynamic>.from(product);
                      productCopy['quantity'] = grams;
                      productCopy['calculated_nutrients'] =
                          _calculateNutrients(product, grams);
                      setState(() {
                        _productsAddedToMeal.add(productCopy);
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Dodaj'),
                ),
              ],
            );
          },
        );
      } else {
        _nameController.text = product['product_name'] ?? '';
        _caloriesController.text =
            (product['nutriments']['energy-kcal_100g'] ?? 0).toString();
        _proteinController.text =
            (product['nutriments']['proteins_100g'] ?? 0).toString();
        _fatController.text =
            (product['nutriments']['fat_100g'] ?? 0).toString();
        _carbsController.text =
            (product['nutriments']['carbohydrates_100g'] ?? 0).toString();
      }
      _searchResults = [];
    });
  }

  void _submitMeal() {
    final name = _nameController.text;
    final calories = double.tryParse(_caloriesController.text) ?? 0;
    final protein = _proteinController.text;
    final fat = _fatController.text;
    final carbs = _carbsController.text;

    if (name.isEmpty || calories == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Wprowadź nazwę posiłku orazz kaloryczność')),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _navigateToUserMealsScreen,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTab = 0;
                    });
                  },
                  child: Text(
                    "Create Meal",
                    style: TextStyle(
                      color: _selectedTab == 0 ? Colors.blue : Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 40),
                Text(
                  "|",
                  style: TextStyle(
                      fontSize: 40,
                      color: Colors.grey,
                      fontWeight: FontWeight.w100),
                ),
                SizedBox(width: 40),
                TextButton(
                  onPressed: () => setState(() => _selectedTab = 1),
                  child: Text(
                    "Add Meal/Product",
                    style: TextStyle(
                      color: _selectedTab == 1 ? Colors.blue : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _selectedTab == 0 ? _addMeal() : _addProduct(),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView _addProduct() {
    return SingleChildScrollView(
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
            Container(
              width: double.infinity,
              height: 300,
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
                      '${(product['nutriments']['fat_100g'] ?? 'Brak danych')} fat/100g',
                    ),
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
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _quickAddToUserMeals,
            child: Text('Zapisz posiłek jako własny'),
          ),
        ],
      ),
    );
  }

  SingleChildScrollView _addMeal() {
    totalCalories = _calculateTotalCalories();
    totalProteins = _calculateTotalNutrient('proteins');
    totalCarbohydrates = _calculateTotalNutrient('carbohydrates');
    totalFat = _calculateTotalNutrient('fat');
    return SingleChildScrollView(
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
                  DropdownMenuItem(value: 'Nazwa', child: Text('Nazwa')),
                  DropdownMenuItem(
                      value: 'Kod kreskowy', child: Text('Kod kreskowy')),
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
            Container(
              width: double.infinity,
              height: 300,
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
                      '${(product['nutriments']['fat_100g'] ?? 'Brak danych')} fat/100g',
                    ),
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
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _quickAddToUserMeals,
              child: Text('Zapisz'),
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 14),
            child: Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.grey[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.15), // Kolor cienia z przezroczystością
                    blurRadius: 10, // Rozmycie cienia
                    offset: Offset(0, 5), // Przesunięcie cienia w pionie
                  ),
                ],
              ),
              child: ListView.builder(
                itemCount: _productsAddedToMeal.length,
                itemBuilder: (context, index) {
                  final product = _productsAddedToMeal[index];
                  final name = product['product_name'] ?? 'Brak nazwy';
                  final nutrients = product['calculated_nutrients'];
                  return ListTile(
                    title: Text(name),
                    subtitle: Text(
                      'Kalorie: ${nutrients['energy-kcal'].toStringAsFixed(2)} kcal | '
                      'Białko: ${nutrients['proteins'].toStringAsFixed(2)}g | '
                      'Węglowodany: ${nutrients['carbohydrates'].toStringAsFixed(2)}g | '
                      'Tłuszcz: ${nutrients['fat'].toStringAsFixed(2)}g',
                    ),
                    onTap: () {
                      setState(() {
                        _productsAddedToMeal.removeAt(index);
                      });
                    },
                  );
                },
              ),
            ),
          ),
          // Sekcja dla wykresów kołowych w osobnych kontenerach
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Pasek dla białka
              Container(
                width: 200,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: LinearPercentIndicator(
                    width: 200.0,
                    lineHeight: 10.0,
                    percent: (totalProteins / 300).clamp(0.0, 1.0),
                    progressColor: Colors.blue,
                    backgroundColor: Colors.grey[300]!,
                    animation: true,
                    center: Text(
                      '${totalProteins.toStringAsFixed(1)}g',
                      style: TextStyle(
                        fontSize: 8, // Zmieniono rozmiar czcionki na 8
                        color: Colors.black, // Kolor tekstu na czarny
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // Pasek dla węglowodanów
              Container(
                width: 200,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: LinearPercentIndicator(
                    width: 200.0,
                    lineHeight: 10.0,
                    percent: (totalCarbohydrates / 300).clamp(0.0, 1.0),
                    progressColor: Colors.orange,
                    backgroundColor: Colors.grey[300]!,
                    animation: true,
                    center: Text(
                      '${totalCarbohydrates.toStringAsFixed(1)}g',
                      style: TextStyle(
                        fontSize: 8, // Zmieniono rozmiar czcionki na 8
                        color: Colors.black, // Kolor tekstu na czarny
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // Pasek dla tłuszczy
              Container(
                width: 200,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: LinearPercentIndicator(
                    width: 200.0,
                    lineHeight: 10.0,
                    percent: (totalFat / 300).clamp(0.0, 1.0),
                    progressColor: Colors.red,
                    backgroundColor: Colors.grey[300]!,
                    animation: true,
                    center: Text(
                      '${totalFat.toStringAsFixed(1)}g',
                      style: TextStyle(
                        fontSize: 8, // Zmieniono rozmiar czcionki na 8
                        color: Colors.black, // Kolor tekstu na czarny
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // Pasek dla kalorii
              Container(
                width: 200,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: LinearPercentIndicator(
                    width: 200.0,
                    lineHeight: 10.0,
                    percent: (_calculateTotalCalories() / 2500).clamp(0.0, 1.0),
                    progressColor: Colors.green,
                    backgroundColor: Colors.grey[300]!,
                    animation: true,
                    center: Text(
                      '${_calculateTotalCalories().toStringAsFixed(0)} kcal',
                      style: TextStyle(
                        fontSize: 8, // Zmieniono rozmiar czcionki na 8
                        color: Colors.black, // Kolor tekstu na czarny
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
