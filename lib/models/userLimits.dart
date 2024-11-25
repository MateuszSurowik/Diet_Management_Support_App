import 'package:diet_management_suppport_app/models/foodItem.dart';
import 'package:diet_management_suppport_app/models/meal.dart';

double protein = 100;
double fat = 50;
double carbs = 150;
double calories = 2000;

DateTime? startDateLimit;
DateTime? endDateLimit;
List<FoodItem> analiticsUserMeals = [];
List<bool> userGlasses = [];
bool track = false;
String userId = '';
List<Meal> userMealData =
    List.generate(24, (hour) => Meal(name: '$hour:00', items: []));
