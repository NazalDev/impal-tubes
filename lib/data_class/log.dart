// ignore_for_file: non_constant_identifier_names

class Log {
  String _user_id;
  String _action;
  DateTime _logged_at;

  Log({
    required String user_id,
    required String action,
    required DateTime logged_at,
  }) : _user_id = user_id,
       _action = action,
       _logged_at = logged_at;

  Future<void> setLog() async {
    //TODO: simpan log ke database
  }

  Future<List<Log>> getLogsForUser(String userId) async {
    //TODO: ambil log untuk pengguna tertentu dari database
    return [];
  }
}
