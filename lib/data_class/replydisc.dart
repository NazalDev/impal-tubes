// ignore_for_file: non_constant_identifier_names

import 'package:volync/core/common/entities/user.dart' as model;
import 'package:volync/data_class/postdisc.dart';

class ReplyDisc {
  Postdisc _post_id;
  model.User _user_id;
  String _body;
  DateTime? _created_at;
  DateTime? _updated_at;

  ReplyDisc({
    required Postdisc post_id,
    required model.User user_id,
    required String body,
  }) : _post_id = post_id,
       _user_id = user_id,
       _body = body;

  Future<void> createReply(
    Postdisc post_id,
    model.User user_id,
    String body,
    DateTime? created_at,
    DateTime? updated_at,
  ) async {}

  Future<void> editReply() async {
    //TODO:: edit reply discussion di database
  }

  Future<void> deleteReply() async {
    //TODO : Hapus reply discussion di database
  }

  Future<List<ReplyDisc>> getReplies(String postId) async {
    //TODO: ambil semua reply yang ada di suatu post discussion dari database
    return [];
  }
}
