// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:volync/core/common/navbar.dart';
import 'package:volync/core/common/widgets/loader.dart';
import 'package:volync/core/theme/app_pallete.dart';
import 'package:volync/core/common/image_show.dart';
import 'package:volync/core/utils/show_popup.dart';
import 'package:volync/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:volync/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:volync/features/auth/presentation/widgets/auth_button.dart';
import 'package:volync/features/auth/presentation/widgets/auth_field.dart';

class LoginEmail extends StatefulWidget {
  const LoginEmail({super.key});

  @override
  State<LoginEmail> createState() => _LoginEmailState();
}

class _LoginEmailState extends State<LoginEmail> {
  TextEditingController emailControl = TextEditingController();
  TextEditingController passControl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String? _loginError;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    return emailRegex.hasMatch(email);
  }

  @override
  void dispose() {
    emailControl.dispose();
    passControl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 232, 246, 243),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppPallete.backButtonColor,
          ),
          onPressed: () {
            emailControl.clear();
            Navigator.pop(context);
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(32),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              showPopup(context, state.message);
            }
            if (state is AuthSuccess) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NavigationBarCustom()),
              );
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Loader();
            }

            return Form(
              key: formKey,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    ImageShow(width: 250, height: 250),

                    Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Text(
                        'Login Akun Volync',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppPallete.defaultTextColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    if (_loginError != null)
                      Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _loginError!,
                                style: TextStyle(
                                  color: Colors.red[700],

                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 32),
                    AuthField(
                      controller: emailControl,
                      hintText: 'username@gmail.com',
                      icon: Icon(Icons.mark_email_unread),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Email tidak boleh kosong';
                        } else if (!_isValidEmail(value)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthField(
                      controller: passControl,
                      hintText: 'Masukkan Password',
                      icon: Icon(Icons.key),
                      obscureIcon: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Password tidak boleh kosong';
                        } else if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    AuthButton(
                      text: 'Next',
                      onPressed: () {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        context.read<AuthBloc>().add(
                          AuthLogin(
                            email: emailControl.text.trim(),
                            password: passControl.text.trim(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage(),
                        ),
                      ),
                      child: RichText(
                        text: TextSpan(
                          text: 'Lupa Password?',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: AppPallete.linkColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
