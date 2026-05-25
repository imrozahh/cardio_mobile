import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../prediction/bloc/prediction_bloc.dart';
import '../../prediction/bloc/prediction_event.dart';
import '../../prediction/bloc/prediction_state.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const Color primaryGreen = Color(0xFF0AA06E);
  final TextEditingController _searchController = TextEditingController();

  int currentIndex = 3;
  String selectedStatus = 'Semua Status';
  String selectedMonth = 'Semua Bulan';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PredictionBloc>().add(const LoadPredictionHistory());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Halaman Konsultasi AI belum dibuat')),
        );
        break;
    }
  }

  void _handleProfileMenu(String value) {
    switch (value) {
      case 'profile':
        context.go('/profile');
        break;
      case 'logout':
        context.go('/login');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.favorite_border,
                color: primaryGreen,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Halo, User 1',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'SENIN, 25 MEI 2026',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 8,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleProfileMenu,
            offset: const Offset(0, 42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 18),
                    SizedBox(width: 10),
                    Text('Profil'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: primaryGreen.withOpacity(0.16),
                    child: const Text(
                      'U',
                      style: TextStyle(
                        color: primaryGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'User 1',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'PATIENT ID: #HR-2026',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 8),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF64748B),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<PredictionBloc, PredictionState>(
          builder: (context, state) {
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

            final items = state is PredictionLoaded ? state.items : [];

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _pageHeader(),
                      const SizedBox(height: 22),
                      _trendCard(items),
                      const SizedBox(height: 22),
                      _filterSection(),
                      const SizedBox(height: 22),
                      _historySection(items),
                      const SizedBox(height: 30),
                      _bottomCta(),
                    ],
                  ),
                ),
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

  Widget _pageHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 620;

        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Dashboard'),
                  TextSpan(text: '  ›  '),
                  TextSpan(
                    text: 'Riwayat',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
            ),
            SizedBox(height: 10),
            Text(
              'Riwayat Prediksi',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Daftar pemeriksaan terdaftar',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ],
        );

        final exportButton = OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download, size: 16),
          label: const Text('Export Riwayat (PDF)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryGreen,
            side: BorderSide(color: Colors.grey.shade300),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: title),
              exportButton,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title,
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: exportButton),
          ],
        );
      },
    );
  }

  Widget _trendCard(List<dynamic> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.history, color: primaryGreen, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Trend Status Kesehatan',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          SizedBox(
            height: 190,
            width: double.infinity,
            child: CustomPaint(
              painter: _TrendPainter(
                values: items
                    .map<double>((e) => _trendValue(e))
                    .toList()
                    .reversed
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 760;

        final search = TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Cari riwayat...',
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: _inputBorder(),
            enabledBorder: _inputBorder(),
            focusedBorder: _inputBorder(color: primaryGreen),
          ),
        );

        final status = _dropdown(
          value: selectedStatus,
          icon: Icons.filter_list,
          items: const ['Semua Status', 'RENDAH', 'TINGGI'],
          onChanged: (value) {
            setState(() => selectedStatus = value ?? 'Semua Status');
          },
        );

        final month = _dropdown(
          value: selectedMonth,
          icon: Icons.calendar_month_outlined,
          items: const [
            'Semua Bulan',
            'Januari',
            'Februari',
            'Maret',
            'April',
            'Mei',
          ],
          onChanged: (value) {
            setState(() => selectedMonth = value ?? 'Semua Bulan');
          },
        );

        if (isWide) {
          return Row(
            children: [
              Expanded(flex: 2, child: search),
              const SizedBox(width: 14),
              Expanded(child: status),
              const SizedBox(width: 14),
              Expanded(child: month),
            ],
          );
        }

        return Column(
          children: [
            search,
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: status),
                const SizedBox(width: 12),
                Expanded(child: month),
              ],
            ),
          ],
        );
      },
    );
  }

  OutlineInputBorder _inputBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color ?? Colors.grey.shade200),
    );
  }

  Widget _dropdown({
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 18),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
        border: _inputBorder(),
        enabledBorder: _inputBorder(),
        focusedBorder: _inputBorder(color: primaryGreen),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
    );
  }

  Widget _historySection(List<dynamic> items) {
    final filtered = _filteredItems(items);

    if (filtered.isEmpty) {
      return _emptyHistoryCard();
    }

    final grouped = <String, List<dynamic>>{};
    for (final item in filtered) {
      final key = _monthLabel(_createdAt(item));
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                entry.key.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...entry.value.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _historyCard(item),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  List<dynamic> _filteredItems(List<dynamic> items) {
    final keyword = _searchController.text.trim().toLowerCase();

    return items.where((item) {
      final risk = _riskLevel(item).toUpperCase();
      final date = _createdAt(item);
      final input = _inputData(item);

      final matchesStatus =
          selectedStatus == 'Semua Status' || risk == selectedStatus;
      final matchesMonth =
          selectedMonth == 'Semua Bulan' || _monthName(date) == selectedMonth;
      final matchesKeyword =
          keyword.isEmpty ||
          risk.toLowerCase().contains(keyword) ||
          '${input['systolic_bp'] ?? input['sistolik'] ?? ''}/${input['diastolic_bp'] ?? input['diastolik'] ?? ''}'
              .toLowerCase()
              .contains(keyword) ||
          '${input['cholesterol'] ?? input['kolesterol'] ?? ''}'.contains(
            keyword,
          );

      return matchesStatus && matchesMonth && matchesKeyword;
    }).toList();
  }

  Widget _historyCard(dynamic item) {
    final createdAt = _createdAt(item);
    final risk = _riskLevel(item);
    final score = _riskScore(item);
    final input = _inputData(item);

    final systolic = input['systolic_bp'] ?? input['sistolik'] ?? '-';
    final diastolic = input['diastolic_bp'] ?? input['diastolik'] ?? '-';
    final cholesterol = input['cholesterol'] ?? input['kolesterol'] ?? '-';
    final heartRate = input['heart_rate'] ?? input['detak'] ?? '0';

    final bool high =
        risk.toUpperCase() == 'TINGGI' || risk.toUpperCase() == 'HIGH';
    final bool medium =
        risk.toUpperCase() == 'SEDANG' || risk.toUpperCase() == 'MEDIUM';
    final statusColor = high
        ? const Color(0xFFEF4444)
        : medium
        ? const Color(0xFFF59E0B)
        : primaryGreen;

    final statusText = high
        ? 'Perlu Perhatian Medis'
        : medium
        ? 'Risiko Sedang'
        : 'Kondisi Terpantau Baik';

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => context.go('/prediction/result'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: statusColor.withOpacity(0.35),
            width: risk.toUpperCase() == 'RENDAH' ? 1.2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 720;

            final dateBox = Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('dd').format(createdAt),
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('MMM', 'id_ID').format(createdAt).toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );

            final status = Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$statusText (${score.toStringAsFixed(1)}%)',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );

            final metrics = Row(
              children: [
                Expanded(child: _metric('TD', '$systolic/$diastolic')),
                Expanded(child: _metric('KLS', '$cholesterol')),
                Expanded(child: _metric('DETAK', '$heartRate')),
              ],
            );

            if (isWide) {
              return Row(
                children: [
                  dateBox,
                  const SizedBox(width: 28),
                  Expanded(flex: 2, child: status),
                  Container(width: 1, height: 42, color: Colors.grey.shade200),
                  const SizedBox(width: 22),
                  Expanded(flex: 4, child: metrics),
                  const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    dateBox,
                    const SizedBox(width: 14),
                    Expanded(child: status),
                    const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                  ],
                ),
                const SizedBox(height: 18),
                metrics,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _emptyHistoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history, size: 36, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum ada riwayat ditemukan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai cek kesehatan pertama Anda hari ini!',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _bottomCta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingin melakukan pemeriksaan lagi?',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            width: 260,
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.favorite_border, size: 20),
              label: const Text(
                'Mulai Cek Kesehatan Baru',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: primaryGreen.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => context.go('/prediction'),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _inputData(dynamic item) {
    try {
      return Map<String, dynamic>.from(item.inputData as Map);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _riskLevel(dynamic item) {
    try {
      return item.riskLevel?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  double _riskScore(dynamic item) {
    try {
      return double.tryParse(item.riskScore.toString()) ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  double _trendValue(dynamic item) {
    final risk = _riskLevel(item).toUpperCase();

    if (risk == 'TINGGI' || risk == 'HIGH') {
      return 78;
    }

    if (risk == 'SEDANG' || risk == 'MEDIUM') {
      return 55;
    }

    return 26;
  }

  DateTime _createdAt(dynamic item) {
    try {
      return item.createdAt as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }

  String _monthLabel(DateTime date) {
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  String _monthName(DateTime date) {
    return DateFormat('MMMM', 'id_ID').format(date);
  }
}

class _TrendPainter extends CustomPainter {
  final List<double> values;

  _TrendPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withOpacity(0.45)
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = values.isNotEmpty
        ? values
        : [26, 26, 26, 78, 26, 26, 26, 26, 78];
    final normalized = points.map((e) => e.clamp(0, 100).toDouble()).toList();
    final gap = normalized.length == 1
        ? size.width
        : size.width / (normalized.length - 1);

    final path = Path();
    for (int i = 0; i < normalized.length; i++) {
      final x = i * gap;
      final y = size.height - (normalized[i] / 100 * size.height * 0.78) - 18;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final previousX = (i - 1) * gap;
        final previousY =
            size.height - (normalized[i - 1] / 100 * size.height * 0.78) - 18;
        final controlX = (previousX + x) / 2;
        path.cubicTo(controlX, previousY, controlX, y, x, y);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x3300A86B), Color(0x0000A86B)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
