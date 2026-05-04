import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi OTP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              const Icon(
                Icons.security_rounded,
                size: 80,
                color: AppTheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Verifikasi Kode OTP',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Masukkan kode 6 digit yang dikirim ke email Anda',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        counterText: '',
                      ),
                      onChanged: (value) => _onOtpChanged(index, value),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  // TODO: Resend OTP
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('OTP dikirim ulang')),
                  );
                },
                child: const Text('Kirim Ulang OTP'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _otpCode.length == 6
                    ? () {
                        // TODO: Verify OTP
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('OTP berhasil diverifikasi!'),
                          ),
                        );
                        context.go(AppRoutes.dashboard);
                      }
                    : null,
                child: const Text('VERIFIKASI'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
