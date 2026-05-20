import 'package:flutter/material.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final Color primaryGreen = const Color(0xFF0AA06E);

  final TextEditingController usiaController = TextEditingController();

  final TextEditingController sistolikController = TextEditingController();

  final TextEditingController diastolikController = TextEditingController();

  final TextEditingController kolesterolController = TextEditingController();

  final TextEditingController gulaController = TextEditingController();

  final TextEditingController detakController = TextEditingController();

  final TextEditingController beratController = TextEditingController();

  final TextEditingController tinggiController = TextEditingController();

  String gender = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Cek Kesehatan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Cek Kesehatan Jantung",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "Lengkapi data kesehatan Anda untuk mendapatkan prediksi AI.",
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),

              const SizedBox(height: 24),

              //  DEMOGRAFI
              sectionCard(
                icon: Icons.person_outline,
                color: Colors.green,
                title: "Data Demografis",
                child: Column(
                  children: [
                    buildInput(
                      "Usia",
                      "Contoh: 35",
                      usiaController,
                      Icons.calendar_today,
                    ),

                    const SizedBox(height: 20),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Jenis Kelamin",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(child: genderButton("Laki-laki")),

                            const SizedBox(width: 12),

                            Expanded(child: genderButton("Perempuan")),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              //  DATA VITAL
              sectionCard(
                icon: Icons.monitor_heart_outlined,
                color: Colors.purple,
                title: "Data Vital",
                child: Column(
                  children: [
                    buildInput(
                      "Tekanan Darah Sistolik",
                      "120",
                      sistolikController,
                      Icons.favorite_border,
                    ),

                    const SizedBox(height: 18),

                    buildInput(
                      "Tekanan Darah Diastolik",
                      "80",
                      diastolikController,
                      Icons.favorite_border,
                    ),

                    const SizedBox(height: 18),

                    buildInput(
                      "Kolesterol Total",
                      "200",
                      kolesterolController,
                      Icons.water_drop_outlined,
                    ),

                    const SizedBox(height: 18),

                    buildInput(
                      "Gula Darah Puasa",
                      "95",
                      gulaController,
                      Icons.water_drop_outlined,
                    ),

                    const SizedBox(height: 18),

                    buildInput(
                      "Detak Jantung",
                      "72",
                      detakController,
                      Icons.monitor_heart,
                    ),

                    const SizedBox(height: 18),

                    buildInput(
                      "Berat Badan",
                      "70",
                      beratController,
                      Icons.monitor_weight,
                    ),

                    const SizedBox(height: 18),

                    buildInput(
                      "Tinggi Badan",
                      "170",
                      tinggiController,
                      Icons.height,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              //  BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/prediction-result');
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Mulai Analisis AI",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      SizedBox(width: 10),

                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  //  CARD
  Widget sectionCard({
    required IconData icon,
    required Color color,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),

              const SizedBox(width: 14),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          child,
        ],
      ),
    );
  }

  //  INPUT
  Widget buildInput(
    String title,
    String hint,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

        const SizedBox(height: 10),

        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  //  GENDER BUTTON
  Widget genderButton(String text) {
    bool isSelected = gender == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          gender = text;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        height: 55,

        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : const Color(0xFFF8FAFC),

          borderRadius: BorderRadius.circular(16),

          border: Border.all(
            color: isSelected ? primaryGreen : Colors.grey.shade300,
          ),
        ),

        child: Center(
          child: Text(
            text,

            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,

              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
