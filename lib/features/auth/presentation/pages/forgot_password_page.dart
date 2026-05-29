import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:volync/core/theme/app_pallete.dart';
import 'package:volync/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:volync/features/auth/presentation/widgets/auth_button.dart';
import 'package:volync/features/auth/presentation/widgets/auth_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  static final _emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthResetPassword(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      ),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.teal[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: Colors.teal[700], size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Password Berhasil Direset!',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan login menggunakan password baru Anda.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                // Pop dialog then pop this page back to login
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Oke, Login Sekarang'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F6F3),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppPallete.backButtonColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (_, state) =>
            state is AuthResetPasswordSuccess ||
            state is AuthResetPasswordFailure,
        listener: (context, state) {
          if (state is AuthResetPasswordSuccess) {
            _showSuccess();
          } else if (state is AuthResetPasswordFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red[700],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        buildWhen: (_, state) =>
            state is AuthResetPasswordLoading ||
            state is AuthResetPasswordSuccess ||
            state is AuthResetPasswordFailure ||
            state is AuthInitial,
        builder: (context, state) {
          final isLoading = state is AuthResetPasswordLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                  // Icon / illustration
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.teal[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: 48,
                      color: Colors.teal[800],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Lupa Password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppPallete.defaultTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masukkan username, email, dan password baru Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Username field
                  AuthField(
                    controller: _usernameController,
                    hintText: 'Username',
                    icon: const Icon(Icons.person_outline),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  AuthField(
                    controller: _emailController,
                    hintText: 'Email',
                    icon: const Icon(Icons.mark_email_unread),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!_emailRegex.hasMatch(value.trim())) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // New password field
                  AuthField(
                    controller: _newPasswordController,
                    hintText: 'Password Baru',
                    icon: const Icon(Icons.lock_outline),
                    obscureIcon: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password baru tidak boleh kosong';
                      }
                      if (value.trim().length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm password field
                  AuthField(
                    controller: _confirmPasswordController,
                    hintText: 'Konfirmasi Password Baru',
                    icon: const Icon(Icons.lock_outline),
                    obscureIcon: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Konfirmasi password tidak boleh kosong';
                      }
                      if (value.trim() != _newPasswordController.text.trim()) {
                        return 'Password tidak cocok';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  isLoading
                      ? const CircularProgressIndicator()
                      : AuthButton(
                          text: 'Reset Password',
                          onPressed: _submit,
                        ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
