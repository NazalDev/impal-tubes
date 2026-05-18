import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volync/core/errors/exceptions.dart';
import 'package:volync/features/history/data/models/user_post_model.dart';
import 'package:volync/features/history/data/models/user_registration_model.dart';

abstract interface class HistoryRemoteDataSource {
  Future<List<UserRegistrationModel>> getUserRegistrations({
    required String userId,
  });

  Future<void> cancelRegistration({required String registrationId});

  Future<List<UserPostModel>> getUserPosts({required String userId});
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final SupabaseClient _supabase;
  HistoryRemoteDataSourceImpl(this._supabase);

  @override
  Future<List<UserRegistrationModel>> getUserRegistrations({
    required String userId,
  }) async {
    try {
      final response = await _supabase
          .from('registration')
          .select('''
            *,
            event (
              id,
              title,
              description,
              location,
              status,
              start_at,
              end_at,
              image_url,
              genre
            )
          ''')
          .eq('user_id', userId)
          .order('registered_at', ascending: false);

      return response
          .map((row) => UserRegistrationModel.fromMap(row))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> cancelRegistration({required String registrationId}) async {
    try {
      await _supabase
          .from('registration')
          .update({'status': 'cancelled'})
          .eq('id', registrationId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<UserPostModel>> getUserPosts({required String userId}) async {
    try {
      // Fetch posts (comments) by the user
      final postsResponse = await _supabase
          .from('postdisc')
          .select('''
            *,
            event (
              id,
              title,
              image_url
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final posts = postsResponse
          .map((row) => UserPostModel.fromPostMap(row))
          .toList();

      // Fetch replies by the user
      final repliesResponse = await _supabase
          .from('replydisc')
          .select('''
            *,
            postdisc:post_id (
              id,
              event_id,
              event (
                id,
                title,
                image_url
              )
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final replies = repliesResponse
          .map((row) => UserPostModel.fromReplyMap(row))
          .toList();

      // Merge and sort by createdAt descending
      final all = [...posts, ...replies];
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return all;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
