import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(IMCApp());
}

class IMCApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de IMC',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  double imc = 0.0;
  List<double> savedIMCs = [];

  @override
  void initState() {
    super.initState();
    loadSavedData();
  }

  void loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedWeight = prefs.getDouble('weight');
    final savedHeight = prefs.getDouble('height');
    if (savedWeight != null && savedHeight != null) {
      setState(() {
        weightController.text = savedWeight.toString();
        heightController.text = savedHeight.toString();
      });
    }
    final imcs = prefs.getStringList('imcs');
    if (imcs != null) {
      setState(() {
        savedIMCs = imcs.map((imc) => double.parse(imc)).toList();
      });
    }
  }

  void saveData() async {
    final weight = double.tryParse(weightController.text) ?? 0;
    final height = double.tryParse(heightController.text) ?? 0;

    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('weight', weight);
    prefs.setDouble('height', height);

    // Calcular o IMC e salvar na lista
    if (weight > 0 && height > 0) {
      final heightMeters = height / 100;
      final calculatedIMC = weight / (heightMeters * heightMeters);

      savedIMCs.add(calculatedIMC);
      prefs.setStringList(
          'imcs', savedIMCs.map((imc) => imc.toString()).toList());
    }
  }

  void calculateIMC() {
    final weight = double.tryParse(weightController.text) ?? 0;
    final height = double.tryParse(heightController.text) ?? 0;

    if (weight > 0 && height > 0) {
      final heightMeters = height / 100;
      final calculatedIMC = weight / (heightMeters * heightMeters);

      setState(() {
        imc = calculatedIMC;
        saveData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora de IMC'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Peso (kg)'),
            ),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Altura (cm)'),
            ),
            ElevatedButton(
              onPressed: calculateIMC,
              child: Text('Calcular IMC'),
            ),
            SizedBox(height: 16),
            Text('Seu IMC: ${imc.toStringAsFixed(2)}'),
            SizedBox(height: 16),
            Text('IMCs Salvos:'),
            Expanded(
              child: ListView.builder(
                itemCount: savedIMCs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                        'IMC ${index + 1}: ${savedIMCs[index].toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
