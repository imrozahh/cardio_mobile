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
  List<dynamic> dashboardPredictions = [];

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
        dashboardPredictions = predictions is List ? predictions : [];
        totalPrediksi = stats['total_checkups'] ?? dashboardPredictions.length;

        if (dashboardPredictions.isNotEmpty) {
          statusRisiko =
              dashboardPredictions.first['result_level']?.toString() ?? '-';
          lastCheckDate =
              dashboardPredictions.first['created_at']?.toString() ?? '-';
        }
      });
    } catch (e) {
      debugPrint('FETCH DASHBOARD ERROR: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    fetchDashboardData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PredictionBloc>().add(const LoadPredictionHistory());
    });
  }

  void _showConsultationSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Halaman Konsultasi AI belum dibuat")),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() => currentIndex = index);

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
        _showConsultationSnack();
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

    final predictionState = context.watch<PredictionBloc>().state;

    List<dynamic> histories = [];
    int displayedTotal = totalPrediksi;
    String displayedRisk = statusRisiko;
    String displayedLastCheck = lastCheckDate;

    if (predictionState is PredictionLoaded &&
        predictionState.items.isNotEmpty) {
      histories = predictionState.items;
      displayedTotal = predictionState.items.length;

      final latest = predictionState.items.first;
      final risk = latest.riskLevel.toString();
      displayedRisk = risk.isNotEmpty
          ? risk[0].toUpperCase() + risk.substring(1).toLowerCase()
          : displayedRisk;
      displayedLastCheck = _formatDate(latest.createdAt);
    } else if (dashboardPredictions.isNotEmpty) {
      histories = dashboardPredictions;
      displayedTotal = dashboardPredictions.length > displayedTotal
          ? dashboardPredictions.length
          : displayedTotal;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _header(userName, currentDate, primaryGreen),
              const SizedBox(height: 20),

              // SUMMARY CARD: Konsultasi AI dan Artikel Dibaca sudah dihapus
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isWide = constraints.maxWidth > 640;
                    return GridView.count(
                      crossAxisCount: isWide ? 2 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isWide ? 2.2 : 1.35,
                      children: [
                        summaryCard(
                          Icons.favorite_border,
                          "Total Prediksi",
                          displayedTotal.toString(),
                          primaryGreen,
                        ),
                        summaryCard(
                          Icons.health_and_safety,
                          "Status Risiko",
                          displayedRisk,
                          Colors.purple,
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: radarSection(
                  primaryGreen,
                  histories: histories,
                  displayedTotal: displayedTotal,
                  displayedRisk: displayedRisk,
                  displayedLastCheck: displayedLastCheck,
                ),
              ),

              const SizedBox(height: 20),

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

  Widget _header(String userName, String currentDate, Color primaryGreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
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
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                    backgroundColor: const Color(0x1A0AA06E),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : "U",
                      style: const TextStyle(
                        color: Color(0xFF0AA06E),
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
    );
  }

  Widget summaryCard(IconData icon, String title, String value, Color color) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget radarSection(
    Color primaryGreen, {
    required List<dynamic> histories,
    required int displayedTotal,
    required String displayedRisk,
    required String displayedLastCheck,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 760;
        final latest = histories.isNotEmpty ? histories.first : null;
        final latestInputs = _inputDataOf(latest);

        final latestDate = latest != null
            ? _formatAnyDate(_createdAtOf(latest))
            : displayedLastCheck;

        final highCount = histories
            .where(
              (e) =>
                  _riskLevelOf(e).toUpperCase() == 'TINGGI' ||
                  _riskLevelOf(e).toUpperCase() == 'HIGH',
            )
            .length;
        final lowCount = histories
            .where(
              (e) =>
                  _riskLevelOf(e).toUpperCase() == 'RENDAH' ||
                  _riskLevelOf(e).toUpperCase() == 'LOW',
            )
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
                          "Perbandingan Semua Checkup",
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

              if (displayedTotal > 0) ...[
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _radarGraphic(primaryGreen, histories)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _comparisonInfo(
                          primaryGreen,
                          total: displayedTotal,
                          latestDate: latestDate,
                          latestRisk: _riskLevelOf(latest).isNotEmpty
                              ? _riskLevelOf(latest)
                              : displayedRisk,
                          highCount: highCount,
                          lowCount: lowCount,
                        ),
                      ),
                    ],
                  )
                else ...[
                  _radarGraphic(primaryGreen, histories),
                  const SizedBox(height: 16),
                  _comparisonInfo(
                    primaryGreen,
                    total: displayedTotal,
                    latestDate: latestDate,
                    latestRisk: _riskLevelOf(latest).isNotEmpty
                        ? _riskLevelOf(latest)
                        : displayedRisk,
                    highCount: highCount,
                    lowCount: lowCount,
                  ),
                ],
                const SizedBox(height: 22),
                Text(
                  "Data Checkup Tersedia",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Membandingkan $displayedTotal data prediksi milik user yang sedang login. Data terbaru dibandingkan dengan rata-rata seluruh riwayat.",
                  style: const TextStyle(color: Colors.grey, height: 1.6),
                ),
                const SizedBox(height: 20),
                _metricComparisonWrap(latestInputs, histories, isWide),
              ] else ...[
                _radarGraphic(primaryGreen, histories),
                const SizedBox(height: 22),
                const Text(
                  "Belum Ada Data Checkup",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Radar chart akan muncul setelah user melakukan prediksi.",
                  style: TextStyle(color: Colors.grey, height: 1.6),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _radarGraphic(Color primaryGreen, List<dynamic> histories) {
    final int total = histories.length;
    final double level = total == 0
        ? 0.35
        : (0.35 + (total.clamp(1, 10).toDouble() * 0.045));

    return Center(
      child: Container(
        width: 210,
        height: 210,
        decoration: BoxDecoration(
          color: primaryGreen.withOpacity(0.08),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ...List.generate(4, (index) {
              final double size = 190 - (index * 34);
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryGreen.withOpacity(0.14),
                    width: 1,
                  ),
                ),
              );
            }),
            CustomPaint(
              size: const Size(150, 150),
              painter: _DashboardRadarPainter(
                color: primaryGreen,
                values: [
                  level,
                  _avgNormalized(
                    histories,
                    ['systolic_bp', 'sistolik'],
                    80,
                    180,
                  ),
                  _avgNormalized(
                    histories,
                    ['diastolic_bp', 'diastolik'],
                    50,
                    120,
                  ),
                  _avgNormalized(
                    histories,
                    ['cholesterol', 'kolesterol'],
                    100,
                    300,
                  ),
                  _avgNormalized(histories, ['blood_sugar', 'gula'], 50, 200),
                ],
              ),
            ),
            Icon(Icons.monitor_heart, color: primaryGreen, size: 34),
          ],
        ),
      ),
    );
  }

  Widget _comparisonInfo(
    Color primaryGreen, {
    required int total,
    required String latestDate,
    required String latestRisk,
    required int highCount,
    required int lowCount,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: radarInfoBox(
                "Total Checkup",
                "$total kali",
                "Semua prediksi user login dihitung.",
                primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: radarInfoBox(
                "Checkup Terbaru",
                latestDate,
                "Risiko terakhir: $latestRisk",
                const Color(0xFFF1F5F9),
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
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              radarSummaryItem("Risiko Tinggi", "$highCount data"),
              radarSummaryItem("Risiko Rendah", "$lowCount data"),
              radarSummaryItem("Data Pembanding", "$total riwayat"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricComparisonWrap(
    Map<String, dynamic> latestInputs,
    List<dynamic> histories,
    bool isWide,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        radarMetricBox(
          "Usia",
          _compareValue(latestInputs, histories, ['age', 'usia'], suffix: 'th'),
          isWide: isWide,
        ),
        radarMetricBox(
          "Sistolik",
          _compareValue(latestInputs, histories, [
            'systolic_bp',
            'sistolik',
          ], suffix: 'mmHg'),
          isWide: isWide,
        ),
        radarMetricBox(
          "Diastolik",
          _compareValue(latestInputs, histories, [
            'diastolic_bp',
            'diastolik',
          ], suffix: 'mmHg'),
          isWide: isWide,
        ),
        radarMetricBox(
          "Kolesterol",
          _compareValue(latestInputs, histories, [
            'cholesterol',
            'kolesterol',
          ], suffix: 'mg/dL'),
          isWide: isWide,
        ),
        radarMetricBox(
          "Detak",
          _compareValue(latestInputs, histories, [
            'heart_rate',
            'detak',
          ], suffix: 'bpm'),
          isWide: isWide,
        ),
        radarMetricBox(
          "Berat",
          _compareValue(latestInputs, histories, [
            'weight',
            'berat',
          ], suffix: 'kg'),
          isWide: isWide,
        ),
        radarMetricBox(
          "Tinggi",
          _compareValue(latestInputs, histories, [
            'height',
            'tinggi',
          ], suffix: 'cm'),
          isWide: isWide,
        ),
        radarMetricBox(
          "Gula Darah",
          _compareValue(latestInputs, histories, [
            'blood_sugar',
            'gula',
          ], suffix: 'mg/dL'),
          isWide: isWide,
        ),
      ],
    );
  }

  String _compareValue(
    Map<String, dynamic> latestInputs,
    List<dynamic> histories,
    List<String> keys, {
    required String suffix,
  }) {
    final latest = _firstNumber(latestInputs, keys);
    final avg = _averageInput(histories, keys);

    if (latest == null && avg == null) return '-';
    if (latest != null && avg != null) {
      return '${_numText(latest)} $suffix\nRata-rata: ${_numText(avg)}';
    }
    if (latest != null) return '${_numText(latest)} $suffix';
    return 'Rata-rata: ${_numText(avg!)} $suffix';
  }

  Map<String, dynamic> _inputDataOf(dynamic item) {
    if (item == null) return <String, dynamic>{};

    try {
      final input = item.inputData;
      if (input is Map) return Map<String, dynamic>.from(input);
    } catch (_) {}

    if (item is Map) {
      final input = item['input_data'];
      if (input is Map) return Map<String, dynamic>.from(input);
    }

    return <String, dynamic>{};
  }

  String _riskLevelOf(dynamic item) {
    if (item == null) return '';

    try {
      return item.riskLevel?.toString() ?? '';
    } catch (_) {}

    if (item is Map) {
      return item['risk_level']?.toString() ??
          item['result_level']?.toString() ??
          '';
    }

    return '';
  }

  dynamic _createdAtOf(dynamic item) {
    if (item == null) return null;

    try {
      return item.createdAt;
    } catch (_) {}

    if (item is Map) return item['created_at'];

    return null;
  }

  String _formatAnyDate(dynamic value) {
    if (value == null) return '-';
    if (value is DateTime) return _formatDate(value);

    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();
    return _formatDate(parsed);
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'id_ID').format(date.toLocal());
  }

  double? _firstNumber(Map<String, dynamic> input, List<String> keys) {
    for (final key in keys) {
      final value = input[key];
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  double? _averageInput(List<dynamic> histories, List<String> keys) {
    final values = <double>[];

    for (final item in histories) {
      final value = _firstNumber(_inputDataOf(item), keys);
      if (value != null) values.add(value);
    }

    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _avgNormalized(
    List<dynamic> histories,
    List<String> keys,
    double min,
    double max,
  ) {
    final avg = _averageInput(histories, keys);
    if (avg == null) return 0.35;
    return ((avg - min) / (max - min)).clamp(0.15, 0.95).toDouble();
  }

  String _numText(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
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
      width: isWide ? 170 : double.infinity,
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

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
                  onPressed: () => context.go('/history'),
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
                  onPressed: () => context.go('/prediction/result'),
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
              onPressed: _showConsultationSnack,
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
}

class _DashboardRadarPainter extends CustomPainter {
  final List<double> values;
  final Color color;

  _DashboardRadarPainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sides = values.length;

    final axisPaint = Paint()
      ..color = color.withOpacity(0.16)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.18)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    for (int ring = 1; ring <= 4; ring++) {
      final ringPath = Path();
      final ringRadius = radius * ring / 4;
      for (int i = 0; i < sides; i++) {
        final angle = -1.5708 + (2 * 3.14159 * i / sides);
        final point = Offset(
          center.dx + ringRadius * math.cos(angle),
          center.dy + ringRadius * math.sin(angle),
        );
        if (i == 0) {
          ringPath.moveTo(point.dx, point.dy);
        } else {
          ringPath.lineTo(point.dx, point.dy);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, axisPaint);
    }

    final dataPath = Path();
    for (int i = 0; i < sides; i++) {
      final angle = -1.5708 + (2 * 3.14159 * i / sides);
      final pointRadius = radius * values[i].clamp(0.0, 1.0);
      final point = Offset(
        center.dx + pointRadius * math.cos(angle),
        center.dy + pointRadius * math.sin(angle),
      );
      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();

    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _DashboardRadarPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}
