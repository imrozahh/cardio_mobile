import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/prediction_event.dart';
import '../bloc/prediction_bloc.dart';
import '../bloc/prediction_state.dart';

class PredictionResultScreen extends StatefulWidget {
  const PredictionResultScreen({super.key});

  @override
  State<PredictionResultScreen> createState() => _PredictionResultScreenState();
}

class _PredictionResultScreenState extends State<PredictionResultScreen> {
  int currentIndex = 2;

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Halaman Konsultasi AI belum dibuat")),
        );
        break;
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PredictionBloc>().add(LoadPredictionHistory());
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF0AA06E);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryGreen),
        title: const Text(
          'Hasil Prediksi',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.picture_as_pdf, color: Color(0xFF047857)),
            label: const Text(
              'PDF Hasil',
              style: TextStyle(color: Color(0xFF047857)),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
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
                    Icon(Icons.person_outline),
                    SizedBox(width: 10),
                    Text('Profil'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: BlocBuilder<PredictionBloc, PredictionState>(
          builder: (context, state) {
            debugPrint('STATE HASIL TERAKHIR: $state');

            if (state is PredictionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PredictionFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            dynamic pred;

            if (state is PredictionSuccess) {
              pred = state.prediction;
            } else if (state is PredictionLoaded && state.items.isNotEmpty) {
              pred = state.items.first;
            }

            debugPrint('PRED TERAKHIR: $pred');

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWide = constraints.maxWidth > 850;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (pred != null) ...[
                        _resultHeader(pred),
                        const SizedBox(height: 16),

                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  children: [
                                    _interpretationBox(pred),
                                    const SizedBox(height: 16),
                                    _summaryGrid(pred),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(flex: 4, child: _recommendations(pred)),
                            ],
                          )
                        else ...[
                          _interpretationBox(pred),
                          const SizedBox(height: 16),
                          _summaryGrid(pred),
                          const SizedBox(height: 16),
                          _recommendations(pred),
                        ],

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              context.go('/history');
                            },
                            icon: const Icon(Icons.history),
                            label: const Text('Lihat Riwayat Prediksi'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF047857),
                              side: const BorderSide(color: Color(0xFF047857)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 40),
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Belum ada hasil prediksi.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Silakan lakukan prediksi terlebih dahulu.',
                                style: TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.go('/prediction');
                                },
                                icon: const Icon(Icons.monitor_heart_outlined),
                                label: const Text('Cek Kesehatan'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            );
          },
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

  Widget _resultHeader(pred) {
    Color bgStart = const Color(0xFF059669);
    Color bgEnd = const Color(0xFF047857);
    String title = 'Risiko Rendah';
    String subtitle =
        'Berdasarkan data kesehatan Anda, risiko penyakit jantung tergolong rendah.';

    final riskLevel = pred.riskLevel.toString().toUpperCase();

    if (riskLevel == 'TINGGI' || riskLevel == 'HIGH') {
      bgStart = const Color(0xFFEF4444);
      bgEnd = const Color(0xFFDC2626);
      title = 'Perlu Perhatian Medis';
      subtitle = pred.recommendation.isNotEmpty
          ? pred.recommendation
          : 'Berdasarkan data kesehatan Anda, risiko penyakit jantung tergolong tinggi.';
    } else if (riskLevel == 'SEDANG' || riskLevel == 'MEDIUM') {
      bgStart = const Color(0xFFF97316);
      bgEnd = const Color(0xFFF59E0B);
      title = 'Risiko Sedang';
      subtitle = pred.recommendation.isNotEmpty
          ? pred.recommendation
          : 'Berdasarkan data kesehatan Anda, risiko penyakit jantung tergolong sedang.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgStart, bgEnd],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bgEnd.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.favorite, color: Colors.white, size: 38),
          const SizedBox(height: 12),
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _interpretationBox(pred) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFAEAEA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFEF4444)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              pred.recommendation.isNotEmpty
                  ? pred.recommendation
                  : 'Interpretasi hasil prediksi Anda akan ditampilkan di sini.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryGrid(pred) {
    final inputs = pred.inputData as Map<String, dynamic>;

    Widget tile(String title, String value) {
      return Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    final age = inputs['age'] ?? inputs['usia'] ?? '';
    final systolic = inputs['systolic_bp'] ?? inputs['sistolik'] ?? '';
    final diastolic = inputs['diastolic_bp'] ?? inputs['diastolik'] ?? '';
    final cholesterol = inputs['cholesterol'] ?? inputs['kolesterol'] ?? '';
    final heartRate = inputs['heart_rate'] ?? inputs['detak'] ?? '';
    final lifestyle = inputs['exercise'] ?? inputs['activity'] ?? '';

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        tile('Usia', '$age tahun'),
        tile('Tekanan Darah', '$systolic/$diastolic mmHg'),
        tile('Kolesterol', '$cholesterol mg/dL'),
        tile('Detak Jantung', '$heartRate bpm'),
        tile('Gaya Hidup', lifestyle.toString()),
      ],
    );
  }

  Widget _recommendations(pred) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rekomendasi untuk Anda',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (pred.recommendation.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(pred.recommendation),
          ),
        if (pred.recommendation.isNotEmpty) const SizedBox(height: 12),
        _recCard(Icons.food_bank, 'Nutrisi', 'Jaga Pola Makan Sehat'),
        const SizedBox(height: 8),
        _recCard(
          Icons.fitness_center,
          'Olahraga',
          'Tingkatkan Aktivitas Fisik',
        ),
        const SizedBox(height: 8),
        _recCard(Icons.smoke_free, 'Gaya Hidup', 'Hentikan Kebiasaan Merokok'),
      ],
    );
  }

  Widget _recCard(IconData icon, String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
