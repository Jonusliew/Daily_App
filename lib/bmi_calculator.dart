import 'package:flutter/material.dart';

class BMICalculatorScreen extends StatefulWidget {
  final bool isEnglish;
  final VoidCallback toggleLanguage;

  BMICalculatorScreen({required this.isEnglish, required this.toggleLanguage});

  @override
  _BMICalculatorScreenState createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  double? _bmi;
  String _bmiCategory = '';

  void _calculateBMI() {
    final heightCm = double.tryParse(_heightController.text);
    final weightKg = double.tryParse(_weightController.text);

    if (heightCm != null && weightKg != null) {
      final heightM = heightCm / 100;
      final bmi = weightKg / (heightM * heightM);

      setState(() {
        _bmi = bmi;
        _bmiCategory = _getBMICategory(bmi);
      });
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return widget.isEnglish ? 'Underweight' : '體重過輕';
    } else if (bmi < 24.9) {
      return widget.isEnglish ? 'Normal weight' : '正常體重';
    } else if (bmi < 29.9) {
      return widget.isEnglish ? 'Overweight' : '過重';
    } else {
      return widget.isEnglish ? 'Obesity' : '肥胖';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = widget.isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEn ? 'BMI Calculator' : 'BMI(身體質量指數)計算機',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[200],
      ),
      backgroundColor: Colors.blueGrey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _heightController,
              decoration: InputDecoration(
                labelText: isEn ? 'Height (cm)' : '身高 (公分)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: isEn ? 'Weight (kg)' : '體重 (公斤)',
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
                isEn ? 'Calculate BMI' : '計算 BMI',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 16),
            if (_bmi != null) ...[
              Text(
                '${isEn ? 'Your BMI' : '您的身體質量指數'}: ${_bmi!.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 24, color: Colors.grey[700]),
              ),
              Text(
                '${isEn ? 'Category' : '類別'}: $_bmiCategory',
                style: TextStyle(fontSize: 20, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              Text(
                isEn ? 'BMI Categories:' : 'BMI 類別：',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                isEn ? 'Underweight: BMI < 18.5' : '體重過輕：BMI < 18.5',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              Text(
                isEn ? 'Normal weight: BMI = 18.5 ~ 24.9' : '正常體重：BMI = 18.5 ~ 24.9',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              Text(
                isEn ? 'Overweight: BMI = 25 ~ 29.9' : '過重：BMI = 25 ~ 29.9',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              Text(
                isEn ? 'Obesity: BMI ≥ 30' : '肥胖：BMI ≥ 30',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
