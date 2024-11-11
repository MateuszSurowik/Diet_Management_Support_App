class FoodItem {
  final String name;
  final double calories;
  final String macros;

  FoodItem({
    required this.name,
    required this.calories,
    required this.macros,
  });

  // Metoda fabryczna do tworzenia FoodItem z mapy
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'] as String,
      calories: map['calories'] as double,
      macros: map['macros'] as String,
    );
  }

  // Konwersja do mapy (na wypadek, gdyby była potrzebna do zapisania)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'macros': macros,
    };
  }
}
