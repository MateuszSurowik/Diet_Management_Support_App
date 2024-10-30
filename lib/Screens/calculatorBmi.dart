import 'package:flutter/material.dart';

class BmiCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BmiHomePage(),
    );
  }
}

class BmiHomePage extends StatefulWidget {
  @override
  _BmiHomePageState createState() => _BmiHomePageState();
}

class _BmiHomePageState extends State<BmiHomePage> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _result = '';

  void _calculateBMI() {
    double weight = double.tryParse(_weightController.text) ?? 0;
    double height = double.tryParse(_heightController.text) ?? 0;

    if (weight > 0 && height > 0) {
      double bmi = weight / (height * height);
      setState(() {
        _result = 'Your BMI is ${bmi.toStringAsFixed(2)}';
      });
    } else {
      setState(() {
        _result = 'Please enter valid weight and height.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _heightController,
              decoration: InputDecoration(
                labelText: 'Height (m)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _calculateBMI,
              child: Text('Calculate BMI'),
            ),
            SizedBox(height: 16.0),
            Text(
              _result,
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
