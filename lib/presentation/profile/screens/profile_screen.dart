import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryGreen = Color(0xFF0AA06E);

  late TabController _tabController;

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final _nameController = TextEditingController(text: 'User');
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _birthDate;
  String _gender = 'Laki-laki';

  bool _isLoadingProfile = false;
  bool _isSavingProfile = false;
  bool _isUpdatingPassword = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfileFromDatabase();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  DateTime? _parseBirthDate(dynamic value) {
    if (value == null) return null;

    final text = value.toString();
    if (text.isEmpty) return null;

    return DateTime.tryParse(text);
  }

  Future<void> _loadProfileFromDatabase() async {
    setState(() => _isLoadingProfile = true);

    try {
      final response = await _dio.get(
        'http://127.0.0.1:8000/api/profile',
        options: await _authOptions(),
      );

      final body = _asMap(response.data);
      final data = _asMap(body['data'] ?? body);
      final user = _asMap(data['user']);
      final profile = _asMap(data['profile']);

      final merged = <String, dynamic>{}
        ..addAll(user)
        ..addAll(profile)
        ..addAll(data);

      if (!mounted) return;

      setState(() {
        _nameController.text =
            _text(merged['name'] ?? user['name'] ?? data['name']).isNotEmpty
            ? _text(merged['name'] ?? user['name'] ?? data['name'])
            : 'User';

        _emailController.text = _text(
          merged['email'] ?? user['email'] ?? data['email'],
        );

        _phoneController.text = _text(
          merged['phone'] ?? merged['no_hp'] ?? merged['phone_number'],
        );

        _addressController.text = _text(merged['address'] ?? merged['alamat']);

        final genderText = _text(merged['gender'] ?? merged['jenis_kelamin']);

        if (genderText.toLowerCase().contains('perempuan') ||
            genderText.toLowerCase() == 'female') {
          _gender = 'Perempuan';
        } else if (genderText.toLowerCase().contains('laki') ||
            genderText.toLowerCase() == 'male') {
          _gender = 'Laki-laki';
        }

        _birthDate = _parseBirthDate(
          merged['birth_date'] ??
              merged['tanggal_lahir'] ??
              merged['date_of_birth'],
        );

        _weightController.text = _text(
          merged['weight'] ?? merged['berat'] ?? merged['berat_badan'],
        );

        _heightController.text = _text(
          merged['height'] ?? merged['tinggi'] ?? merged['tinggi_badan'],
        );
      });
    } on DioException catch (e) {
      debugPrint('PROFILE LOAD ERROR STATUS: ${e.response?.statusCode}');
      debugPrint('PROFILE LOAD ERROR RESPONSE: ${e.response?.data}');
      debugPrint('PROFILE LOAD ERROR MESSAGE: ${e.message}');

      if (!mounted) return;
      _showSnack(_errorMessageFromResponse(e.response?.data), isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Gagal mengambil data profil: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() => _birthDate = picked);
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

  String _genderForApi() {
    if (_gender.toLowerCase().contains('perempuan')) {
      return 'female';
    }

    return 'male';
  }

  Future<void> _saveProfileToDatabase() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnack('Nama lengkap tidak boleh kosong', isError: true);
      return;
    }

    setState(() => _isSavingProfile = true);

    try {
      final payload = <String, dynamic>{
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'gender': _genderForApi(),
        'birth_date': _birthDate == null
            ? null
            : DateFormat('yyyy-MM-dd').format(_birthDate!),
        'age': _birthDate == null ? null : _calculateAge(_birthDate!),
        'weight': double.tryParse(_weightController.text.trim()),
        'height': double.tryParse(_heightController.text.trim()),
      };

      debugPrint('PROFILE UPDATE PAYLOAD: $payload');

      final response = await _dio.put(
        'http://127.0.0.1:8000/api/profile',
        data: payload,
        options: await _authOptions(),
      );

      debugPrint('PROFILE UPDATE STATUS: ${response.statusCode}');
      debugPrint('PROFILE UPDATE RESPONSE: ${response.data}');

      if (!mounted) return;

      _showSnack(
        response.data?['message']?.toString() ??
            'Data profil berhasil disimpan ke database',
      );

      await _loadProfileFromDatabase();
    } on DioException catch (e) {
      debugPrint('PROFILE UPDATE ERROR STATUS: ${e.response?.statusCode}');
      debugPrint('PROFILE UPDATE ERROR RESPONSE: ${e.response?.data}');
      debugPrint('PROFILE UPDATE ERROR MESSAGE: ${e.message}');

      if (!mounted) return;
      _showSnack(_errorMessageFromResponse(e.response?.data), isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Gagal menyimpan profil: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSavingProfile = false);
    }
  }

  Future<void> _updatePasswordToDatabase() async {
    final currentPassword = _currentPasswordController.text.trim();
    final password = _passwordController.text.trim();
    final confirmation = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty || password.isEmpty || confirmation.isEmpty) {
      _showSnack('Semua field password wajib diisi', isError: true);
      return;
    }

    if (password.length < 8) {
      _showSnack('Password baru minimal 8 karakter', isError: true);
      return;
    }

    if (password != confirmation) {
      _showSnack('Konfirmasi password tidak sama', isError: true);
      return;
    }

    setState(() => _isUpdatingPassword = true);

    try {
      final payload = {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': confirmation,
      };

      debugPrint('PASSWORD UPDATE PAYLOAD KEYS: ${payload.keys.toList()}');

      final response = await _dio.patch(
        'http://127.0.0.1:8000/api/profile/password',
        data: payload,
        options: await _authOptions(),
      );

      debugPrint('PASSWORD UPDATE STATUS: ${response.statusCode}');
      debugPrint('PASSWORD UPDATE RESPONSE: ${response.data}');

      if (!mounted) return;

      _currentPasswordController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();

      _showSnack(
        response.data?['message']?.toString() ?? 'Password berhasil diperbarui',
      );
    } on DioException catch (e) {
      debugPrint('PASSWORD UPDATE ERROR STATUS: ${e.response?.statusCode}');
      debugPrint('PASSWORD UPDATE ERROR RESPONSE: ${e.response?.data}');
      debugPrint('PASSWORD UPDATE ERROR MESSAGE: ${e.message}');

      if (!mounted) return;
      _showSnack(_errorMessageFromResponse(e.response?.data), isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Gagal memperbarui password: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isUpdatingPassword = false);
    }
  }

  String _errorMessageFromResponse(dynamic responseData) {
    if (responseData is Map) {
      final map = Map<String, dynamic>.from(responseData);

      final message = map['message']?.toString();

      if (map['errors'] is Map) {
        final errors = Map<String, dynamic>.from(map['errors']);
        final details = errors.entries
            .map((entry) {
              final value = entry.value;
              if (value is List) {
                return '${entry.key}: ${value.join(', ')}';
              }
              return '${entry.key}: $value';
            })
            .join('\n');

        if (details.isNotEmpty) {
          return message == null || message.isEmpty
              ? details
              : '$message\n$details';
        }
      }

      if (message != null && message.isNotEmpty) return message;
    }

    return responseData?.toString() ?? 'Terjadi kesalahan';
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : primaryGreen,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onBottomNavTap(int index) {
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
        _showSnack('Halaman Konsultasi AI belum dibuat');
        break;
    }
  }

  void _logout() async {
    await _storage.delete(key: AppConstants.tokenKey);
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Menu akun',
            offset: const Offset(0, 48),
            onSelected: (value) {
              if (value == 'profile') {
                context.go('/profile');
              } else if (value == 'logout') {
                _logout();
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
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFFE8F8F0),
                    child: Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoadingProfile
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadProfileFromDatabase,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 28 : 16,
                    vertical: 16,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: isWide ? _wideLayout() : _mobileLayout(),
                    ),
                  ),
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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

  Widget _wideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _profileHeader(isWide: true),
              const SizedBox(height: 16),
              _accountSummaryCard(),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(flex: 7, child: _profileContentCard(isWide: true)),
      ],
    );
  }

  Widget _mobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _profileHeader(isWide: false),
        const SizedBox(height: 16),
        _accountSummaryCard(),
        const SizedBox(height: 16),
        _profileContentCard(isWide: false),
      ],
    );
  }

  Widget _profileHeader({required bool isWide}) {
    const headerGradient = LinearGradient(
      colors: [Color(0xFF0B8757), Color(0xFF03865A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 24 : 20),
      decoration: BoxDecoration(
        gradient: headerGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: isWide
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatar(size: 88),
                const SizedBox(height: 18),
                _profileIdentity(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatar(size: 72),
                const SizedBox(width: 16),
                Expanded(child: _profileIdentity()),
              ],
            ),
    );
  }

  Widget _avatar({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Text(
          _nameController.text.isNotEmpty
              ? _nameController.text[0].toUpperCase()
              : 'U',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.38,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _profileIdentity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _nameController.text.isEmpty ? 'User' : _nameController.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _emailController.text.isEmpty ? '-' : _emailController.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _profileBadge('DATA TERSIMPAN DATABASE'),
            _verifiedBadge(),
          ],
        ),
      ],
    );
  }

  Widget _profileBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }

  Widget _verifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 14, color: Colors.white),
          SizedBox(width: 6),
          Text(
            'TERVERIFIKASI',
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _accountSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Akun',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          _summaryItem(Icons.person_outline, 'Nama', _nameController.text),
          const SizedBox(height: 12),
          _summaryItem(
            Icons.phone_outlined,
            'Telepon',
            _phoneController.text.isEmpty ? '-' : _phoneController.text,
          ),
          const SizedBox(height: 12),
          _summaryItem(Icons.wc_outlined, 'Gender', _gender),
          const SizedBox(height: 12),
          _summaryItem(
            Icons.calendar_today_outlined,
            'Tanggal Lahir',
            _birthDate == null
                ? '-'
                : DateFormat('dd MMMM yyyy', 'id_ID').format(_birthDate!),
          ),
          const SizedBox(height: 12),
          _summaryItem(
            Icons.monitor_weight_outlined,
            'Berat / Tinggi',
            '${_weightController.text.isEmpty ? '-' : _weightController.text} kg / ${_heightController.text.isEmpty ? '-' : _heightController.text} cm',
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F8F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primaryGreen, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '-' : value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _profileContentCard({required bool isWide}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isWide ? 24 : 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black54,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              tabs: const [
                Tab(text: 'Informasi Pribadi', icon: Icon(Icons.person)),
                Tab(text: 'Keamanan', icon: Icon(Icons.lock)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              return _tabController.index == 0
                  ? _personalInfoForm(isWide: isWide)
                  : _securityForm(isWide: isWide);
            },
          ),
        ],
      ),
    );
  }

  Widget _personalInfoForm({required bool isWide}) {
    final fields = [
      _inputField(
        controller: _nameController,
        label: 'Nama Lengkap',
        icon: Icons.person_outline,
        onChanged: (_) => setState(() {}),
      ),
      GestureDetector(
        onTap: _pickBirthDate,
        child: AbsorbPointer(
          child: _inputField(
            label: 'Tanggal Lahir',
            hint: _birthDate == null
                ? 'dd/mm/yyyy'
                : DateFormat('dd/MM/yyyy').format(_birthDate!),
            icon: Icons.calendar_today,
          ),
        ),
      ),
      _inputField(
        controller: _phoneController,
        label: 'Nomor Telepon',
        icon: Icons.phone,
        keyboardType: TextInputType.phone,
        onChanged: (_) => setState(() {}),
      ),
      _genderSelector(),
      _inputField(
        controller: _weightController,
        label: 'Berat Badan',
        hint: 'Contoh: 50',
        icon: Icons.monitor_weight,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
      ),
      _inputField(
        controller: _heightController,
        label: 'Tinggi Badan',
        hint: 'Contoh: 160',
        icon: Icons.height,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isWide) ...[
          Row(
            children: [
              Expanded(child: fields[0]),
              const SizedBox(width: 14),
              Expanded(child: fields[1]),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: fields[2]),
              const SizedBox(width: 14),
              Expanded(child: fields[3]),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: fields[4]),
              const SizedBox(width: 14),
              Expanded(child: fields[5]),
            ],
          ),
        ] else ...[
          fields[0],
          const SizedBox(height: 14),
          fields[1],
          const SizedBox(height: 14),
          fields[2],
          const SizedBox(height: 14),
          fields[3],
          const SizedBox(height: 14),
          fields[4],
          const SizedBox(height: 14),
          fields[5],
        ],
        const SizedBox(height: 14),
        _inputField(
          controller: _addressController,
          label: 'Alamat Lengkap',
          hint: 'Masukkan alamat domisili Anda',
          maxLines: isWide ? 4 : 3,
          alignLabelWithHint: true,
        ),
        const SizedBox(height: 24),
        Align(
          alignment: isWide ? Alignment.centerRight : Alignment.center,
          child: SizedBox(
            width: isWide ? null : double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSavingProfile ? null : _saveProfileToDatabase,
              icon: _isSavingProfile
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _isSavingProfile ? 'Menyimpan...' : 'Simpan Perubahan',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                disabledBackgroundColor: primaryGreen.withOpacity(0.5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _securityForm({required bool isWide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ubah Password',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),

        _inputField(
          controller: _currentPasswordController,
          label: 'Password Lama',
          hint: 'Masukkan password saat ini',
          icon: Icons.lock_clock_outlined,
          obscureText: true,
        ),

        const SizedBox(height: 14),

        if (isWide)
          Row(
            children: [
              Expanded(
                child: _inputField(
                  controller: _passwordController,
                  label: 'Password Baru',
                  hint: 'Minimal 8 karakter',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _inputField(
                  controller: _confirmPasswordController,
                  label: 'Konfirmasi Password Baru',
                  hint: 'Ulangi password baru',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
              ),
            ],
          )
        else ...[
          _inputField(
            controller: _passwordController,
            label: 'Password Baru',
            hint: 'Minimal 8 karakter',
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 14),
          _inputField(
            controller: _confirmPasswordController,
            label: 'Konfirmasi Password Baru',
            hint: 'Ulangi password baru',
            icon: Icons.lock_outline,
            obscureText: true,
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: isWide ? null : double.infinity,
          child: ElevatedButton(
            onPressed: _isUpdatingPassword ? null : _updatePasswordToDatabase,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              disabledBackgroundColor: primaryGreen.withOpacity(0.5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _isUpdatingPassword ? 'Memperbarui...' : 'Update Password',
            ),
          ),
        ),
        const SizedBox(height: 24),
        _deleteAccountBox(isWide: isWide),
      ],
    );
  }

  Widget _deleteAccountBox({required bool isWide}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFDAD5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hapus Akun',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9B1C1C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Menghapus akun akan menghapus semua data riwayat dan preferensi Anda secara permanen.',
            style: TextStyle(color: Color(0xFF9B1C1C), height: 1.5),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: isWide ? Alignment.centerRight : Alignment.center,
            child: SizedBox(
              width: isWide ? null : double.infinity,
              child: OutlinedButton(
                onPressed: () =>
                    _showSnack('Fitur hapus akun belum dibuat', isError: true),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF9B1C1C)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Hapus Akun Saya',
                  style: TextStyle(color: Color(0xFF9B1C1C)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Kelamin',
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _genderButton('Laki-laki')),
            const SizedBox(width: 10),
            Expanded(child: _genderButton('Perempuan')),
          ],
        ),
      ],
    );
  }

  Widget _genderButton(String text) {
    final bool selected = _gender == text;

    return OutlinedButton(
      onPressed: () => setState(() => _gender = text),
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? const Color(0xFFE8F8F0) : Colors.white,
        foregroundColor: selected ? primaryGreen : Colors.black87,
        side: BorderSide(color: selected ? primaryGreen : Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  Widget _inputField({
    TextEditingController? controller,
    required String label,
    String? hint,
    IconData? icon,
    bool obscureText = false,
    int maxLines = 1,
    bool alignLabelWithHint = false,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: alignLabelWithHint,
        prefixIcon: icon == null ? null : Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryGreen, width: 1.4),
        ),
      ),
    );
  }
}
