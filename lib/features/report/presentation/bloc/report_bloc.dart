import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:volync/features/report/domain/entity/report_entity.dart';
import 'package:volync/features/report/domain/usecase/report_usecases.dart';

part 'report_event.dart';
part 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final SubmitReportUseCase _submitReport;
  final GetAllReportsUseCase _getAllReports;
  final MarkReportAsSeenUseCase _markAsSeen;

  ReportBloc({
    required SubmitReportUseCase submitReport,
    required GetAllReportsUseCase getAllReports,
    required MarkReportAsSeenUseCase markAsSeen,
  }) : _submitReport = submitReport,
       _getAllReports = getAllReports,
       _markAsSeen = markAsSeen,
       super(ReportInitial()) {
    on<ReportSubmit>(_onSubmit);
    on<ReportLoadAll>(_onLoadAll);
    on<ReportMarkSeen>(_onMarkSeen);
  }

  Future<void> _onSubmit(ReportSubmit event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    final res = await _submitReport(
      reportedUserId: event.reportedUserId,
      reportedEventId: event.reportedEventId,
      reason: event.reason,
      description: event.description,
    );
    res.fold(
      (failure) => emit(ReportFailure(failure.message)),
      (_) => emit(ReportSubmitSuccess()),
    );
  }

  Future<void> _onLoadAll(
    ReportLoadAll event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    final res = await _getAllReports();
    res.fold(
      (failure) => emit(ReportFailure(failure.message)),
      (reports) => emit(ReportLoaded(reports)),
    );
  }

  Future<void> _onMarkSeen(
    ReportMarkSeen event,
    Emitter<ReportState> emit,
  ) async {
    final res = await _markAsSeen(reportId: event.reportId);
    res.fold(
      (failure) => emit(ReportFailure(failure.message)),
      (_) => emit(ReportMarkSeenSuccess()),
    );
  }
}
