import 'package:flutter/material.dart';
import '../../auth/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:go_router/go_router.dart';

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

  //  FETCH DATA
  Future<void> fetchDashboardData() async {
    try {
      final token = await storage.read(key: AppConstants.tokenKey);

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
              decoration: const BoxDecoration(color: primaryGreen),
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

            drawerItem(Icons.monitor_heart_outlined, "Cek Kesehatan", () {
              Navigator.pushNamed(context, '/prediction');
            }),

            drawerItem(Icons.favorite_border, "Hasil Terakhir", () {
              Navigator.pushNamed(context, '/prediction-result');
            }),

            drawerItem(Icons.history, "Riwayat Prediksi", () {
              Navigator.pushNamed(context, '/history');
            }),

            drawerItem(Icons.chat_bubble_outline, "Konsultasi AI", () {
              context.push('/chat');
            }),

            drawerItem(Icons.person_outline, "Profil", () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Halaman Profil belum dibuat")),
              );
            }),

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
                          icon: const Icon(Icons.menu, color: primaryGreen),
                        ),

                        const SizedBox(width: 6),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Halo, $userName",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                currentDate,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        //  PROFILE
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                          ),

                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: primaryGreen.withOpacity(0.1),

                                child: Text(
                                  userName.isNotEmpty
                                      ? userName[0].toUpperCase()
                                      : "U",
                                  style: const TextStyle(
                                    color: primaryGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 6),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
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

                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,

                  children: [
                    summaryCard(
                      Icons.favorite_border,
                      "Total Prediksi",
                      totalPrediksi.toString(),
                      primaryGreen,
                    ),

                    summaryCard(
                      Icons.health_and_safety,
                      "Status Risiko",
                      statusRisiko,
                      Colors.purple,
                    ),

                    summaryCard(
                      Icons.chat_bubble_outline,
                      "Konsultasi AI",
                      "0",
                      Colors.blue,
                    ),

                    summaryCard(
                      Icons.article_outlined,
                      "Artikel Dibaca",
                      "0",
                      Colors.orange,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              //  RADAR SECTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: radarSection(primaryGreen),
              ),

              const SizedBox(height: 20),

              //  PREDIKSI TERAKHIR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: predictionCard(primaryGreen, context),
              ),

              const SizedBox(height: 20),

              //  KONSULTASI
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: consultationCard(context),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  //  SUMMARY CARD
  Widget summaryCard(IconData icon, String title, String value, Color color) {
    return Container(
      constraints: const BoxConstraints(minHeight: 150),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icon, color: color, size: 22),
          ),

          const Spacer(),

          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget radarSection(Color primaryGreen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 760;
        final double chartSize = isWide
            ? 190
            : (constraints.maxWidth * 0.54).clamp(140, 190);
        final double infoSpacing = isWide ? 12 : 0;

        return Container(
          width: double.infinity,
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
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                        fontSize: 20,
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
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/history');
                                },
                                child: const Text("Riwayat"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Center(
                            child: Container(
                              width: chartSize,
                              height: chartSize,
                              decoration: BoxDecoration(
                                color: primaryGreen.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ...List.generate(4, (index) {
                                    final double size =
                                        chartSize - (index * 30);
                                    return Container(
                                      width: size,
                                      height: size,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: primaryGreen.withOpacity(0.12),
                                          width: 1,
                                        ),
                                      ),
                                    );
                                  }),
                                  Container(
                                    width: chartSize * 0.58,
                                    height: chartSize * 0.58,
                                    decoration: BoxDecoration(
                                      color: primaryGreen.withOpacity(0.14),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.show_chart,
                                      size: 46,
                                      color: Color(0xFF0AA06E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            totalPrediksi > 0
                                ? "Data Checkup Tersedia"
                                : "Belum Ada Data Checkup",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            totalPrediksi > 0
                                ? "Total checkup: $totalPrediksi"
                                : "Radar chart akan muncul setelah user melakukan prediksi.",
                            style: const TextStyle(
                              color: Colors.grey,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: radarInfoBox(
                                  "Checkup Terbaru",
                                  "19 Mei 2026",
                                  "Risiko terakhir: $statusRisiko",
                                  primaryGreen,
                                ),
                              ),
                              SizedBox(width: infoSpacing),
                              Expanded(
                                child: radarInfoBox(
                                  "Data Pembanding",
                                  "Belum ada pembanding",
                                  "Radar hanya menampilkan kondisi terbaru.",
                                  Colors.grey.shade200,
                                  textColor: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Ringkasan Perilaku & Riwayat",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  runSpacing: 10,
                                  spacing: 10,
                                  children: [
                                    radarSummaryItem("Gender", "female"),
                                    radarSummaryItem("Olahraga", "Jarang"),
                                    radarSummaryItem("Merokok", "Tidak"),
                                    radarSummaryItem(
                                      "Alkohol",
                                      "Tidak ada data",
                                    ),
                                    radarSummaryItem(
                                      "Riwayat Medis",
                                      "Tidak Ada Riwayat",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  fontSize: 20,
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
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/history');
                          },
                          child: const Text("Riwayat"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: Container(
                        width: chartSize,
                        height: chartSize,
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ...List.generate(4, (index) {
                              final double size = chartSize - (index * 30);
                              return Container(
                                width: size,
                                height: size,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryGreen.withOpacity(0.12),
                                    width: 1,
                                  ),
                                ),
                              );
                            }),
                            Container(
                              width: chartSize * 0.58,
                              height: chartSize * 0.58,
                              decoration: BoxDecoration(
                                color: primaryGreen.withOpacity(0.14),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.show_chart,
                                size: 46,
                                color: Color(0xFF0AA06E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      totalPrediksi > 0
                          ? "Data Checkup Tersedia"
                          : "Belum Ada Data Checkup",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      totalPrediksi > 0
                          ? "Total checkup: $totalPrediksi"
                          : "Radar chart akan muncul setelah user melakukan prediksi.",
                      style: const TextStyle(color: Colors.grey, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    radarInfoBox(
                      "Checkup Terbaru",
                      "19 Mei 2026",
                      "Risiko terakhir: $statusRisiko",
                      primaryGreen,
                    ),
                    const SizedBox(height: 12),
                    radarInfoBox(
                      "Data Pembanding",
                      "Belum ada pembanding",
                      "Radar hanya menampilkan kondisi terbaru.",
                      Colors.grey.shade200,
                      textColor: Colors.black87,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Ringkasan Perilaku & Riwayat",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            runSpacing: 10,
                            spacing: 10,
                            children: [
                              radarSummaryItem("Gender", "female"),
                              radarSummaryItem("Olahraga", "Jarang"),
                              radarSummaryItem("Merokok", "Tidak"),
                              radarSummaryItem("Alkohol", "Tidak ada data"),
                              radarSummaryItem(
                                "Riwayat Medis",
                                "Tidak Ada Riwayat",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  radarMetricBox("Usia", "21th", isWide: isWide),
                  radarMetricBox("Sistolik", "120 mmHg", isWide: isWide),
                  radarMetricBox("Diastolik", "75 mmHg", isWide: isWide),
                  radarMetricBox("Kolesterol", "100 mg/dL", isWide: isWide),
                  radarMetricBox("Detak", "80 bpm", isWide: isWide),
                  radarMetricBox("Berat", "40 kg", isWide: isWide),
                  radarMetricBox("Tinggi", "151 cm", isWide: isWide),
                  radarMetricBox("Gula Darah", "50 mg/dL", isWide: isWide),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget radarInfoBox(
    String title,
    String primary,
    String subtitle,
    Color background, {
    Color textColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 11),
          ),
          const SizedBox(height: 8),
          Text(
            primary,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget radarSummaryItem(String label, String value) {
    return Container(
      width: 134,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget radarMetricBox(String label, String value, {bool isWide = true}) {
    return Container(
      width: isWide ? 160 : null,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  //  PREDICTION CARD
  Widget predictionCard(Color primaryGreen, BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF059669), Color(0xFF047857)],
        ),

        borderRadius: BorderRadius.circular(28),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Prediksi Terakhir",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            statusRisiko.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 24),

          Container(
            width: 72,
            height: 72,

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.favorite_border,
              color: Colors.white,
              size: 34,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            totalPrediksi > 0 ? "PREDIKSI TERAKHIR" : "BELUM ADA PREDIKSI",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            totalPrediksi > 0
                ? "Terakhir checkup: $lastCheckDate"
                : "Mulai cek kesehatan untuk mendapatkan analisis risiko penyakit jantung.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              height: 1.6,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.4)),

                    foregroundColor: Colors.white,

                    padding: const EdgeInsets.symmetric(vertical: 14),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  onPressed: () {
                    Navigator.pushNamed(context, '/history');
                  },

                  child: const Text("Lihat Riwayat"),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,

                    foregroundColor: const Color(0xFF047857),

                    elevation: 0,

                    padding: const EdgeInsets.symmetric(vertical: 14),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  onPressed: () {
                    Navigator.pushNamed(context, '/prediction');
                  },

                  child: const Text(
                    "Detail Hasil",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //  CONSULTATION CARD
  Widget consultationCard(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Konsultasi Terakhir",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),

                  borderRadius: BorderRadius.circular(20),
                ),

                child: const Text(
                  "LIHAT",
                  style: TextStyle(
                    color: Color(0xFF059669),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          Container(
            width: 70,
            height: 70,

            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.chat_bubble_outline,
              size: 34,
              color: Colors.grey.shade400,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            "BELUM ADA KONSULTASI",
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,

            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),

                side: BorderSide(color: Colors.grey.shade300),

                padding: const EdgeInsets.symmetric(vertical: 15),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              onPressed: () {
                context.push('/chat');
              },

              child: const Text(
                "+ Mulai Konsultasi Baru",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
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
