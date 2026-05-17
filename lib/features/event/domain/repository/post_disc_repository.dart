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
}
