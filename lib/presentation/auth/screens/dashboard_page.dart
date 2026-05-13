import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen =
        const Color(0xFF0AA06E);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // APP BAR
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Text(
                      "HeartCare",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Spacer(),

                    // LOGIN BUTTON
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/login',
                        );
                      },

                      child: Text(
                        "Masuk",
                        style: TextStyle(
                          color: primaryGreen,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // REGISTER BUTTON
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            primaryGreen,
                        foregroundColor:
                            Colors.white,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  12),
                        ),
                      ),

                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/register',
                        );
                      },

                      child: const Text("Daftar"),
                    ),
                  ],
                ),
              ),

              // HERO SECTION
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryGreen,
                  borderRadius:
                      const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withOpacity(
                                0.15),
                        borderRadius:
                            BorderRadius.circular(30),
                      ),
                      child: const Text(
                        "PREDIKSI RISIKO PENYAKIT JANTUNG",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight:
                              FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Jaga Jantung Anda\nDengan Teknologi AI Terpecaya",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "HeartCare membantu Anda mendeteksi risiko penyakit"
                      "jantung sejak dini menggunakan kecerdasan buatan"
                      "Dapatkan prediksi akurat dan konsultasi AI kapan saja.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.7,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // BUTTON LOGIN
                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.white,
                          foregroundColor:
                              primaryGreen,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    16),
                          ),
                        ),

                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/login',
                          );
                        },

                        child: const Text(
                          "Mulai Cek Kesehatan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // BUTTON REGISTER
                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: OutlinedButton(
                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              Colors.white,
                          side: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    16),
                          ),
                        ),

                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/register',
                          );
                        },

                        child: const Text(
                          "Daftar Sekarang",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // IMAGE
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(24),
                      child: Image.network(
                        "https://images.unsplash.com/photo-1584515933487-779824d29309",
                        height: 230,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // VERIFIED CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),

                      child: Row(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.all(
                                    12),
                            decoration: BoxDecoration(
                              color: primaryGreen
                                  .withOpacity(0.1),
                              borderRadius:
                                  BorderRadius
                                      .circular(14),
                            ),
                            child: Icon(
                              Icons.shield_outlined,
                              color: primaryGreen,
                            ),
                          ),

                          const SizedBox(width: 14),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  "Teknologi Terverifikasi",
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                SizedBox(height: 4),

                                Text(
                                  "Didukung keputusan klinis digital.",
                                  style: TextStyle(
                                    color:
                                        Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // FOCUS SECTION
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Fokus Kami Untuk\nKesehatan Anda",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    GridView.count(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.3,

                      children: [
                        focusCard(
                          Icons.monitor_heart,
                          "Tekanan Darah",
                          primaryGreen,
                        ),

                        focusCard(
                          Icons.water_drop_outlined,
                          "Kadar Kolesterol",
                          primaryGreen,
                        ),

                        focusCard(
                          Icons.favorite_border,
                          "Gaya Hidup",
                          primaryGreen,
                        ),

                        focusCard(
                          Icons.health_and_safety,
                          "Deteksi Dini",
                          primaryGreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // FEATURES
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Column(
                  children: [
                    const Text(
                      "Kenapa Memilih\nHeartCare?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Platform prediksi risiko jantung "
                      "berbasis AI dengan fitur lengkap.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 25),

                    featureCard(
                      Icons.psychology,
                      "Prediksi AI Akurat",
                      "Algoritma machine learning terlatih dengan ribuan"
                      "data medis untuk hasil prediksi yang presisi",
                      primaryGreen,
                    ),

                    featureCard(
                      Icons.chat_bubble_outline,
                      "Konsultasi AI 24/7",
                      "Tanyakan apapun seputar kesehatan jantung anda"
                      "kepada chatbot AI yang responsif.",
                      primaryGreen,
                    ),

                    featureCard(
                      Icons.history,
                      "Riwayat Lengkap",
                      "Simpan data pantau semua hasil prediksi dan"
                      "konsultasi anda dalam satu dashboard.",
                      primaryGreen,
                    ),

                    featureCard(
                      Icons.lock_outline,
                      "Data Aman & Privat",
                      "Semua data kesehatan anda terenkripsi"
                      "dan dijamin kerahasiaannya.",
                      primaryGreen,
                    ),

                    featureCard(
                      Icons.book_outlined,
                      "Artikel Kesehatan",
                      "Akses ratusan artikel tentang kesehatan jantung"
                      "yang ditulis oleh ahli kesehatan.",
                      primaryGreen,
                    ),

                    featureCard(
                      Icons.monitor_heart,
                      "Rekomendasi Personal",
                      "Dapatkan saran gaya hidup sehat yang disesuaikan"
                      "dengan kondisi medis anda.",
                      primaryGreen,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // HOW IT WORKS
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: Colors.white,

                child: Column(
                  children: [
                    const Text(
                      "Cara Kerja HeartCare",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    stepItem(
                      "1",
                      "Daftar Gratis",
                      "Buat akun dengan email Anda.",
                      primaryGreen,
                    ),

                    stepItem(
                      "2",
                      "Isi Data Kesehatan",
                      "Masukkan data kesehatan Anda.",
                      primaryGreen,
                    ),

                    stepItem(
                      "3",
                      "Dapatkan Hasil",
                      "AI akan memberikan prediksi.",
                      primaryGreen,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),
              
              // HEALTH ARTICLES
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  ),
                  child: Column(
                    crossAxisAlignment:
                      CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Artikel Kesehatan\nTerbaru",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  const SizedBox(height: 10),

                  const Text(
                    "Artikel kesehatan akan tampil "
                    "di sini.",
                  style: TextStyle(
                    color: Colors.grey,
                    height: 1.6,
                  ),
                ),

                  const SizedBox(height: 24),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 60,
                        horizontal: 20,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(24),
                      ),

                      child: Column(
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 70,
                            color:
                                primaryGreen.withOpacity(0.5),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "Belum Ada Artikel",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Artikel kesehatan terbaru\nakan muncul di sini.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // CTA
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(28),

                decoration: BoxDecoration(
                  color: primaryGreen,
                  borderRadius:
                      BorderRadius.circular(30),
                ),

                child: Column(
                  children: [
                    const Text(
                      "Mulai Jaga Kesehatan\nJantung Anda Hari Ini",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Bergabunglah dengan ribuan pengguna "
                      "HeartCare sekarang juga.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.white,
                          foregroundColor:
                              primaryGreen,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    16),
                          ),
                        ),

                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/register',
                          );
                        },

                        child: const Text(
                          "Daftar Sekarang",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget focusCard(
    IconData icon,
    String title,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
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

          const SizedBox(height: 16),

          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget featureCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget stepItem(
    String number,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 26),

      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}