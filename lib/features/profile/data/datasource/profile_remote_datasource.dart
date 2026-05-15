import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volync/core/errors/exceptions.dart';
import 'package:volync/features/profile/data/models/profile_event_model.dart';
import 'package:volync/features/profile/data/models/profile_member_model.dart';

abstract interface class ProfileRemoteDataSource {
  Future<List<ProfileEventModel>> getUserEvents({required String userId});
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

  @override
  Future<void> updateEvent({
    required String eventId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _supabase
          .from('event')
          .update({...data, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', eventId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteEvent({required String eventId}) async {
    try {
      await _supabase.from('event').delete().eq('id', eventId);
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
          .eq('id', eventId);
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
            users (
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
