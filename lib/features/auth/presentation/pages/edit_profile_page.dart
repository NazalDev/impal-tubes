import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _changePassword = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Avatar file upload (max 1 MB)
  File? _pickedAvatar;
  String? _avatarError;
  static const int _maxAvatarBytes = 1 * 1024 * 1024; // 1 MB

  @override
  void initState() {
    super.initState();
    final cubitState = context.read<AppUserCubit>().state;
    final user = cubitState is AppUserLoggedIn ? cubitState.user : null;
    _usernameController = TextEditingController(text: user?.username ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Avatar picker ─────────────────────────────────────────────────────────
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final bytes = await file.length();

    if (bytes > _maxAvatarBytes) {
      setState(() {
        _pickedAvatar = null;
        _avatarError = 'Ukuran gambar maksimal 1 MB.';
      });
      return;
    }
    setState(() {
      _pickedAvatar = file;
      _avatarError = null;
    });
  }

  void _removeAvatar() => setState(() {
        _pickedAvatar = null;
        _avatarError = null;
      });

  // ── Submit ────────────────────────────────────────────────────────────────
  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final username = _usernameController.text.trim();
    final oldPassword = _changePassword ? _oldPasswordController.text : null;
    final newPassword = _changePassword ? _newPasswordController.text : null;

    context.read<AuthBloc>().add(
      AuthEditProfile(
        username: username.isNotEmpty ? username : null,
        avatarFile: _pickedAvatar,
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
      fillColor: AppPallete.whiteColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppPallete.focusedColor, width: 1.5),
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
            SnackBar(
              content: const Text('Profil berhasil diperbarui!'),
              backgroundColor: AppPallete.focusedColor,
            ),
          );
          Navigator.pop(context);
        } else if (state is AuthEditProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppPallete.errorColor,
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
            color: AppPallete.backButtonColor,
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
                    // ── Avatar preview & upload ──────────────────────
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          BlocBuilder<AppUserCubit, AppUserState>(
                            builder: (context, userState) {
                              if (_pickedAvatar != null) {
                                return CircleAvatar(
                                  radius: 50,
                                  backgroundImage: FileImage(_pickedAvatar!),
                                );
                              }
                              final user = userState is AppUserLoggedIn
                                  ? userState.user
                                  : null;
                              final avatarUrl = user?.avatar_url;
                              if (avatarUrl != null &&
                                  avatarUrl != 'default' &&
                                  avatarUrl.isNotEmpty) {
                                return CircleAvatar(
                                  radius: 50,
                                  backgroundImage: NetworkImage(avatarUrl),
                                  onBackgroundImageError: (_, _) {},
                                );
                              }
                              return CircleAvatar(
                                radius: 50,
                                backgroundColor:
                                    AppPallete.buttonColor.withValues(alpha: 0.2),
                                child: Text(
                                  (user?.username.isNotEmpty == true)
                                      ? user!.username[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    color: AppPallete.buttonColor,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Edit badge
                          GestureDetector(
                            onTap: _pickAvatar,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppPallete.focusedColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppPallete.whiteColor,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 16,
                                color: AppPallete.whiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_pickedAvatar != null) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                          onPressed: _removeAvatar,
                          icon: Icon(Icons.delete_outline,
                              size: 16, color: AppPallete.errorColor),
                          label: Text(
                            'Hapus foto',
                            style: TextStyle(
                                color: AppPallete.errorColor, fontSize: 12),
                          ),
                        ),
                      ),
                    ],

                    if (_avatarError != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _avatarError!,
                            style: TextStyle(
                                color: AppPallete.errorColor, fontSize: 11),
                          ),
                        ),
                      ),

                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'Ketuk ikon kamera untuk ganti foto (maks. 1 MB)',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppPallete.borderColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Username ─────────────────────────────────────
                    const Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppPallete.defaultTextColor,
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
                    const SizedBox(height: 24),

                    // ── Password toggle ───────────────────────────────
                    Row(
                      children: [
                        Switch(
                          value: _changePassword,
                          onChanged: (val) =>
                              setState(() => _changePassword = val),
                          activeColor: AppPallete.focusedColor,
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
                              color: AppPallete.borderColor,
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
                              color: AppPallete.borderColor,
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
                              color: AppPallete.borderColor,
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

                    // ── Save button ───────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.focusedColor,
                          foregroundColor: AppPallete.whiteColor,
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
                                  color: AppPallete.whiteColor,
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
