import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../auth/bloc/auth_bloc.dart';

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
  final Dio _dio = Dio();

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
  bool _isLoadingProfileData = false;

  @override
  void initState() {
    super.initState();
    beratController.addListener(_recalculateBmi);
    tinggiController.addListener(_recalculateBmi);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
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

  Future<Options> _authOptions() async {
    final token = await _storage.read(key: AppConstants.tokenKey);

    return Options(
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String _text(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  dynamic _findValue(dynamic source, List<String> keys) {
    if (source is Map) {
      final map = Map<String, dynamic>.from(source);

      for (final key in keys) {
        if (map.containsKey(key) && map[key] != null) {
          final value = map[key];
          if (value.toString().trim().isNotEmpty) return value;
        }
      }

      for (final value in map.values) {
        if (value is Map || value is List) {
          final result = _findValue(value, keys);
          if (result != null && result.toString().trim().isNotEmpty) {
            return result;
          }
        }
      }
    }

    if (source is List) {
      for (final value in source) {
        final result = _findValue(value, keys);
        if (result != null && result.toString().trim().isNotEmpty) {
          return result;
        }
      }
    }

    return null;
  }

  DateTime? _parseBirthDate(dynamic value) {
    if (value == null) return null;

    final text = value.toString();
    if (text.isEmpty) return null;

    return DateTime.tryParse(text);
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoadingProfileData = true);

    try {
      final response = await _dio.get(
        'http://127.0.0.1:8000/api/profile',
        options: await _authOptions(),
      );

      final body = _asMap(response.data);

      final birthDate = _parseBirthDate(
        _findValue(body, [
          'birth_date',
          'tanggal_lahir',
          'date_of_birth',
          'dob',
        ]),
      );

      String calculatedAge = _text(_findValue(body, ['age', 'usia', 'umur']));

      if (calculatedAge.isEmpty && birthDate != null) {
        calculatedAge = _calculateAge(birthDate).toString();
      }

      final savedGender = _text(
        _findValue(body, ['gender', 'jenis_kelamin', 'sex']),
      );

      final savedWeight = _text(
        _findValue(body, ['weight', 'berat', 'berat_badan', 'bb']),
      );

      final savedHeight = _text(
        _findValue(body, ['height', 'tinggi', 'tinggi_badan', 'tb']),
      );

      if (!mounted) return;

      setState(() {
        if (calculatedAge.isNotEmpty && calculatedAge != 'null') {
          usiaController.text = calculatedAge;
        }

        final genderLower = savedGender.toLowerCase();

        if (genderLower.contains('perempuan') ||
            genderLower == 'female' ||
            genderLower == 'wanita' ||
            genderLower == '2') {
          gender = 'Perempuan';
        } else if (genderLower.contains('laki') ||
            genderLower == 'male' ||
            genderLower == 'pria' ||
            genderLower == '1') {
          gender = 'Laki-laki';
        }

        if (savedWeight.isNotEmpty && savedWeight != 'null') {
          beratController.text = savedWeight;
        }

        if (savedHeight.isNotEmpty && savedHeight != 'null') {
          tinggiController.text = savedHeight;
        }
      });

      _recalculateBmi();

      if (!mounted) return;

      if (calculatedAge.isEmpty &&
          savedGender.isEmpty &&
          savedWeight.isEmpty &&
          savedHeight.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Profil berhasil diambil, tapi data usia/gender/berat/tinggi masih kosong di database',
            ),
          ),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;

      final responseData = e.response?.data;
      String message = 'Gagal mengambil data profil dari database';

      if (responseData is Map && responseData['message'] != null) {
        message = responseData['message'].toString();
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data profil: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingProfileData = false);
      }
    }
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
    final authState = context.watch<AuthBloc>().state;
    String userName = "User";

    if (authState is Authenticated) {
      userName = authState.user.name;
    }

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
              margin: const EdgeInsets.only(right: 16),
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
                    backgroundColor: primaryGreen.withOpacity(0.1),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : "U",
                      style: TextStyle(
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
                        color: Colors.black87,
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

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _isLoadingProfileData
                          ? null
                          : _loadProfileData,
                      icon: _isLoadingProfileData
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync),
                      label: Text(
                        _isLoadingProfileData
                            ? 'Mengambil data profil...'
                            : 'Ambil Data dari Profil',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryGreen,
                        side: BorderSide(color: primaryGreen.withOpacity(0.4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
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
