import 'package:diet_management_suppport_app/main.dart';
import 'package:diet_management_suppport_app/models/userLimits.dart';
import 'package:flutter/material.dart';

class YourGoalsScreen extends StatefulWidget {
  const YourGoalsScreen({super.key});

  @override
  State<YourGoalsScreen> createState() => _YourGoalsScreenState();
}

class _YourGoalsScreenState extends State<YourGoalsScreen> {
  final TextEditingController _calorieLimitController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();

  double _protein = protein;
  double _fat = fat;
  double _carbs = carbs;
  double _caloriesLimit = calories;

  @override
  void initState() {
    super.initState();
    _proteinController.text = _protein.toInt().toString();
    _fatController.text = _fat.toInt().toString();
    _carbsController.text = _carbs.toInt().toString();
    _calorieLimitController.text = _caloriesLimit.toInt().toString();
  }

  void _updateSliderValue(TextEditingController controller, double newValue) {
    setState(() {
      controller.text = newValue.toInt().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Stylish heading
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Your Goal Section',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              // Description text
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'Hi! Welcome to your goal section. Here, you can set your current goals for calories, protein, fat, and carbs. We wish you the best of luck in achieving them and living a healthier lifestyle!',
                  style: TextStyle(
                    fontSize: 16,
                    color: kIsDark ? Colors.white : Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Calorie limit input
              TextField(
                controller: _calorieLimitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Calorie Limit',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),

              // Protein slider and input field
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Protein"),
                        Slider(
                          value: _protein,
                          min: 1,
                          max: 600,
                          divisions: 599,
                          label: _protein.toInt().toString(),
                          onChanged: (value) {
                            setState(() {
                              _protein = value;
                              _proteinController.text =
                                  value.toInt().toString();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 60,
                    child: TextField(
                      controller: _proteinController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'g',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _protein = double.tryParse(value) ?? _protein;
                        });
                      },
                    ),
                  ),
                ],
              ),

              // Fat slider and input field
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Fat"),
                        Slider(
                          value: _fat,
                          min: 1,
                          max: 600,
                          divisions: 599,
                          label: _fat.toInt().toString(),
                          onChanged: (value) {
                            setState(() {
                              _fat = value;
                              _fatController.text = value.toInt().toString();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 60,
                    child: TextField(
                      controller: _fatController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'g',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _fat = double.tryParse(value) ?? _fat;
                        });
                      },
                    ),
                  ),
                ],
              ),

              // Carbohydrates slider and input field
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Carbohydrates"),
                        Slider(
                          value: _carbs,
                          min: 1,
                          max: 600,
                          divisions: 599,
                          label: _carbs.toInt().toString(),
                          onChanged: (value) {
                            setState(() {
                              _carbs = value;
                              _carbsController.text = value.toInt().toString();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 60,
                    child: TextField(
                      controller: _carbsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'g',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _carbs = double.tryParse(value) ?? _carbs;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    protein = _protein;
                    carbs = _carbs;
                    fat = _fat;
                    calories = _caloriesLimit;
                  },
                  child: Text("Save changes")),
            ],
          ),
        ),
      ),
    );
  }
}
