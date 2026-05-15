// ignore_for_file: non_constant_identifier_names

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volync/core/common/entities/user.dart' as model;
import 'package:volync/data_class/event.dart';

class Postdisc {
  model.User _user_id;
  Event _event_id;
  String _title;
  String _body;
  DateTime? _created_at;
  DateTime? _updated_at;

  Postdisc({
    required model.User user_id,
    required Event event_id,
    required String title,
    required String body,
  }) : _user_id = user_id,
       _event_id = event_id,
       _title = title,
       _body = body;

  Future<void> createPost(
    model.User user_id,
    Event event_id,
    String title,
    String body,
    DateTime? created_a,
    DateTime? updated_at,
  ) async {
    //TODO: simpan post discussion ke database
  }

  Future<void> editPost() async {
    //TODO: edit post discussion di database
  }

  Future<void> deletePost() async {
    // TODDO: hapus post discussion dari database
  }

  Future<List<Postdisc>> getPosts(String eventId) async {
    //TODO: ambil semua post discussion untuk event tertentu dari database
    return [];
  }
}
