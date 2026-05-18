import 'package:flutter/material.dart';

class PredictionResultScreen extends StatelessWidget {
  const PredictionResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const emerald = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Prediction Result',
        ),

        backgroundColor: emerald,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            //  RESULT CARD 
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(24),
              ),

              child: Column(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 80,
                    color: Colors.red.shade400,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'High Risk',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    '87% Probability',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'You are advised to consult a cardiologist and adopt a healthier lifestyle.',
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            //  BUTTON 
            SizedBox(
              width: double.infinity,
              height: 56,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: emerald,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/',
                  );
                },

                child: const Text(
                  'Back to Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}