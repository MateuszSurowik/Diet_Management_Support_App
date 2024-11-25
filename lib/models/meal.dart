import 'package:diet_management_suppport_app/models/foodItem.dart';

class Meal {
  final String name;
  final List<FoodItem> items;

  Meal({
    required this.name,
    required this.items,
  });

  // Metoda fabryczna do tworzenia Meal z mapy
  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      name: map['name'] as String,
      items: (map['items'] as List<dynamic>)
          .map((item) => FoodItem.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }

  // Konwersja do mapy
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  // Funkcja zliczająca całkowite kalorie
  double calculateTotalCalories() {
    return items.fold(0, (sum, item) => sum + item.calories);
  }
}
