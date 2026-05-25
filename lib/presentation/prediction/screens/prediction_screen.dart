import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../bloc/prediction_bloc.dart';
import '../bloc/prediction_event.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final Color primaryGreen = const Color(0xFF0AA06E);

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final TextEditingController usiaController = TextEditingController();
  final TextEditingController sistolikController = TextEditingController();
  final TextEditingController diastolikController = TextEditingController();
  final TextEditingController kolesterolController = TextEditingController();
  final TextEditingController gulaController = TextEditingController();
  final TextEditingController detakController = TextEditingController();
  final TextEditingController beratController = TextEditingController();
  final TextEditingController tinggiController = TextEditingController();

  String gender = "";
  double bmi = 0.0;
  int currentIndex = 1;
  String smoking = '';
  String activity = '';

  @override
  void initState() {
    super.initState();
    beratController.addListener(_recalculateBmi);
    tinggiController.addListener(_recalculateBmi);
    _loadProfileData();
  }

  @override
  void dispose() {
    usiaController.dispose();
    sistolikController.dispose();
    diastolikController.dispose();
    kolesterolController.dispose();
    gulaController.dispose();
    detakController.dispose();
    beratController.dispose();
    tinggiController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final savedAge = await _storage.read(key: 'profile_age');
    final savedGender = await _storage.read(key: 'profile_gender');
    final savedBirthDate = await _storage.read(key: 'profile_birth_date');
    final savedWeight = await _storage.read(key: 'profile_weight');
    final savedHeight = await _storage.read(key: 'profile_height');

    String? calculatedAge = savedAge;

    if ((calculatedAge == null || calculatedAge.isEmpty) &&
        savedBirthDate != null &&
        savedBirthDate.isNotEmpty) {
      final birthDate = DateTime.tryParse(savedBirthDate);
      if (birthDate != null) {
        calculatedAge = _calculateAge(birthDate).toString();
      }
    }

    if (!mounted) return;

    setState(() {
      if (calculatedAge != null && calculatedAge.isNotEmpty) {
        usiaController.text = calculatedAge;
      }
      if (savedGender != null && savedGender.isNotEmpty) {
        gender = savedGender;
      }
      if (savedWeight != null && savedWeight.isNotEmpty) {
        beratController.text = savedWeight;
      }
      if (savedHeight != null && savedHeight.isNotEmpty) {
        tinggiController.text = savedHeight;
      }
    });

    _recalculateBmi();
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    final hasBirthdayPassed =
        now.month > birthDate.month ||
        (now.month == birthDate.month && now.day >= birthDate.day);

    if (!hasBirthdayPassed) {
      age--;
    }

    return age;
  }

  void _onBottomNavTap(int index) {
    if (index == currentIndex) return;

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
          const SnackBar(content: Text('Halaman Konsultasi AI belum dibuat')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryGreen),
        title: const Text(
          'Cek Kesehatan',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        actions: [
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
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth > 850;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  const Text(
                    'Cek Kesehatan Jantung',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Lengkapi data kesehatan Anda untuk mendapatkan prediksi risiko penyakit jantung oleh AI.',
                    style: TextStyle(color: Colors.black54, height: 1.6),
                  ),

                  const SizedBox(height: 20),

                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: dataDemografisCard()),
                        const SizedBox(width: 16),
                        Expanded(child: dataVitalCard()),
                      ],
                    )
                  else
                    Column(
                      children: [
                        dataDemografisCard(),
                        const SizedBox(height: 16),
                        dataVitalCard(),
                      ],
                    ),

                  const SizedBox(height: 18),

                  sectionCard(
                    icon: Icons.self_improvement,
                    color: const Color(0xFFFFC857),
                    title: 'Gaya Hidup',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kebiasaan Merokok *',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _selectableLifestyle('Tidak', true),
                            _selectableLifestyle('Kadang', true),
                            _selectableLifestyle('Sering', true),
                            _selectableLifestyle('Sudah Berhenti', true),
                          ],
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'Aktivitas Fisik / Olahraga *',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _selectableLifestyle('Jarang', false),
                            _selectableLifestyle('1-2x Seminggu', false),
                            _selectableLifestyle('3-4x Seminggu', false),
                            _selectableLifestyle('Setiap Hari', false),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: isWide
                        ? Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Data kesehatan Anda akan tetap rahasia dan hanya digunakan untuk keperluan simulasi prediksi AI medis.',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                              const SizedBox(width: 12),
                              submitButton(),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Data kesehatan Anda akan tetap rahasia dan hanya digunakan untuk keperluan simulasi prediksi AI medis.',
                                style: TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: submitButton(),
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 24),
                ],
              );
            },
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

  Widget dataDemografisCard() {
    return sectionCard(
      icon: Icons.person_outline,
      color: Colors.green,
      title: 'Data Demografis',
      child: Column(
        children: [
          buildInput('Usia *', '21', usiaController, Icons.calendar_today),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: genderButton('Laki-laki')),
              const SizedBox(width: 10),
              Expanded(child: genderButton('Perempuan')),
            ],
          ),
        ],
      ),
    );
  }

  Widget dataVitalCard() {
    return sectionCard(
      icon: Icons.monitor_heart_outlined,
      color: Colors.purple,
      title: 'Data Vital',
      child: Column(
        children: [
          buildInput(
            'Tekanan Darah Sistolik *',
            '120',
            sistolikController,
            Icons.favorite_border,
          ),

          const SizedBox(height: 12),

          buildInput(
            'Tekanan Darah Diastolik *',
            '80',
            diastolikController,
            Icons.favorite_border,
          ),

          const SizedBox(height: 12),

          buildInput(
            'Kolesterol Total *',
            '150',
            kolesterolController,
            Icons.water_drop_outlined,
          ),

          const SizedBox(height: 12),

          buildInput(
            'Gula Darah Puasa (Opsional)',
            '99',
            gulaController,
            Icons.water_drop_outlined,
          ),

          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth > 600;

              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      child: buildInput(
                        'Detak Jantung *',
                        '80',
                        detakController,
                        Icons.monitor_heart,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: buildInput(
                        'Berat Badan *',
                        '40',
                        beratController,
                        Icons.monitor_weight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: buildInput(
                        'Tinggi Badan *',
                        '150',
                        tinggiController,
                        Icons.height,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  buildInput(
                    'Detak Jantung *',
                    '80',
                    detakController,
                    Icons.monitor_heart,
                  ),
                  const SizedBox(height: 12),
                  buildInput(
                    'Berat Badan *',
                    '40',
                    beratController,
                    Icons.monitor_weight,
                  ),
                  const SizedBox(height: 12),
                  buildInput(
                    'Tinggi Badan *',
                    '150',
                    tinggiController,
                    Icons.height,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                const Icon(Icons.monitor_heart, color: Colors.black54),
                const Text(
                  'Body Mass Index (BMI) Anda:',
                  style: TextStyle(color: Colors.black87),
                ),
                Text(
                  bmi.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  _bmiLabel(bmi),
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget submitButton() {
    return ElevatedButton(
      onPressed: _submitPrediction,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Mulai Analisis AI'),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward),
        ],
      ),
    );
  }

  Widget sectionCard({
    required IconData icon,
    required Color color,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
          keyboardType: TextInputType.number,
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

  Widget genderButton(String text) {
    final bool isSelected = gender == text;

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

  Widget _selectableLifestyle(String label, bool isSmoking) {
    final bool selected = isSmoking ? smoking == label : activity == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSmoking) {
            smoking = label;
          } else {
            activity = label;
          }
        });
      },
      child: Container(
        constraints: const BoxConstraints(minWidth: 130),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF0AA06E) : Colors.grey.shade300,
          ),
          color: selected ? const Color(0xFFE8F8F0) : Colors.white,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFF0AA06E) : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _recalculateBmi() {
    final double w = double.tryParse(beratController.text) ?? 0;
    final double h = double.tryParse(tinggiController.text) ?? 0;

    if (w > 0 && h > 0) {
      final double meters = h / 100;
      setState(() {
        bmi = w / (meters * meters);
      });
    } else {
      setState(() {
        bmi = 0;
      });
    }
  }

  String _bmiLabel(double value) {
    if (value == 0) return '';
    if (value < 18.5) return '— Kekurangan Berat';
    if (value < 25) return '— Normal';
    if (value < 30) return '— Kelebihan Berat';
    return '— Obesitas';
  }

  void _submitPrediction() {
    if (usiaController.text.isEmpty ||
        gender.isEmpty ||
        sistolikController.text.isEmpty ||
        diastolikController.text.isEmpty ||
        kolesterolController.text.isEmpty ||
        gulaController.text.isEmpty ||
        beratController.text.isEmpty ||
        tinggiController.text.isEmpty ||
        smoking.isEmpty ||
        activity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lengkapi semua data yang dibutuhkan model terlebih dahulu',
          ),
        ),
      );
      return;
    }

    final data = <String, dynamic>{
      'age': int.tryParse(usiaController.text) ?? 0,
      'gender': gender,
      'systolic_bp': int.tryParse(sistolikController.text) ?? 0,
      'diastolic_bp': int.tryParse(diastolikController.text) ?? 0,
      'cholesterol': int.tryParse(kolesterolController.text) ?? 0,
      'blood_sugar': int.tryParse(gulaController.text) ?? 90,
      'weight': double.tryParse(beratController.text) ?? 0,
      'height': double.tryParse(tinggiController.text) ?? 0,
      'smoking': smoking,
      'exercise': activity,
      'alcohol': 'tidak',
      'heart_rate': detakController.text.isEmpty
          ? null
          : int.tryParse(detakController.text),
      'bmi': double.tryParse(bmi.toStringAsFixed(1)) ?? 0,
    };

    final bloc = context.read<PredictionBloc>();
    bloc.add(Predict(data));

    context.go('/prediction/result');
  }

  static Widget drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }
}
