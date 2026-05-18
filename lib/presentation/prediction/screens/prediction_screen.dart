import 'package:flutter/material.dart';

//  GLOBAL COLOR 
const emerald = Color(0xFF10B981);

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final TextEditingController ageController = TextEditingController();

  final TextEditingController cholesterolController =
      TextEditingController();

  final TextEditingController bpController = TextEditingController();

  @override
  void dispose() {
    ageController.dispose();
    cholesterolController.dispose();
    bpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      //  APPBAR 
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: emerald,
        foregroundColor: Colors.white,

        title: const Text(
          'AI Prediction',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      //  BODY 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  HEADER CARD 
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: emerald,
                borderRadius: BorderRadius.circular(24),
              ),

              child: const Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 42,
                  ),

                  SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      'Predict your heart disease risk using AI technology.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            //  INPUT AGE 
            _buildInput(
              'Age',
              ageController,
              Icons.cake_outlined,
            ),

            const SizedBox(height: 18),

            //  INPUT CHOLESTEROL 
            _buildInput(
              'Cholesterol',
              cholesterolController,
              Icons.monitor_heart_outlined,
            ),

            const SizedBox(height: 18),

            //  INPUT BLOOD PRESSURE 
            _buildInput(
              'Blood Pressure',
              bpController,
              Icons.favorite_border,
            ),

            const SizedBox(height: 35),

            //  BUTTON 
            SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: emerald,
                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                  },

                child: const Text(
                  'Predict Now',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  INPUT FIELD 
  Widget _buildInput(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(icon),

        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: emerald,
            width: 2,
          ),
        ),
      ),
    );
  }
}