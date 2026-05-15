// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:volync/core/common/widgets/loader.dart';
import 'package:volync/core/theme/app_pallete.dart';
import 'package:volync/core/common/image_show.dart';
import 'package:volync/core/utils/show_popup.dart';
import 'package:volync/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:volync/features/auth/presentation/widgets/auth_button.dart';
import 'package:volync/features/auth/presentation/widgets/auth_field.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailControl = TextEditingController();
  TextEditingController nameControl = TextEditingController();
  TextEditingController passControl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    return emailRegex.hasMatch(email);
  }

  @override
  void dispose() {
    emailControl.dispose();
    nameControl.dispose();
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
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.teal[900]),
          onPressed: () {
            emailControl.clear();
            nameControl.clear();
            passControl.clear();

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
                    ImageShow(width: 150, height: 150),

                    Text(
                      'Buat Akun Baru',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppPallete.blackColor,
                        fontSize: 50,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 32),

                    AuthField(
                      controller: nameControl,
                      hintText: 'Masukkan username',
                      icon: Icon(Icons.person),
                    ),
                    const SizedBox(height: 16),
                    AuthField(
                      controller: emailControl,
                      hintText: 'username@gmail.com',
                      icon: Icon(Icons.email),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Email tidak boleh kosong';
                        } else if (!_isValidEmail(value!)) {
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
                        if (value?.isEmpty ?? true) {
                          return 'Password tidak boleh kosong';
                        } else if (value!.length < 6) {
                          return 'Panjang password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),
                    AuthButton(
                      text: 'Buat Akun',
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            AuthSignUp(
                              username: nameControl.text.trim(),
                              email: emailControl.text.trim(),
                              password: passControl.text.trim(),
                            ),
                          );

                          Navigator.pop(context);
                        }
                      },
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
