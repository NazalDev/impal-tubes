import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:volync/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:volync/core/theme/app_pallete.dart';
import 'package:volync/features/auth/presentation/bloc/auth_bloc.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _avatarUrlController;
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _changePassword = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    final cubitState = context.read<AppUserCubit>().state;
    final user = cubitState is AppUserLoggedIn ? cubitState.user : null;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _avatarUrlController = TextEditingController(
      text: (user?.avatar_url == 'default' ? '' : user?.avatar_url) ?? '',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _avatarUrlController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final username = _usernameController.text.trim();
    final avatarUrl = _avatarUrlController.text.trim();
    final oldPassword = _changePassword ? _oldPasswordController.text : null;
    final newPassword = _changePassword ? _newPasswordController.text : null;

    context.read<AuthBloc>().add(
      AuthEditProfile(
        username: username.isNotEmpty ? username : null,
        avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
        oldPassword: oldPassword,
        newPassword: newPassword,
      ),
    );
  }

  InputDecoration _decoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.teal, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, s) =>
          s is AuthEditProfileSuccess ||
          s is AuthEditProfileFailure ||
          s is AuthEditProfileLoading,
      listener: (context, state) {
        if (state is AuthEditProfileSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil diperbarui!'),
              backgroundColor: Colors.teal,
            ),
          );
          Navigator.pop(context);
        } else if (state is AuthEditProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red[700],
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppPallete.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppPallete.cardBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Edit Profil',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (_, s) =>
              s is AuthEditProfileLoading ||
              s is AuthEditProfileSuccess ||
              s is AuthEditProfileFailure,
          builder: (context, state) {
            final isLoading = state is AuthEditProfileLoading;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar preview ─────────────────────
                    Center(
                      child: BlocBuilder<AppUserCubit, AppUserState>(
                        builder: (context, userState) {
                          final avatarUrl = _avatarUrlController.text.trim();
                          if (avatarUrl.isNotEmpty) {
                            return CircleAvatar(
                              radius: 44,
                              backgroundImage: NetworkImage(avatarUrl),
                              onBackgroundImageError: (_, _) {},
                            );
                          }
                          final user = userState is AppUserLoggedIn
                              ? userState.user
                              : null;
                          return CircleAvatar(
                            radius: 44,
                            backgroundColor: AppPallete.buttonColor.withValues(
                              alpha: 0.2,
                            ),
                            child: Text(
                              (user?.username.isNotEmpty == true)
                                  ? user!.username[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: AppPallete.buttonColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Username ───────────────────────────
                    const Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _usernameController,
                      decoration: _decoration('Username'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Username tidak boleh kosong.';
                        }
                        if (v.trim().length < 3) {
                          return 'Username minimal 3 karakter.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Avatar URL ─────────────────────────
                    const Text(
                      'URL Foto Profil',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _avatarUrlController,
                      decoration: _decoration(
                        'https://... (kosongkan untuk gunakan inisial)',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),

                    // ── Password toggle ────────────────────
                    Row(
                      children: [
                        Switch(
                          value: _changePassword,
                          onChanged: (val) =>
                              setState(() => _changePassword = val),
                          activeColor: Colors.teal,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Ganti Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    if (_changePassword) ...[
                      const SizedBox(height: 16),

                      // Old password
                      TextFormField(
                        controller: _oldPasswordController,
                        obscureText: _obscureOld,
                        decoration: _decoration(
                          'Password Lama',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureOld
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () =>
                                setState(() => _obscureOld = !_obscureOld),
                          ),
                        ),
                        validator: _changePassword
                            ? (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Masukkan password lama.';
                                }
                                return null;
                              }
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // New password
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNew,
                        decoration: _decoration(
                          'Password Baru',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNew
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () =>
                                setState(() => _obscureNew = !_obscureNew),
                          ),
                        ),
                        validator: _changePassword
                            ? (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Masukkan password baru.';
                                }
                                if (v.length < 6) {
                                  return 'Password minimal 6 karakter.';
                                }
                                return null;
                              }
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Confirm password
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        decoration: _decoration(
                          'Konfirmasi Password Baru',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                        ),
                        validator: _changePassword
                            ? (v) {
                                if (v != _newPasswordController.text) {
                                  return 'Password tidak cocok.';
                                }
                                return null;
                              }
                            : null,
                      ),
                    ],

                    const SizedBox(height: 32),

                    // ── Save button ────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
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
