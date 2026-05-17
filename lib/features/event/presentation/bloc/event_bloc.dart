import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:volync/features/event/domain/entity/event.dart';
import 'package:volync/features/event/domain/usecase/create_event_usecase.dart';
import 'package:volync/features/event/domain/usecase/get_events_usecase.dart';
import 'package:volync/features/event/domain/usecase/regist_event_usecase.dart';

part 'event_state.dart';
part 'event_event.dart';

class EventBloc extends Bloc<EventBlocEvent, EventBlocState> {
  final GetEventsUseCase getEventsUseCase;
  final CreateEventUseCase createEventUseCase;
  final RegistEventUsecase registerEventUseCase;

  static const int _pageSize = 10;
  int _offset = 0;

  EventBloc({
    required this.getEventsUseCase,
    required this.createEventUseCase,
    required this.registerEventUseCase,
  }) : super(EventInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<SearchEvents>(_onSearchEvents);
    on<FilterEvents>(_onFilterEvents);
    on<CreateEvent>(_onCreateEvent);
    on<RegisterEvent>(_onRegisterEvent);
    on<ResetEventState>(_onResetState);
  }

  Future<void> _onResetState(
    ResetEventState event,
    Emitter<EventBlocState> emit,
  ) async {
    // Re-emit EventLoaded if we have events, otherwise EventInitial
    // This clears any stale create/register states
    final current = state;
    if (current is EventLoaded) {
      emit(
        EventLoaded(
          events: current.events,
          hasMore: current.hasMore,
          activeFilter: current.activeFilter,
          searchQuery: current.searchQuery,
        ),
      );
    }
  }

  Future<void> _onLoadEvents(
    LoadEvents event,
    Emitter<EventBlocState> emit,
  ) async {
    final currentState = state;

    final activeFilter = currentState is EventLoaded
        ? currentState.activeFilter
        : 'Semua';
    final searchQuery = currentState is EventLoaded
        ? currentState.searchQuery
        : '';

    if (event.reset) {
      _offset = 0;
      emit(EventLoading());
    }

    try {
      final fetched = await getEventsUseCase(
        limit: _pageSize,
        offset: _offset,
        searchQuery: event.searchQuery ?? searchQuery,
        statusFilter: event.statusFilter ?? activeFilter,
      );

      final existing = (event.reset || state is! EventLoaded)
          ? <EventEntity>[]
          : (state as EventLoaded).events;

      _offset += fetched.length;

      emit(
        EventLoaded(
          events: [...existing, ...fetched],
          hasMore: fetched.length == _pageSize,
          activeFilter: event.statusFilter ?? activeFilter,
          searchQuery: event.searchQuery ?? searchQuery,
        ),
      );
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onSearchEvents(
    SearchEvents event,
    Emitter<EventBlocState> emit,
  ) async {
    final activeFilter = state is EventLoaded
        ? (state as EventLoaded).activeFilter
        : 'Semua';

    add(
      LoadEvents(
        reset: true,
        searchQuery: event.query,
        statusFilter: activeFilter,
      ),
    );
  }

  Future<void> _onFilterEvents(
    FilterEvents event,
    Emitter<EventBlocState> emit,
  ) async {
    final searchQuery = state is EventLoaded
        ? (state as EventLoaded).searchQuery
        : '';

    add(
      LoadEvents(
        reset: true,
        searchQuery: searchQuery,
        statusFilter: event.filter,
      ),
    );
  }

  Future<void> _onCreateEvent(
    CreateEvent event,
    Emitter<EventBlocState> emit,
  ) async {
    emit(EventCreating());
    try {
      await createEventUseCase(event.event);
      emit(EventCreated());
    } catch (e) {
      emit(EventCreateError(_parseError(e)));
      print(e);
    }
  }

  Future<void> _onRegisterEvent(
    RegisterEvent event,
    Emitter<EventBlocState> emit,
  ) async {
    emit(EventRegistering());
    try {
      await registerEventUseCase(eventId: event.eventId, userId: event.userId);
      emit(EventRegistered());
    } catch (e) {
      emit(EventRegisterError(_parseError(e)));
    }
  }
}

String _parseError(Object error) {
  final msg = error.toString().toLowerCase();
  if (msg.contains('jwt') ||
      msg.contains('not authenticated') ||
      msg.contains('invalid token')) {
    return 'Sesi Anda telah berakhir. Silakan login kembali.';
  }
  if (msg.contains('network') ||
      msg.contains('socket') ||
      msg.contains('connection') ||
      msg.contains('unreachable')) {
    return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
  }
  if (msg.contains('unique') || msg.contains('duplicate')) {
    return 'Kegiatan dengan nama dan tanggal yang sama sudah ada.';
  }
  if (msg.contains('foreign key') || msg.contains('violates')) {
    return 'Data tidak valid. Pastikan akun Anda terdaftar dengan benar.';
  }
  if (msg.contains('row-level security') ||
      msg.contains('permission') ||
      msg.contains('403')) {
    return 'Anda tidak memiliki izin untuk membuat kegiatan.';
  }
  if (msg.contains('timeout')) {
    return 'Permintaan habis waktu. Silakan coba lagi.';
  }
  if (msg.contains('500') || msg.contains('internal server')) {
    return 'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
  }
  return 'Gagal mengunggah kegiatan. Silakan coba lagi.';
}
