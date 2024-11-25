import 'package:diet_management_suppport_app/Screens/aiAssistantScreen.dart';
import 'package:diet_management_suppport_app/Screens/analiticsScreen.dart';
import 'package:diet_management_suppport_app/Screens/calculatorBmi.dart';
import 'package:diet_management_suppport_app/Screens/dietBlogsScreen.dart';
import 'package:diet_management_suppport_app/Screens/mealSelectionScreen.dart';
import 'package:diet_management_suppport_app/Screens/userProfileScreen.dart';
import 'package:diet_management_suppport_app/Screens/yourGoalsScreen.dart';
import 'package:diet_management_suppport_app/main.dart';
import 'package:diet_management_suppport_app/models/userLimits.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.toggleTheme});
  final Function(int) toggleTheme;
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _selectedIndexDrawer = 0;
  Widget? actualScreen = MealSelectionScreen(
    track: false,
    date: DateTime.now(),
  );
  DateTime _selectedDate = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isTracking = true;
  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        actualScreen = MealSelectionScreen(
          track: track,
          date: _selectedDate,
        );
      } else if (_selectedIndex == 1) {
        actualScreen = BmiHomePage();
      } else if (_selectedIndex == 2) {
        actualScreen = AiAssistantScreen();
      } else if (_selectedIndex == 3) {
        actualScreen = UserProfileScreen();
      }
    });
  }

  void _onTrackerClick() {
    if (_isTracking) {
      _showTrackerDatePicker();
      track = true;
      actualScreen = MealSelectionScreen(
        track: true,
        date: _selectedDate,
      );
    } else {
      setState(() {
        _startDate = null;
        _endDate = null;
        _isTracking = !_isTracking;
        track = !track;
        actualScreen = MealSelectionScreen(track: false, date: _selectedDate);
      });
      _showWelcomeBackDialog();
    }
  }

  void _showWelcomeBackDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Welcome Back!"),
          content: Text(
            "We’re thrilled to see you resuming your diet tracking journey. "
            "Let's make progress together toward your goals!",
          ),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Zamknij dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTrackerDatePicker() async {
    // Wybór pierwszej daty
    DateTime? startDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (startDate != null) {
      // Wybór drugiej daty
      DateTime? endDate = await showDatePicker(
        context: context,
        initialDate: startDate,
        firstDate: startDate,
        lastDate: DateTime(2100),
      );

      if (endDate != null) {
        // Zapisujemy wybrane daty
        setState(() {
          _startDate = startDate;
          _endDate = endDate;
          _isTracking = false;
        });
        startDateLimit = _startDate;
        endDateLimit = _endDate;
      }
    }
    print("${startDate}  ${_endDate}");
  }

  void _onDrawerTap(int index) {
    setState(() {
      _selectedIndexDrawer = index;
      if (_selectedIndexDrawer == 0) {
        actualScreen = YourGoalsScreen();
      } else if (_selectedIndexDrawer == 1) {
        actualScreen = AnaliticsScreen();
      } else if (_selectedIndexDrawer == 2) {
        actualScreen = DietBlogsScreen();
      } else if (_selectedIndexDrawer == 3) {}
      Navigator.pop(context);
    });
  }

  // Funkcja do wybrania daty
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
        centerTitle: true, // Wyświetlanie daty
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              _selectDate(context); // Wywołanie wyboru daty po kliknięciu
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.check),
              title: const Text('Your Goals'),
              onTap: () => _onDrawerTap(0),
            ),
            ListTile(
              leading: const Icon(Icons.insert_chart_outlined_outlined),
              title: const Text('Analitics'),
              onTap: () => _onDrawerTap(1),
            ),
            ListTile(
              leading: const Icon(Icons.newspaper_outlined),
              title: const Text('Diet Blogs'),
              onTap: () => _onDrawerTap(2),
            ),
            ExpansionTile(
              leading: const Icon(Icons.style_outlined),
              title: const Text('Style Your UI'),
              children: <Widget>[
                ListTile(
                  title: const Text('Light Mode'),
                  onTap: () => widget.toggleTheme(1),
                ),
                ListTile(
                  title: const Text('Dark Mode'),
                  onTap: () => widget.toggleTheme(2),
                ),
              ],
            ),
            ListTile(
              leading: Icon(
                _isTracking
                    ? Icons.motion_photos_pause
                    : Icons.motion_photos_on,
              ),
              title: Text(
                  _isTracking ? 'stop Tracking Diet' : 'Start Tracking Diet'),
              onTap: () {
                _onTrackerClick();
              },
            ),
          ],
        ),
      ),
      body: actualScreen,
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: kIsDark ? Colors.white : Colors.black,
        selectedItemColor: kIsDark ? Colors.white : Colors.black,
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
