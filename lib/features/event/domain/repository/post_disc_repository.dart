import 'package:volync/features/event/domain/entity/post_disc.dart';
import 'package:volync/features/event/domain/entity/reply_post_disc.dart';

abstract class PostDiscRepository {
  Future<List<PostDiscEntity>> getComments({
    required int eventId,
    int limit = 5,
    int offset = 0,
  });

  Future<List<ReplyPostDiscEntity>> getReplies({
    required String parentCommentId,
  });

  Future<PostDiscEntity> postComment({
    required int eventId,
    required String userId,
    required String body,
  });

  Future<ReplyPostDiscEntity> postReply({
    required String postId,
    required String userId,
    required String body,
  });
}
