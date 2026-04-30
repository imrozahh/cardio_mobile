import 'package:flutter/material.dart';

class PredictionResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  const PredictionResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Prediksi')),
      body: Center(child: Text('Result: $result')),
    );
  }
}
