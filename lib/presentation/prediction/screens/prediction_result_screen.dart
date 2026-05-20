import 'package:flutter/material.dart';

class PredictionResultScreen extends StatelessWidget {
  const PredictionResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen =
        const Color(0xFF0AA06E);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Hasil Prediksi",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme:
            const IconThemeData(color: Colors.black),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              //  RESULT CARD 
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF059669),
                      Color(0xFF047857),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withOpacity(
                          0.15,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "RISIKO RENDAH",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Berdasarkan data kesehatan Anda, risiko penyakit jantung tergolong rendah.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            Colors.white.withOpacity(
                          0.9,
                        ),
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withOpacity(
                          0.15,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                      child: const Text(
                        "Tingkat Akurasi AI : 95%",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              //  HEALTH INFO 
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ringkasan Kesehatan",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    infoTile(
                      Icons.favorite_border,
                      "Tekanan Darah",
                      "120 / 80 mmHg",
                      Colors.red,
                    ),

                    const SizedBox(height: 16),

                    infoTile(
                      Icons.monitor_heart,
                      "Detak Jantung",
                      "72 bpm",
                      Colors.purple,
                    ),

                    const SizedBox(height: 16),

                    infoTile(
                      Icons.water_drop_outlined,
                      "Kolesterol",
                      "200 mg/dL",
                      Colors.blue,
                    ),

                    const SizedBox(height: 16),

                    infoTile(
                      Icons.monitor_weight,
                      "Berat Badan",
                      "70 Kg",
                      Colors.orange,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              //  RECOMMENDATION 
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Rekomendasi AI",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    recommendationTile(
                      "Perbanyak olahraga ringan minimal 30 menit per hari.",
                    ),

                    recommendationTile(
                      "Kurangi makanan berlemak tinggi dan gula berlebih.",
                    ),

                    recommendationTile(
                      "Lakukan pengecekan kesehatan rutin setiap bulan.",
                    ),

                    recommendationTile(
                      "Istirahat cukup dan kelola stres dengan baik.",
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
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Kembali",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  //  INFO TILE 
  Widget infoTile(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //  RECOMMENDATION 
  Widget recommendationTile(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 22,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}