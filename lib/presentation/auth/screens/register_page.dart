import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool agreeTerms = false;

  final Color primaryGreen = const Color(0xFF0AA06E);

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  void register() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua field wajib diisi"),
        ),
      );
      return;
    }

    if (passwordController.text !=
        confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password tidak sama"),
        ),
      );
      return;
    }

    if (!agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Setujui syarat dan ketentuan",
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Register berhasil"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen,

      body: SafeArea(
        child: Stack(
          children: [
            // BACKGROUND
            Positioned(
              top: -80,
              left: -80,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              bottom: -120,
              right: -120,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),

                child: Column(
                  children: [
                    // LOGO
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.favorite_border,
                            color: primaryGreen,
                            size: 24,
                          ),
                        ),

                        const SizedBox(width: 10),

                        const Text(
                          "HeartCare",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    // IMAGE
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(24),
                        image: const DecorationImage(
                          image: NetworkImage(
                            "https://images.unsplash.com/photo-1586773860418-d37222d8fce3",
                          ),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.15),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Mulai Jaga Kesehatan\nAnda",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      "Daftar gratis dan dapatkan prediksi risiko\n"
                      "jantung dengan teknologi AI terkini.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 35),

                    // CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Daftar HeartCare",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            "Buat akun baru untuk mulai menggunakan aplikasi.",
                            style: TextStyle(
                              color: Colors.grey,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // NAMA
                          const Text(
                            "Nama Lengkap",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 10),

                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: "John Doe",
                              prefixIcon: const Icon(
                                Icons.person_outline,
                              ),
                              filled: true,
                              fillColor:
                                  const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // EMAIL
                          const Text(
                            "Email",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 10),

                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: "nama@email.com",
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                              ),
                              filled: true,
                              fillColor:
                                  const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // PASSWORD
                          const Text(
                            "Password",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 10),

                          TextField(
                            controller: passwordController,
                            obscureText:
                                !isPasswordVisible,
                            decoration: InputDecoration(
                              hintText:
                                  "Minimal 8 karakter",
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible =
                                        !isPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                              filled: true,
                              fillColor:
                                  const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // CONFIRM PASSWORD
                          const Text(
                            "Konfirmasi Password",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 10),

                          TextField(
                            controller:
                                confirmPasswordController,
                            obscureText:
                                !isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              hintText:
                                  "Ulangi password Anda",
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isConfirmPasswordVisible =
                                        !isConfirmPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                              filled: true,
                              fillColor:
                                  const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: agreeTerms,
                                activeColor: primaryGreen,
                                onChanged: (value) {
                                  setState(() {
                                    agreeTerms = value!;
                                  });
                                },
                              ),

                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    top: 12,
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      style:
                                          const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text:
                                              "Saya setuju dengan ",
                                        ),
                                        TextSpan(
                                          text:
                                              "Syarat & Ketentuan",
                                          style: TextStyle(
                                            color:
                                                primaryGreen,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: " dan ",
                                        ),
                                        TextSpan(
                                          text:
                                              "Kebijakan Privasi",
                                          style: TextStyle(
                                            color:
                                                primaryGreen,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    primaryGreen,
                                foregroundColor:
                                    Colors.white,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          16),
                                ),
                              ),

                              onPressed: register,

                              child: const Text(
                                "Daftar Sekarang",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          Row(
                            children: [
                              const Expanded(
                                  child: Divider()),

                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  "ATAU",
                                  style: TextStyle(
                                    color:
                                        Colors.grey.shade600,
                                  ),
                                ),
                              ),

                              const Expanded(
                                  child: Divider()),
                            ],
                          ),

                          const SizedBox(height: 18),

                          Center(
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Sudah punya akun?",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),

                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/login',
                                    );
                                  },
                                  child: Text(
                                    "Masuk di sini",
                                    style: TextStyle(
                                      color: primaryGreen,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}