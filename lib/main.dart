import 'package:diet_management_suppport_app/Screens/CalculatorBmiScreen.dart';
import 'package:flutter/material.dart';
import 'package:diet_management_suppport_app/Screens/MealScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitatu-like Meal Tracker',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MealScreen(),
    );
  }
}
