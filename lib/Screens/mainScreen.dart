import 'package:diet_management_suppport_app/Screens/aiAssistantScreen.dart';
import 'package:diet_management_suppport_app/Screens/calculatorBmi.dart';
import 'package:diet_management_suppport_app/Screens/mealSelectionScreen.dart';
import 'package:diet_management_suppport_app/Screens/userProfileScreen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  Widget? actualScreen = MealSelectionScreen();
  void _onBottomNavTap(int index) {
    // dokonczyc poprawic
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        actualScreen = MealSelectionScreen();
      } else if (_selectedIndex == 1) {
        actualScreen = BmiHomePage();
      } else if (_selectedIndex == 2) {
        actualScreen = AiAssistantScreen();
      } else if (_selectedIndex == 3) {
        actualScreen = UserProfileScreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // Obsługa wyboru daty
            },
          ),
        ],
      ),
      body: actualScreen,
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer_outlined),
            label: 'Ask AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
