// ignore_for_file: non_constant_identifier_names

import 'package:volync/core/common/entities/user.dart' as model;
import 'package:volync/data_class/event.dart';

class Registration {
  model.User _user_id;
  Event _event_id;
  String _status;
  String _notes;
  DateTime? _registered_at;
  DateTime? _updated_at;

  Registration({
    required model.User user_id,
    required Event event_id,
    required String status,
    required String notes,
  }) : _user_id = user_id,
       _event_id = event_id,
       _status = status,
       _notes = notes;

  Future<List<Registration>> getRegistrationsForUser(String userId) async {
    //TODO: ambil pendaftaran untuk pengguna tertentu dari database
    return [];
  }

  Future<void> submitRegistration(
    model.User userId,
    Event eventId,
    String status,
    String notes,
    DateTime? registeredAt,
    DateTime? updatedAt,
  ) async {
    //TODO: simpan pendaftaran ke database
  }

  Future<void> cancelRegistration() async {
    // TODO: update status pendaftaran menjadi cancel
  }

  Future<void> updateStatus() async {
    // TODO: Update status pendaftaran (untuk penyelenggara)
  }
}
