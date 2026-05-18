import 'package:volync/features/event/domain/entity/event.dart';
import 'package:volync/features/event/domain/repository/event_repository.dart';

class GetCalendarEventsUseCase {
  final EventRepository repository;

  GetCalendarEventsUseCase(this.repository);

  Future<List<EventWithRegistration>> call({required String userId}) {
    return repository.getCalendarEvents(userId: userId);
  }
}

/// Combines an event with the current user's registration status (if any).
class EventWithRegistration {
  final EventEntity event;

  /// null  → user has never registered
  /// 'pending'  → registered, awaiting approval
  /// 'approved' → accepted
  /// 'rejected' → rejected
  /// 'cancelled'→ user or organiser cancelled
  final String? registrationStatus;

  const EventWithRegistration({
    required this.event,
    this.registrationStatus,
  });

  /// Derives the colour-coding category used by the calendar.
  CalendarDotColor get dotColor {
    final now = DateTime.now();
    final isFinished =
        event.status == 'finished' || event.startAt.isBefore(now);

    if (isFinished) return CalendarDotColor.grey;

    if (event.status == 'cancelled') return CalendarDotColor.red;

    switch (registrationStatus) {
      case 'approved':
        return CalendarDotColor.green;
      case 'pending':
        return CalendarDotColor.yellow;
      case 'rejected':
      case 'cancelled':
        return CalendarDotColor.red;
      default:
        return CalendarDotColor.teal; // not registered
    }
  }
}

enum CalendarDotColor { teal, yellow, red, green, grey }
