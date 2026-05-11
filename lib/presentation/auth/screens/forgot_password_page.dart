import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {
  final TextEditingController emailController =
      TextEditingController();

  final Color primaryGreen = const Color(0xFF0AA06E);

  void sendOTP() {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email wajib diisi"),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Kode OTP dikirim ke ${emailController.text}",
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
            // BACKGROUND SHAPE
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
                width: 260,
                height: 260,
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
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(24),
                        image: const DecorationImage(
                          image: NetworkImage(
                            "https://cdn-icons-png.flaticon.com/512/6195/6195700.png",
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Lupa Password?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      "Jangan khawatir, kami akan membantu Anda\n"
                      "kembali ke dashboard dengan cepat dan aman.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.7,
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
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: primaryGreen
                                  .withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(
                                      18),
                            ),
                            child: Icon(
                              Icons.mail_outline,
                              color: primaryGreen,
                              size: 45,
                            ),
                          ),

                          const SizedBox(height: 24),

                          const Text(
                            "Lupa Password?",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            "Masukkan email Anda dan kami akan\n"
                            "mengirimkan kode OTP untuk reset password.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 30),

                          Align(
                            alignment:
                                Alignment.centerLeft,
                            child: const Text(
                              "Email",
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText:
                                  "nama@email.com",
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                              ),
                              filled: true,
                              fillColor:
                                  const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        14),
                                borderSide:
                                    BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

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

                              onPressed: sendOTP,

                              child: const Text(
                                "Kirim Kode OTP",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/login',
                              );
                            },
                            child: Text(
                              "← KEMBALI KE LOGIN",
                              style: TextStyle(
                                color: primaryGreen,
                                fontWeight:
                                    FontWeight.bold,
                                letterSpacing: 1,
                              ),
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