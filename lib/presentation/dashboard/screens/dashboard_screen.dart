import 'package:flutter/material.dart';
import '../../auth/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Dio dio = Dio();

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  int totalPrediksi = 0;

  String statusRisiko = "-";

  String lastCheckDate = "-";

  //function to fetch dashboard data
  Future<void> fetchDashboardData() async {
    try {
      final token = await storage.read(key: AppConstants.tokenKey);
      print(token);
      final response = await dio.get(
        'http://127.0.0.1:8000/api/user/dashboard',

        options: Options(
          headers: {
            'Accept': 'application/json',

            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data['data'];

      final stats = data['stats'];

      final predictions = data['predictions'];

      setState(() {
        totalPrediksi = stats['total_checkups'] ?? 0;

        if (predictions.isNotEmpty) {
          statusRisiko = predictions[0]['result_level'];

          lastCheckDate = predictions[0]['created_at'];
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    initializeDateFormatting('id_ID', null);

    fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF0AA06E);

    final authState = context.watch<AuthBloc>().state;

    String userName = "User";

    if (authState is Authenticated) {
      userName = authState.user.name;
    }

    final currentDate = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      //  DRAWER
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

            // DASHBOARD
            drawerItem(Icons.dashboard, "Dashboard", () {
              Navigator.pop(context);
            }),

            // CEK KESEHATAN
            drawerItem(Icons.favorite, "Cek Kesehatan", () {
              Navigator.pushNamed(context, '/prediction');
            }),

            // RIWAYAT PREDIKSI
            drawerItem(Icons.history, "Riwayat Prediksi", () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Halaman Riwayat belum dibuat")),
              );
            }),

            // KONSULTASI AI
            drawerItem(Icons.chat_bubble_outline, "Konsultasi AI", () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Halaman Konsultasi AI belum dibuat"),
                ),
              );
            }),

            // PROFIL
            drawerItem(Icons.person_outline, "Profil", () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Halaman Profil belum dibuat")),
              );
            }),

            // LOGOUT
            drawerItem(Icons.logout, "Logout", () {
              Navigator.pushNamed(context, '/login');
            }),
          ],
        ),
      ),

      //  BODY
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //  HEADER
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

                            children: [
                              Text(
                                "Halo, $userName",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 2),

                              Text(
                                currentDate,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        //  PROFILE
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
                                  userName.isNotEmpty
                                      ? userName[0].toUpperCase()
                                      : "U",
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

                                children: [
                                  Text(
                                    "$userName",
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

              //  SUMMARY CARD
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
                            totalPrediksi.toString(),
                            primaryGreen,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: summaryCard(
                            Icons.health_and_safety,
                            "Status Risiko",
                            statusRisiko,
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

              //  RADAR SECTION
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
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
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

                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Belum ada riwayat"),
                              ),
                            );
                          },

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

  //  SUMMARY CARD
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

  //  DRAWER ITEM
  static Widget drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }
}
