import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryGreen = Color(0xFF0AA06E);

  late TabController _tabController;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final _nameController = TextEditingController(text: 'User 1');
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _birthDate;
  String _gender = 'Laki-laki';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

  Future<void> _loadProfile() async {
    final name = await _storage.read(key: 'profile_name');
    final phone = await _storage.read(key: 'profile_phone');
    final address = await _storage.read(key: 'profile_address');
    final gender = await _storage.read(key: 'profile_gender');
    final birthDateText = await _storage.read(key: 'profile_birth_date');
    final weight = await _storage.read(key: 'profile_weight');
    final height = await _storage.read(key: 'profile_height');

    if (!mounted) return;

    setState(() {
      if (name != null && name.isNotEmpty) {
        _nameController.text = name;
      }
      if (phone != null) {
        _phoneController.text = phone;
      }
      if (address != null) {
        _addressController.text = address;
      }
      if (gender != null && gender.isNotEmpty) {
        _gender = gender;
      }
      if (birthDateText != null && birthDateText.isNotEmpty) {
        _birthDate = DateTime.tryParse(birthDateText);
      }
      if (weight != null) {
        _weightController.text = weight;
      }
      if (height != null) {
        _heightController.text = height;
      }
    });
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lengkap tidak boleh kosong')),
      );
      return;
    }

    await _storage.write(
      key: 'profile_name',
      value: _nameController.text.trim(),
    );
    await _storage.write(
      key: 'profile_phone',
      value: _phoneController.text.trim(),
    );
    await _storage.write(
      key: 'profile_address',
      value: _addressController.text.trim(),
    );
    await _storage.write(key: 'profile_gender', value: _gender);
    await _storage.write(
      key: 'profile_weight',
      value: _weightController.text.trim(),
    );
    await _storage.write(
      key: 'profile_height',
      value: _heightController.text.trim(),
    );

    if (_birthDate != null) {
      await _storage.write(
        key: 'profile_birth_date',
        value: _birthDate!.toIso8601String(),
      );
      await _storage.write(
        key: 'profile_age',
        value: _calculateAge(_birthDate!).toString(),
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data profil berhasil disimpan')),
    );

    setState(() {});
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Halaman Konsultasi AI belum dibuat')),
        );
        break;
    }
  }

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFFE8F8F0),
                    child: Text(
                      'U',
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
    return Stack(
      children: [
        Container(
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
        ),
        Positioned(
          right: -4,
          bottom: -4,
          child: InkWell(
            onTap: () => _showComingSoon('Fitur ubah foto belum dibuat'),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(7),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Color(0xFF047857),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileIdentity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _nameController.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'user1@gmail.com',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [_profileBadge('MEMBER SEJAK APR 2026'), _verifiedBadge()],
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
                value,
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
      ),
      _inputField(
        controller: _heightController,
        label: 'Tinggi Badan',
        hint: 'Contoh: 160',
        icon: Icons.height,
        keyboardType: TextInputType.number,
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
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: const Text('Simpan Perubahan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
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
            onPressed: () => _showComingSoon('Password berhasil diperbarui'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Update Password'),
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
                    _showComingSoon('Fitur hapus akun belum dibuat'),
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
