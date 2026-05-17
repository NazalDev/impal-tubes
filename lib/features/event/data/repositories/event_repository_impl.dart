import 'package:volync/features/event/data/datasource/event_remote_datasource.dart';
import 'package:volync/features/event/data/models/event_model.dart';
import 'package:volync/features/event/domain/entity/event.dart';
import 'package:volync/features/event/domain/entity/post_disc.dart';
import 'package:volync/features/event/domain/entity/reply_post_disc.dart';
import 'package:volync/features/event/domain/repository/event_repository.dart';
import 'package:volync/features/event/domain/repository/post_disc_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;

  EventRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<EventEntity>> getEvents({
    int limit = 10,
    int offset = 0,
    String? searchQuery,
    String? statusFilter,
  }) {
    return remoteDataSource.getEvents(
      limit: limit,
      offset: offset,
      searchQuery: searchQuery,
      statusFilter: statusFilter,
    );
  }

  @override
  Future<void> createEvent(EventEntity event) {
    // Convert entity → model so the datasource can call toMap()
    final model = EventModel(
      userId: event.userId,
      title: event.title,
      description: event.description,
      location: event.location,
      status: event.status,
      startAt: event.startAt,
      endAt: event.endAt,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
      imageUrl: event.imageUrl,
      id: 0,
    );
    return remoteDataSource.createEvent(model);
  }

  @override
  Future<void> registerEvent(int eventId, String userId) {
    return remoteDataSource.registerEvent(eventId, userId);
  }
}

class PostDiscRepositoryImpl implements PostDiscRepository {
  final EventRemoteDataSource remoteDataSource;

  PostDiscRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<PostDiscEntity>> getComments({
    required int eventId,
    int limit = 5,
    int offset = 0,
  }) {
    return remoteDataSource.getComments(
      eventId: eventId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<ReplyPostDiscEntity>> getReplies({
    required String parentCommentId,
  }) {
    return remoteDataSource.getReplies(parentCommentId: parentCommentId);
  }

  @override
  Future<PostDiscEntity> postComment({
    required int eventId,
    required String userId,
    required String body,
  }) {
    return remoteDataSource.postComment(
      eventId: eventId,
      userId: userId,
      body: body,
    );
  }

  @override
  Future<ReplyPostDiscEntity> postReply({
    required String postId,
    required String userId,
    required String body,
  }) {
    return remoteDataSource.postReply(
      postId: postId,
      userId: userId,
      body: body,
    );
  }
}
