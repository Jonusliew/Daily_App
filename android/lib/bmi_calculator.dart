import 'package:flutter/material.dart';

void main() {
  runApp(BMICalculatorApp());
}

class BMICalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: BMICalculatorScreen(),
    );
  }
}

class BMICalculatorScreen extends StatefulWidget {
  @override
  _BMICalculatorScreenState createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  double? _bmi;
  String _bmiCategory = '';

  void _calculateBMI() {
    final heightCm = double.tryParse(_heightController.text);  // Height in cm
    final weightKg = double.tryParse(_weightController.text);   // Weight in kg

    if (heightCm != null && weightKg != null) {
      final heightM = heightCm / 100;  // Convert height to meters
      final bmi = weightKg / (heightM * heightM);  // BMI formula

      setState(() {
        _bmi = bmi;
        _bmiCategory = _getBMICategory(bmi);
      });
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi >= 18.5 && bmi < 24.9) {
      return 'Normal weight';
    } else if (bmi >= 25 && bmi < 29.9) {
      return 'Overweight';
    } else {
      return 'Obesity';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator', style: TextStyle(color: Colors.white)), // Header text white
        backgroundColor: Colors.blueGrey[200], // Header color
      ),
      backgroundColor: Colors.blueGrey[100],  // Background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _heightController,
              decoration: InputDecoration(
                labelText: 'Height (cm)',  // Height in cm
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',  // Weight remains in kg
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _calculateBMI,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[300],
              ),
              child: Text(
                'Calculate BMI',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 16),
            if (_bmi != null) ...[
              Text(
                'Your BMI: ${_bmi!.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 24, color: Colors.grey[700]),
              ),
              Text(
                'Category: $_bmiCategory',
                style: TextStyle(fontSize: 20, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              // Display the updated BMI ranges and categories
              Text(
                'BMI Categories:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'Underweight: BMI < 18.5',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              Text(
                'Normal weight: BMI = 18.5 ~ 24.9',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              Text(
                'Overweight: BMI = 25 ~ 29.9',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              Text(
                'Obesity: BMI ≥ 30',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
