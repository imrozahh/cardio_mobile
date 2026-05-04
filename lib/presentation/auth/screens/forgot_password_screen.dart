import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../../../../injection_container.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email reset password telah dikirim.'),
              ),
            );
            context.go(AppRoutes.otpVerification, extra: state.email);
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
            appBar: AppBar(title: const Text('Lupa Password')),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 48),
                      const Icon(
                        Icons.lock_outline,
                        size: 80,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Masukkan Email Anda',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kami akan mengirimkan kode OTP ke email Anda untuk mereset password.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 48),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                    ForgotPasswordRequested(
                                      email: _emailController.text.trim(),
                                    ),
                                  );
                                }
                              },
                        child: state is AuthLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('KIRIM KODE OTP'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        child: const Text('Kembali ke Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
