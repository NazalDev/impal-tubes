import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volync/core/errors/exceptions.dart';
import 'package:volync/features/report/data/models/report_model.dart';

abstract interface class ReportRemoteDataSource {
  Future<void> submitReport({
    required String? reportedUserId,
    required String? reportedEventId,
    required String reason,
    String? description,
  });

  Future<List<ReportModel>> getAllReports();
  Future<void> markReportAsSeen({required String reportId});
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final SupabaseClient _supabase;

  ReportRemoteDataSourceImpl(this._supabase);

  String get _currentUserId {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw const ServerException('Not authenticated');
    return id;
  }

  @override
  Future<void> submitReport({
    required String? reportedUserId,
    required String? reportedEventId,
    required String reason,
    String? description,
  }) async {
    try {
      await _supabase.from('report').insert({
        'reporter_user_id': _currentUserId,
        if (reportedUserId != null) 'reported_user_id': reportedUserId,
        if (reportedEventId != null) 'reported_event_id': int.tryParse(reportedEventId) ?? reportedEventId,
        'reason': reason,
        if (description != null && description.isNotEmpty) 'description': description,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ReportModel>> getAllReports() async {
    try {
      final response = await _supabase
          .from('report')
          .select(
            'id, reporter_user_id, reported_user_id, reported_event_id, '
            'reason, description, status, created_at, '
            'reporter:reporter_user_id ( username ), '
            'reported_user:reported_user_id ( username ), '
            'reported_event:reported_event_id ( title )',
          )
          .order('created_at', ascending: false);

      return response.map((row) => ReportModel.fromMap(row)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markReportAsSeen({required String reportId}) async {
    try {
      await _supabase
          .from('report')
          .update({'status': 'seen'})
          .eq('id', reportId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
