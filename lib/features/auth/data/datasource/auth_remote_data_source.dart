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

  Future<void> editProfile({
    String? username,
    String? avatarUrl,
    String? oldPassword,
    String? newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;
  AuthRemoteDataSourceImpl(this._supabaseClient);

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
  Session? get currentUserSession => _supabaseClient.auth.currentSession;

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

      // Change password if requested
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

        // Step 3: Update to new password
        final result = await _supabaseClient.auth.updateUser(
          UserAttributes(password: newPassword),
        );
        if (result.user == null) {
          throw const ServerException('Gagal memperbarui password.');
        }
      }

      // Update profile data in the user table
      final Map<String, dynamic> updates = {};
      if (username != null && username.isNotEmpty) {
        updates['username'] = username;
      }
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        updates['avatar_url'] = avatarUrl;
      }
      if (updates.isNotEmpty) {
        // Update public.user table
        await _supabaseClient.from('user').update(updates).eq('id', userId);

        // Also update auth metadata so it persists across sessions
        final Map<String, dynamic> metaUpdates = {};
        if (username != null && username.isNotEmpty) {
          metaUpdates['username'] = username;
        }
        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          metaUpdates['avatar_url'] = avatarUrl;
        }
        if (metaUpdates.isNotEmpty) {
          await _supabaseClient.auth.updateUser(
            UserAttributes(data: metaUpdates),
          );
        }
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      print(e);
      throw ServerException(e.toString());
    }
  }
}
