import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volync/features/event/data/models/event_model.dart';
import 'package:volync/features/event/data/models/post_disc_model.dart';
import 'package:volync/features/event/data/models/reply_post_disc_model.dart';

abstract class EventRemoteDataSource {
  Future<List<EventModel>> getEvents({
    int limit,
    int offset,
    String? searchQuery,
    String? statusFilter,
  });

  Future<void> createEvent(EventModel event);

  Future<void> registerEvent(int eventId, String userId);

  Future<List<PostDiscModel>> getComments({
    required String eventId,
    int limit,
    int offset,
  });

  Future<List<ReplyPostDiscModel>> getReplies({
    required String parentCommentId,
  });
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final SupabaseClient supabase;

  EventRemoteDataSourceImpl(this.supabase);

  // EVENTS

  @override
  Future<List<EventModel>> getEvents({
    int limit = 10,
    int offset = 0,
    String? searchQuery,
    String? statusFilter,
  }) async {
    if (statusFilter != null) statusFilter = statusFilter.toLowerCase();

    var query = supabase
        .from('event')
        .select()
        .order('start_at', ascending: true)
        .range(offset, offset + limit - 1);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query = supabase
          .from('event')
          .select()
          .ilike('title', '%$searchQuery%')
          .order('start_at', ascending: true)
          .range(offset, offset + limit - 1);
    }

    if (statusFilter != null && statusFilter != 'semua') {
      query = supabase
          .from('event')
          .select()
          .eq('genre', statusFilter)
          .order('start_at', ascending: true)
          .range(offset, offset + limit - 1);
    }

    if (searchQuery != null &&
        searchQuery.trim().isNotEmpty &&
        statusFilter != null &&
        statusFilter != 'semua') {
      query = supabase
          .from('event')
          .select()
          .ilike('title', '%$searchQuery%')
          .eq('genre', statusFilter)
          .order('start_at', ascending: true)
          .range(offset, offset + limit - 1);
    }

    final response = await query;
    return response.map((row) => EventModel.fromMap(row)).toList();
  }

  @override
  Future<void> createEvent(EventModel event) async {
    await supabase.from('event').insert(event.toMap());
  }

  // DISCUSCCION
  @override
  Future<List<PostDiscModel>> getComments({
    required String eventId,
    int limit = 5,
    int offset = 0,
  }) async {
    final response = await supabase
        .from('postdisc')
        .select('''
          *,
          user (
            id,
            username,
            avatar_url
          )
        ''')
        .eq('event_id', eventId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return response.map((row) => PostDiscModel.fromMap(row)).toList();
  }

  //REPLIES
  @override
  Future<List<ReplyPostDiscModel>> getReplies({
    required String parentCommentId,
  }) async {
    final response = await supabase
        .from('replydisc')
        .select('''
          *,
          user (
            id,
            username,
            avatar_url
          )
        ''')
        .eq('post_id', parentCommentId)
        .order('created_at', ascending: true);

    return response.map((row) => ReplyPostDiscModel.fromMap(row)).toList();
  }

  // REGISTER EVENT
  @override
  Future<void> registerEvent(int eventId, String userId) async {
    await supabase.from('registration').insert({
      'event_id': eventId,
      'user_id': userId,
      'registered_at': DateTime.now().toIso8601String(),
      'status': 'pending',
    });
  }
}
