import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volync/core/errors/exceptions.dart';
import 'package:volync/features/profile/data/models/profile_event_model.dart';
import 'package:volync/features/profile/data/models/profile_member_model.dart';

abstract interface class ProfileRemoteDataSource {
  Future<List<ProfileEventModel>> getUserEvents({required String userId});

  /// Uploads [imageFile] to the `event-images` bucket and returns the public URL.
  /// Pass `null` to skip the upload (returns `null`).
  Future<String?> uploadEventImage({
    required String eventId,
    required File? imageFile,
  });

  Future<void> updateEvent({
    required String eventId,
    required Map<String, dynamic> data,
  });
  Future<void> deleteEvent({required String eventId});
  Future<void> cancelEvent({required String eventId});
  Future<List<ProfileMemberModel>> getEventMembers({required String eventId});
  Future<void> updateMemberStatus({
    required String registrationId,
    required String status,
  });
  Future<void> signOut();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient _supabase;

  ProfileRemoteDataSourceImpl(this._supabase);

  @override
  Future<List<ProfileEventModel>> getUserEvents({
    required String userId,
  }) async {
    try {
      final response = await _supabase
          .from('event')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map((row) => ProfileEventModel.fromMap(row)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ── Event image upload ────────────────────────────────────────────────────
  @override
  Future<String?> uploadEventImage({
    required String eventId,
    required File? imageFile,
  }) async {
    if (imageFile == null) return null;
    try {
      final imageExtension = imageFile.path.split('.').last.toLowerCase();
      final bytes = await imageFile.readAsBytes();
      final storagePath = '$eventId/images';

      await _supabase.storage
          .from('event-images')
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/$imageExtension',
            ),
          );

      String publicUrl = _supabase.storage
          .from('event-images')
          .getPublicUrl(storagePath);

      publicUrl = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      return publicUrl;
    } catch (e) {
      throw ServerException(
        'Gagal mengunggah gambar kegiatan: ${e.toString()}',
      );
    }
  }

  String get _currentUserId {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const ServerException('Not authenticated');
    }
    return userId;
  }

  @override
  Future<void> updateEvent({
    required String eventId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _supabase
          .from('event')
          .update({...data, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', eventId)
          .eq('user_id', _currentUserId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteEvent({required String eventId}) async {
    try {
      await _supabase
          .from('event')
          .delete()
          .eq('id', eventId)
          .eq('user_id', _currentUserId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> cancelEvent({required String eventId}) async {
    try {
      await _supabase
          .from('event')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', eventId)
          .eq('user_id', _currentUserId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ProfileMemberModel>> getEventMembers({
    required String eventId,
  }) async {
    try {
      final response = await _supabase
          .from('registration')
          .select('''
            *,
            user (
              id,
              username,
              email,
              avatar_url
            )
          ''')
          .eq('event_id', eventId)
          .order('registered_at', ascending: false);

      return response.map((row) => ProfileMemberModel.fromMap(row)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateMemberStatus({
    required String registrationId,
    required String status,
  }) async {
    try {
      await _supabase
          .from('registration')
          .update({'status': status})
          .eq('id', registrationId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
