import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF0AA06E);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      //DRAWER
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: primaryGreen),

              child: const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "HeartCare",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            drawerItem(Icons.dashboard, "Dashboard", () {
              Navigator.pop(context);
            }),

            drawerItem(Icons.favorite, "Cek Kesehatan", () {}),

            drawerItem(Icons.history, "Riwayat Prediksi", () {}),

            drawerItem(Icons.chat_bubble_outline, "Konsultasi AI", () {}),

            drawerItem(Icons.person_outline, "Profil", () {}),

            drawerItem(Icons.logout, "Logout", () {
              Navigator.pushNamed(context, '/login');
            }),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //HEADER
              Builder(
                builder: (context) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    color: Colors.white,

                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },

                          icon: Icon(Icons.menu, color: primaryGreen),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Halo, User1",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 2),

                              Text(
                                "Senin, 18 Mei 2026",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // PROFILE
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.grey.shade200),
                          ),

                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: primaryGreen.withOpacity(0.1),
                                child: Text(
                                  "U",
                                  style: TextStyle(
                                    color: primaryGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "User1",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Text(
                                    "ID: #HP-2026",
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              //SUMMARY CARDS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: summaryCard(
                            Icons.favorite_border,
                            "Total Prediksi",
                            "0",
                            primaryGreen,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: summaryCard(
                            Icons.health_and_safety,
                            "Status Risiko",
                            "-",
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: summaryCard(
                            Icons.chat_bubble_outline,
                            "Konsultasi AI",
                            "0",
                            Colors.blue,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: summaryCard(
                            Icons.article_outlined,
                            "Artikel Dibaca",
                            "0",
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              //RADAR SECTION
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Perbandingan Checkup",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),

                              SizedBox(height: 8),

                              Text(
                                "Radar Kondisi Tubuh",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                          ),

                          onPressed: () {},

                          child: const Text("Riwayat"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    Container(
                      width: 90,
                      height: 90,

                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),

                      child: Icon(
                        Icons.show_chart,
                        size: 45,
                        color: primaryGreen,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Belum Ada Data Checkup",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Radar chart akan muncul\nsetelah user melakukan prediksi.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, height: 1.6),
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

  // SUMMARY CARD
  Widget summaryCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icon, color: color),
          ),

          const SizedBox(height: 16),

          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // DRAWER ITEM
  static Widget drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }
}
