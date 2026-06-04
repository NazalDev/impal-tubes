import 'package:volync/features/event/domain/entity/event.dart';
import 'package:volync/features/event/domain/repository/event_repository.dart';

class GetCalendarEventsUseCase {
  GetCalendarEventsUseCase(this.repository);

  final EventRepository repository;

  Future<List<EventWithRegistration>> call({required String userId}) =>
      repository.getCalendarEvents(userId: userId);
}

// ── EventWithRegistration ─────────────────────────────────────────────────────

/// Combines an event with the current user's registration status (if any).
class EventWithRegistration {
  const EventWithRegistration({
    required this.event,
    this.registrationStatus,
  });

  final EventEntity event;

  /// Possible values:
  /// - `null`        → user has never registered
  /// - `'pending'`   → registered, awaiting approval
  /// - `'approved'`  → accepted
  /// - `'rejected'`  → rejected
  /// - `'cancelled'` → user or organiser cancelled
  final String? registrationStatus;

  /// Derives the colour-coding category used by the calendar.
  CalendarDotColor get dotColor {
    if (event.status == 'finished' || event.startAt.isBefore(DateTime.now())) {
      return CalendarDotColor.grey;
    }

    if (event.status == 'cancelled') return CalendarDotColor.red;

    return switch (registrationStatus) {
      'approved' => CalendarDotColor.green,
      'pending' => CalendarDotColor.yellow,
      'rejected' || 'cancelled' => CalendarDotColor.red,
      _ => CalendarDotColor.teal, // not registered
    };
  }
}

// ── CalendarDotColor ──────────────────────────────────────────────────────────

enum CalendarDotColor { teal, yellow, red, green, grey }