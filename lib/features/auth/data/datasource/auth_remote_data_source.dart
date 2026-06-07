import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volync/core/errors/exceptions.dart';
import 'package:volync/features/auth/data/models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Session? get currentUserSession;

  Future<UserModel> signUpWithEmailPassword({
    required String username,
    required String email,
    required String password,
  });
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<UserModel?> getCurrentUserData();

  /// Uploads [avatarFile] to the `avatars` Supabase Storage bucket and
  /// returns the public URL.  Pass `null` to skip the upload.
  Future<String?> uploadAvatar(File? avatarFile);

  Future<void> editProfile({
    String? username,
    String? avatarUrl,
    String? oldPassword,
    String? newPassword,
  });

  Future<void> resetPassword({
    required String username,
    required String email,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;
  AuthRemoteDataSourceImpl(this._supabaseClient);

  @override
  Session? get currentUserSession => _supabaseClient.auth.currentSession;

  @override
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user == null) {
        throw const ServerException('An error occured when signing in');
      }
      return UserModel.fromJson(res.user!.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'role': 'Pengguna',
          'avatar_url': 'default',
        },
      );
      if (res.user == null) {
        throw const ServerException('An error occured when signing up');
      }
      return UserModel.fromJson(res.user!.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUserSession != null) {
        final userData = await _supabaseClient
            .from('user')
            .select()
            .eq('id', currentUserSession!.user.id);
        return UserModel.fromJson(userData.first);
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
    return null;
  }

  // ── Avatar upload ─────────────────────────────────────────────────────────
  @override
  Future<String?> uploadAvatar(File? avatarFile) async {
    if (avatarFile == null) return null;
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) throw const ServerException('Not authenticated');
      final imageExtension = avatarFile.path.split('.').last.toLowerCase();
      final bytes = await avatarFile.readAsBytes();
      final storagePath = '$userId/profiles';

      await _supabaseClient.storage
          .from('avatars')
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/$imageExtension',
            ),
          );

      String publicUrl = _supabaseClient.storage
          .from('avatars')
          .getPublicUrl(storagePath);
      publicUrl = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      return publicUrl;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Gagal mengunggah foto: ${e.toString()}');
    }
  }

  // ── Edit profile ──────────────────────────────────────────────────────────
  @override
  Future<void> editProfile({
    String? username,
    String? avatarUrl,
    String? oldPassword,
    String? newPassword,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) throw const ServerException('Not authenticated');

      // Password change
      if (oldPassword != null &&
          newPassword != null &&
          newPassword.isNotEmpty) {
        await _supabaseClient.auth.refreshSession();
        final email = _supabaseClient.auth.currentUser?.email;
        if (email == null || email.isEmpty) {
          throw const ServerException('Tidak dapat mengambil email pengguna.');
        }
        try {
          final reAuth = await _supabaseClient.auth.signInWithPassword(
            email: email,
            password: oldPassword,
          );
          if (reAuth.user == null) {
            throw const ServerException('Password lama tidak sesuai.');
          }
        } on AuthException catch (e) {
          throw ServerException('Password lama tidak sesuai: ${e.message}');
        }
        final result = await _supabaseClient.auth.updateUser(
          UserAttributes(password: newPassword),
        );
        if (result.user == null) {
          throw const ServerException('Gagal memperbarui password.');
        }
      }

      // Profile fields
      final Map<String, dynamic> updates = {};
      if (username != null && username.isNotEmpty) {
        updates['username'] = username;
      }
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        updates['avatar_url'] = avatarUrl;
      }
      if (updates.isNotEmpty) {
        await _supabaseClient.from('user').update(updates).eq('id', userId);
        await _supabaseClient.auth.updateUser(UserAttributes(data: updates));
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> resetPassword({
    required String username,
    required String email,
    required String newPassword,
  }) async {
    try {
      final rows = await _supabaseClient
          .from('user')
          .select('id, username, email')
          .eq('username', username.trim())
          .eq('email', email.trim())
          .limit(1);

      if (rows.isEmpty) {
        throw const ServerException(
          'Username dan email tidak cocok. Periksa kembali data Anda.',
        );
      }

      final result = await _supabaseClient.rpc(
        'reset_user_password',
        params: {'p_email': email.trim(), 'p_new_password': newPassword},
      );

      if (result == false) {
        throw const ServerException(
          'Gagal mereset password. Silakan coba lagi.',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
