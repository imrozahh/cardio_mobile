import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../auth/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../prediction/bloc/prediction_bloc.dart';
import '../../prediction/bloc/prediction_event.dart';
import '../../prediction/bloc/prediction_state.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui' as ui;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Dio dio = Dio();

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  int totalPrediksi = 0;

  int currentIndex = 0;

  String statusRisiko = "-";

  String lastCheckDate = "-";

  String lastConsultationTitle = "BELUM ADA KONSULTASI";
  String lastConsultationMessage = "Mulai konsultasi pertama Anda hari ini.";
  String lastConsultationDate = "-";
  bool isLoadingConsultation = false;

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

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  List<dynamic> _extractList(dynamic value) {
    if (value is List) return value;

    if (value is Map) {
      final map = Map<String, dynamic>.from(value);

      if (map['data'] is List) return map['data'] as List;
      if (map['chats'] is List) return map['chats'] as List;
      if (map['messages'] is List) return map['messages'] as List;

      if (map['data'] is Map) {
        return _extractList(map['data']);
      }
    }

    return <dynamic>[];
  }

  Future<void> fetchLastConsultation() async {
    setState(() {
      isLoadingConsultation = true;
    });

    try {
      final token = await storage.read(key: AppConstants.tokenKey);

      final response = await dio.get(
        'http://127.0.0.1:8000/api/chats',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final chats = _extractList(response.data);

      if (chats.isEmpty) {
        if (!mounted) return;
        setState(() {
          lastConsultationTitle = "BELUM ADA KONSULTASI";
          lastConsultationMessage = "Mulai konsultasi pertama Anda hari ini.";
          lastConsultationDate = "-";
        });
        return;
      }

      final latest = _asMap(chats.first);

      final message =
          latest['message'] ??
          latest['question'] ??
          latest['prompt'] ??
          latest['user_message'] ??
          latest['content'] ??
          latest['last_message'] ??
          latest['title'] ??
          '';

      final answer =
          latest['answer'] ??
          latest['response'] ??
          latest['ai_response'] ??
          latest['reply'] ??
          latest['bot_message'] ??
          '';

      final createdAt =
          latest['created_at'] ?? latest['updated_at'] ?? latest['date'] ?? '';

      if (!mounted) return;

      setState(() {
        lastConsultationTitle = "KONSULTASI TERAKHIR";
        lastConsultationMessage = answer.toString().isNotEmpty
            ? answer.toString()
            : message.toString().isNotEmpty
            ? message.toString()
            : "Konsultasi terakhir tersedia.";
        lastConsultationDate = createdAt.toString().isNotEmpty
            ? _formatDisplayDate(createdAt)
            : "-";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        lastConsultationTitle = "GAGAL MEMUAT KONSULTASI";
        lastConsultationMessage =
            "Tidak bisa mengambil data konsultasi terakhir.";
        lastConsultationDate = "-";
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoadingConsultation = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    initializeDateFormatting('id_ID', null);

    fetchDashboardData();
    fetchLastConsultation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PredictionBloc>().add(const LoadPredictionHistory());
    });
  }

  void _onBottomNavTap(int index) {
    setState(() {
      currentIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/prediction');
        break;
      case 2:
        context.go('/prediction/result');
        break;
      case 3:
        context.go('/history');
        break;
      case 4:
        context.go('/chat');
        break;
    }
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

    // Ambil semua riwayat prediksi user login dari PredictionBloc.
    // Data ini dipakai untuk total checkup, status terakhir, dan radar pembanding.
    final predictionState = context.watch<PredictionBloc>().state;
    final List<dynamic> histories = predictionState is PredictionLoaded
        ? predictionState.items
        : <dynamic>[];

    int displayedTotal = histories.isNotEmpty
        ? histories.length
        : totalPrediksi;
    String displayedRisk = statusRisiko;
    String displayedLastCheck = lastCheckDate;

    if (histories.isNotEmpty) {
      final latest = histories.first;
      final rl = latest.riskLevel.toString();
      displayedRisk = rl.isNotEmpty ? _formatRiskLevel(rl) : displayedRisk;
      displayedLastCheck = _formatDisplayDate(latest.createdAt);
    }

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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                color: Colors.white,

                child: Row(
                  children: [
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

                    //  PROFILE DROPDOWN
                    PopupMenuButton<String>(
                      tooltip: "Menu akun",
                      offset: const Offset(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      onSelected: (value) {
                        if (value == 'profile') {
                          context.go('/profile');
                        } else if (value == 'logout') {
                          context.go('/login');
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'profile',
                          child: Row(
                            children: [
                              Icon(Icons.person_outline, size: 20),
                              SizedBox(width: 10),
                              Text('Profil'),
                            ],
                          ),
                        ),
                        PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, size: 20, color: Colors.red),
                              SizedBox(width: 10),
                              Text(
                                'Logout',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
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
                          mainAxisSize: MainAxisSize.min,
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
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 86),
                              child: Text(
                                userName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
                  childAspectRatio: 1.85,

                  children: [
                    summaryCard(
                      Icons.favorite_border,
                      "Total Prediksi",
                      displayedTotal.toString(),
                      primaryGreen,
                    ),

                    summaryCard(
                      Icons.health_and_safety,
                      "Status Risiko Terakhir",
                      displayedRisk,
                      Colors.purple,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              //  RADAR SECTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: radarSection(primaryGreen, histories),
              ),

              const SizedBox(height: 20),

              //  PREDIKSI TERAKHIR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: predictionCard(
                  primaryGreen,
                  context,
                  displayedTotal,
                  displayedRisk,
                  displayedLastCheck,
                ),
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

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        showUnselectedLabels: true,
        elevation: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_outlined),
            activeIcon: Icon(Icons.monitor_heart),
            label: 'Cek',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Hasil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Konsul AI',
          ),
        ],
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

  Widget radarSection(Color primaryGreen, List<dynamic> histories) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 760;
        final latest = histories.isNotEmpty ? histories.first : null;
        final previous = histories.length > 1 ? histories[1] : null;
        final latestInputs = latest == null
            ? <String, dynamic>{}
            : _safeInputs(latest);

        final radarItems = _buildRadarItems(histories);
        final latestValues = radarItems.map((e) => e.latestValue).toList();
        final previousValues = radarItems.map((e) => e.previousValue).toList();
        final labels = radarItems.map((e) => e.label).toList();
        final highCount = histories
            .where((e) => _riskLevel(e).toUpperCase() == 'TINGGI')
            .length;
        final lowCount = histories
            .where((e) => _riskLevel(e).toUpperCase() == 'RENDAH')
            .length;

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
                          style: TextStyle(color: Colors.grey, fontSize: 12),
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
                    onPressed: () => context.go('/history'),
                    child: const Text("Riwayat"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (histories.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 38),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.radar_outlined,
                        color: Colors.grey.shade400,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Belum Ada Data Checkup",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Radar akan membandingkan semua prediksi setelah user melakukan checkup.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _radarChartCard(
                        labels: labels,
                        latestValues: latestValues,
                        previousValues: previousValues,
                        total: histories.length,
                        primaryGreen: primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 5,
                      child: _radarComparisonInfo(
                        primaryGreen: primaryGreen,
                        latest: latest,
                        previous: previous,
                        highCount: highCount,
                        lowCount: lowCount,
                        total: histories.length,
                      ),
                    ),
                  ],
                )
              else ...[
                _radarChartCard(
                  labels: labels,
                  latestValues: latestValues,
                  previousValues: previousValues,
                  total: histories.length,
                  primaryGreen: primaryGreen,
                ),
                const SizedBox(height: 16),
                _radarComparisonInfo(
                  primaryGreen: primaryGreen,
                  latest: latest,
                  previous: previous,
                  highCount: highCount,
                  lowCount: lowCount,
                  total: histories.length,
                ),
              ],
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  radarMetricBox(
                    "Usia Terakhir",
                    "${_valueText(latestInputs, ['age', 'usia'])} th",
                    isWide: isWide,
                  ),
                  radarMetricBox(
                    "TD Terakhir",
                    "${_valueText(latestInputs, ['systolic_bp', 'sistolik'])}/${_valueText(latestInputs, ['diastolic_bp', 'diastolik'])} mmHg",
                    isWide: isWide,
                  ),
                  radarMetricBox(
                    "Kolesterol",
                    "${_valueText(latestInputs, ['cholesterol', 'kolesterol'])} mg/dL",
                    isWide: isWide,
                  ),
                  radarMetricBox(
                    "Detak",
                    "${_valueText(latestInputs, ['heart_rate', 'detak'])} bpm",
                    isWide: isWide,
                  ),
                  radarMetricBox(
                    "Rata-rata Skor",
                    "${_averageRiskScore(histories).toStringAsFixed(1)}%",
                    isWide: isWide,
                  ),
                  radarMetricBox(
                    "Total Data",
                    "${histories.length} prediksi",
                    isWide: isWide,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _radarChartCard({
    required List<String> labels,
    required List<double> latestValues,
    required List<double> previousValues,
    required int total,
    required Color primaryGreen,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.radar_outlined, color: primaryGreen),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Membandingkan $total data prediksi",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            width: double.infinity,
            child: CustomPaint(
              painter: BodyRadarPainter(
                labels: labels,
                latestValues: latestValues,
                previousValues: previousValues,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: const [
              _LegendDot(label: 'Checkup Terbaru', color: Color(0xFF0AA06E)),
              _LegendDot(label: 'Checkup sebelumnya', color: Color(0xFF0F172A)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _radarComparisonInfo({
    required Color primaryGreen,
    required dynamic latest,
    required dynamic previous,
    required int highCount,
    required int lowCount,
    required int total,
  }) {
    final latestRisk = latest == null
        ? '-'
        : _formatRiskLevel(_riskLevel(latest));
    final latestScore = latest == null ? 0.0 : _riskScore(latest);
    final previousScore = previous == null ? null : _riskScore(previous);
    final String scoreCompare = previousScore == null
        ? 'Belum ada data pembanding sebelumnya.'
        : latestScore > previousScore
        ? 'Skor risiko naik ${(latestScore - previousScore).toStringAsFixed(1)}% dari checkup sebelumnya.'
        : latestScore < previousScore
        ? 'Skor risiko turun ${(previousScore - latestScore).toStringAsFixed(1)}% dari checkup sebelumnya.'
        : 'Skor risiko sama dengan checkup sebelumnya.';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: radarInfoBox(
                "Checkup Terbaru",
                latest == null ? '-' : _formatDisplayDate(latest.createdAt),
                "Risiko terakhir: $latestRisk (${latestScore.toStringAsFixed(1)}%)",
                primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: radarInfoBox(
                "Pembanding",
                "$total data",
                scoreCompare,
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
                "Sebaran Status Semua Prediksi",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Wrap(
                runSpacing: 10,
                spacing: 10,
                children: [
                  radarSummaryItem("Tinggi", "$highCount data"),
                  radarSummaryItem("Rendah", "$lowCount data"),
                  radarSummaryItem(
                    "Rata-rata",
                    "${_averageRiskScore(_currentHistories()).toStringAsFixed(1)}%",
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<dynamic> _currentHistories() {
    final state = context.read<PredictionBloc>().state;
    return state is PredictionLoaded ? state.items : <dynamic>[];
  }

  List<_RadarMetric> _buildRadarItems(List<dynamic> histories) {
    if (histories.isEmpty) {
      return const [
        _RadarMetric(label: 'Usia', latestValue: 0.0, previousValue: 0.0),
        _RadarMetric(label: 'Sistolik', latestValue: 0.0, previousValue: 0.0),
        _RadarMetric(label: 'Diastolik', latestValue: 0.0, previousValue: 0.0),
        _RadarMetric(label: 'Kolesterol', latestValue: 0.0, previousValue: 0.0),
        _RadarMetric(label: 'Berat', latestValue: 0.0, previousValue: 0.0),
        _RadarMetric(label: 'Tinggi', latestValue: 0.0, previousValue: 0.0),
        _RadarMetric(label: 'Gula Darah', latestValue: 0.0, previousValue: 0.0),
      ];
    }

    final latest = histories.first;
    final previous = histories.length > 1 ? histories[1] : histories.first;

    return [
      _RadarMetric(
        label: 'Usia',
        latestValue: _normalize(_metricValue(latest, ['age', 'usia']), 1, 100),
        previousValue: _normalize(
          _metricValue(previous, ['age', 'usia']),
          1,
          100,
        ),
      ),
      _RadarMetric(
        label: 'Sistolik',
        latestValue: _normalize(
          _metricValue(latest, ['systolic_bp', 'sistolik']),
          70,
          250,
        ),
        previousValue: _normalize(
          _metricValue(previous, ['systolic_bp', 'sistolik']),
          70,
          250,
        ),
      ),
      _RadarMetric(
        label: 'Diastolik',
        latestValue: _normalize(
          _metricValue(latest, ['diastolic_bp', 'diastolik']),
          40,
          150,
        ),
        previousValue: _normalize(
          _metricValue(previous, ['diastolic_bp', 'diastolik']),
          40,
          150,
        ),
      ),
      _RadarMetric(
        label: 'Kolesterol',
        latestValue: _normalize(
          _metricValue(latest, ['cholesterol', 'kolesterol']),
          80,
          400,
        ),
        previousValue: _normalize(
          _metricValue(previous, ['cholesterol', 'kolesterol']),
          80,
          400,
        ),
      ),
      _RadarMetric(
        label: 'Berat',
        latestValue: _normalize(
          _metricValue(latest, ['weight', 'berat']),
          25,
          160,
        ),
        previousValue: _normalize(
          _metricValue(previous, ['weight', 'berat']),
          25,
          160,
        ),
      ),
      _RadarMetric(
        label: 'Tinggi',
        latestValue: _normalize(
          _metricValue(latest, ['height', 'tinggi']),
          100,
          230,
        ),
        previousValue: _normalize(
          _metricValue(previous, ['height', 'tinggi']),
          100,
          230,
        ),
      ),
      _RadarMetric(
        label: 'Gula Darah',
        latestValue: _normalize(
          _metricValue(latest, ['blood_sugar', 'gula']),
          50,
          500,
        ),
        previousValue: _normalize(
          _metricValue(previous, ['blood_sugar', 'gula']),
          50,
          500,
        ),
      ),
    ];
  }

  Map<String, dynamic> _safeInputs(dynamic item) {
    try {
      return Map<String, dynamic>.from(item.inputData as Map);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _valueText(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value != null && value.toString().isNotEmpty) return value.toString();
    }
    return '-';
  }

  double _metricValue(dynamic item, List<String> keys) {
    final map = _safeInputs(item);
    for (final key in keys) {
      final value = double.tryParse(map[key]?.toString() ?? '');
      if (value != null) return value;
    }
    return 0.0;
  }

  double _averageMetric(List<dynamic> histories, List<String> keys) {
    final values = histories
        .map((e) => _metricValue(e, keys))
        .where((e) => e > 0)
        .toList();
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _bmiFromInput(Map<String, dynamic> inputs) {
    final bmi = double.tryParse(inputs['bmi']?.toString() ?? '');
    if (bmi != null && bmi > 0) return bmi;
    final weight = double.tryParse(inputs['weight']?.toString() ?? '') ?? 0;
    final height = double.tryParse(inputs['height']?.toString() ?? '') ?? 0;
    if (weight <= 0 || height <= 0) return 0.0;
    final meter = height / 100;
    return weight / (meter * meter);
  }

  double _averageBmi(List<dynamic> histories) {
    final values = histories
        .map((e) => _bmiFromInput(_safeInputs(e)))
        .where((e) => e > 0)
        .toList();
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _normalize(double value, double min, double max) {
    if (value <= 0) return 0.05;
    return ((value - min) / (max - min)).clamp(0.05, 1.0);
  }

  double _riskScore(dynamic item) {
    try {
      return (item.riskScore as num).toDouble();
    } catch (_) {
      return 0.0;
    }
  }

  String _riskLevel(dynamic item) {
    try {
      return item.riskLevel?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  double _averageRiskScore(List<dynamic> histories) {
    final values = histories.map(_riskScore).where((e) => e > 0).toList();
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  String _formatRiskLevel(String value) {
    final level = value.toUpperCase();
    if (level == 'HIGH') return 'TINGGI';
    if (level == 'LOW') return 'RENDAH';
    if (level.isEmpty) return '-';
    return level[0] + level.substring(1).toLowerCase();
  }

  String _formatDisplayDate(dynamic date) {
    try {
      final parsed = date is DateTime ? date : DateTime.parse(date.toString());
      return DateFormat('d MMMM yyyy', 'id_ID').format(parsed);
    } catch (_) {
      return date?.toString() ?? '-';
    }
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
  Widget predictionCard(
    Color primaryGreen,
    BuildContext context,
    int displayedTotal,
    String displayedRisk,
    String displayedLastCheck,
  ) {
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
            displayedRisk.toUpperCase(),
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
            displayedTotal > 0 ? "PREDIKSI TERAKHIR" : "BELUM ADA PREDIKSI",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            displayedTotal > 0
                ? "Terakhir checkup: $displayedLastCheck"
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
                    context.go('/prediction/result');
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
              InkWell(
                onTap: () {
                  fetchLastConsultation();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "REFRESH",
                    style: TextStyle(
                      color: Color(0xFF059669),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (isLoadingConsultation)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(),
            )
          else ...[
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 34,
                color: Color(0xFF059669),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              lastConsultationTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: lastConsultationTitle == "BELUM ADA KONSULTASI"
                    ? Colors.grey.shade400
                    : const Color(0xFF047857),
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              lastConsultationMessage,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                height: 1.6,
                fontSize: 13,
              ),
            ),

            if (lastConsultationDate != "-") ...[
              const SizedBox(height: 10),
              Text(
                lastConsultationDate,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ],

          const SizedBox(height: 24),

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

  // DRAWER ITEM
  static Widget drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }
}

class _RadarMetric {
  final String label;
  final double latestValue;
  final double previousValue;

  const _RadarMetric({
    required this.label,
    required this.latestValue,
    required this.previousValue,
  });
}

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

class BodyRadarPainter extends CustomPainter {
  final List<String> labels;
  final List<double> latestValues;
  final List<double> previousValues;

  BodyRadarPainter({
    required this.labels,
    required this.latestValues,
    required this.previousValues,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (labels.length < 3) return;

    final center = Offset(size.width / 2, size.height / 2 + 6);
    final radius = math.min(size.width, size.height) * 0.34;
    final axisCount = labels.length;

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final axisPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;

    final latestLinePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6;

    final latestFillPaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.18)
      ..style = PaintingStyle.fill;

    final previousLinePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Grid polygon bertingkat seperti contoh.
    for (int level = 1; level <= 4; level++) {
      final r = radius * (level / 4);
      final path = Path();
      for (int i = 0; i < axisCount; i++) {
        final point = _point(center, r, i, axisCount);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Garis sumbu dan label.
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    for (int i = 0; i < axisCount; i++) {
      final outer = _point(center, radius, i, axisCount);
      canvas.drawLine(center, outer, axisPaint);

      final labelPoint = _point(center, radius + 28, i, axisCount);
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: Color(0xFF111827),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          labelPoint.dx - textPainter.width / 2,
          labelPoint.dy - textPainter.height / 2,
        ),
      );
    }

    final previousPath = _buildPath(center, radius, previousValues, axisCount);
    _drawDashedPath(canvas, previousPath, previousLinePaint);

    final latestPath = _buildPath(center, radius, latestValues, axisCount);
    canvas.drawPath(latestPath, latestFillPaint);
    canvas.drawPath(latestPath, latestLinePaint);
  }

  Offset _point(Offset center, double radius, int index, int total) {
    // index 0 ada di atas, lalu bergerak searah jarum jam:
    // Usia, Sistolik, Diastolik, Kolesterol, Berat, Tinggi, Gula Darah.
    final angle = (-math.pi / 2) + (2 * math.pi * index / total);
    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
  }

  Path _buildPath(
    Offset center,
    double radius,
    List<double> values,
    int total,
  ) {
    final path = Path();
    for (int i = 0; i < total; i++) {
      final value = i < values.length ? values[i].clamp(0.0, 1.0) : 0.0;
      final point = _point(center, radius * value, i, total);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const double dashWidth = 7;
    const double dashSpace = 5;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final nextDistance = math.min(distance + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(distance, nextDistance), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant BodyRadarPainter oldDelegate) {
    return oldDelegate.labels != labels ||
        oldDelegate.latestValues != latestValues ||
        oldDelegate.previousValues != previousValues;
  }
}
