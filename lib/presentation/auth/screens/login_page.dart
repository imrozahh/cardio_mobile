import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isPasswordVisible = false;
  bool rememberMe = false;

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final Color primaryGreen = const Color(0xFF0AA06E);

  void login() {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Email dan Password wajib diisi",
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Welcome ${emailController.text}",
        ),
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
            // Background Circle
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
              bottom: -100,
              right: -100,
              child: Container(
                width: 250,
                height: 250,
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

                    const SizedBox(height: 40),

                    // CARD LOGIN
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
                            "Welcome",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Silakan login untuk melanjutkan",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 30),

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
                                  "Masukkan password",
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

                          const SizedBox(height: 14),

                          // REMEMBER
                          Row(
                            children: [
                              Checkbox(
                                value: rememberMe,
                                activeColor: primaryGreen,
                                onChanged: (value) {
                                  setState(() {
                                    rememberMe = value!;
                                  });
                                },
                              ),

                              const Text(
                                "Ingat saya",
                              ),

                              const Spacer(),

                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/forgot-password',
                                  );
                                },
                                child: Text(
                                  "Lupa Password?",
                                  style: TextStyle(
                                    color: primaryGreen,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // BUTTON LOGIN
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

                              onPressed: login,

                              child: const Text(
                                "Masuk",
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

                          const SizedBox(height: 22),

                          Center(
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Belum punya akun?",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),

                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/register',
                                    );
                                  },
                                  child: Text(
                                    "Daftar sekarang",
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

                    const SizedBox(height: 30),

                    // TEXT BAWAH
                    const Text(
                      "Jaga Kesehatan Jantung Anda",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Platform prediksi risiko berbasis AI\n"
                      "dan konsultasi kesehatan 24/7",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.6,
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