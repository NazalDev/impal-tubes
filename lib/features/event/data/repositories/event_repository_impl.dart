import 'package:volync/features/event/data/datasource/event_remote_datasource.dart';
import 'package:volync/features/event/data/models/event_model.dart';
import 'package:volync/features/event/domain/entity/event.dart';
import 'package:volync/features/event/domain/entity/post_disc.dart';
import 'package:volync/features/event/domain/entity/reply_post_disc.dart';
import 'package:volync/features/event/domain/repository/event_repository.dart';
import 'package:volync/features/event/domain/repository/post_disc_repository.dart';
import 'package:volync/features/event/domain/usecase/get_calendar_events_usecase.dart';

// ── EVENT ──────────────────────────────────────────────────────────────────────

class EventRepositoryImpl implements EventRepository {
  EventRepositoryImpl(this.remoteDataSource);

  final EventRemoteDataSource remoteDataSource;

  @override
  Future<List<EventEntity>> getEvents({
    int limit = 10,
    int offset = 0,
    String? searchQuery,
    String? statusFilter,
  }) => remoteDataSource.getEvents(
        limit: limit,
        offset: offset,
        searchQuery: searchQuery,
        statusFilter: statusFilter,
      );

  @override
  Future<void> createEvent(EventEntity event) =>
      remoteDataSource.createEvent(_toModel(event));

  @override
  Future<void> registerEvent(int eventId, String userId) =>
      remoteDataSource.registerEvent(eventId, userId);

  @override
  Future<List<EventWithRegistration>> getCalendarEvents({
    required String userId,
  }) => remoteDataSource.getCalendarEvents(userId: userId);

  @override
  Future<bool> isUserRegistered({
    required int eventId,
    required String userId,
  }) => remoteDataSource.isUserRegistered(eventId: eventId, userId: userId);

  // ── Helpers ──────────────────────────────────────────────────────────────

  EventModel _toModel(EventEntity e) => EventModel(
        id: 0,
        userId: e.userId,
        title: e.title,
        description: e.description,
        location: e.location,
        status: e.status,
        genre: e.genre,
        quota: e.quota,
        imageUrl: e.imageUrl,
        startAt: e.startAt,
        endAt: e.endAt,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );
}

// ── POST DISC ──────────────────────────────────────────────────────────────────

class PostDiscRepositoryImpl implements PostDiscRepository {
  PostDiscRepositoryImpl(this.remoteDataSource);

  final EventRemoteDataSource remoteDataSource;

  @override
  Future<List<PostDiscEntity>> getComments({
    required int eventId,
    int limit = 5,
    int offset = 0,
  }) => remoteDataSource.getComments(
        eventId: eventId,
        limit: limit,
        offset: offset,
      );

  @override
  Future<List<ReplyPostDiscEntity>> getReplies({
    required String parentCommentId,
  }) => remoteDataSource.getReplies(parentCommentId: parentCommentId);

  @override
  Future<PostDiscEntity> postComment({
    required int eventId,
    required String userId,
    required String body,
  }) => remoteDataSource.postComment(
        eventId: eventId,
        userId: userId,
        body: body,
      );

  @override
  Future<ReplyPostDiscEntity> postReply({
    required String postId,
    required String userId,
    required String body,
  }) => remoteDataSource.postReply(
        postId: postId,
        userId: userId,
        body: body,
      );
}