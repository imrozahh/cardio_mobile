import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../../../../injection_container.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

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
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpVerified) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP berhasil diverifikasi!')),
            );
            context.go(AppRoutes.login);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
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
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masukkan kode 6 digit yang dikirim ke email ${widget.email}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('OTP dikirim ulang')),
                        );
                      },
                      child: const Text('Kirim Ulang OTP'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: state is AuthLoading
                          ? null
                          : _otpCode.length == 6
                          ? () {
                              context.read<AuthBloc>().add(
                                OtpVerificationRequested(
                                  email: widget.email,
                                  otp: _otpCode,
                                ),
                              );
                            }
                          : null,
                      child: state is AuthLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('VERIFIKASI'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
