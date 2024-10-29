import 'FoodItem.dart';

class Meal {
  final String name;
  final List<FoodItem> items;

  Meal({
    required this.name,
    required this.items,
  });

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
}
