import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volync/core/theme/app_pallete.dart';
import 'package:volync/features/event/domain/usecase/get_calendar_events_usecase.dart';
import 'package:volync/features/event/domain/usecase/get_post_disc_usecase.dart';
import 'package:volync/features/event/presentation/bloc/event_bloc.dart';
import 'package:volync/features/event/presentation/widgets/event_detail_sheet.dart';
import 'package:volync/init_dependencies.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadCalendar();
  }

  void _loadCalendar() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      context.read<EventBloc>().add(LoadCalendarEvents(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      body: SafeArea(
        child: BlocBuilder<EventBloc, EventBlocState>(
          buildWhen: (_, s) =>
              s is CalendarLoading ||
              s is CalendarLoaded ||
              s is CalendarError,
          builder: (context, state) {
            if (state is CalendarLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              );
            }

            if (state is CalendarError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadCalendar,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            final events =
                state is CalendarLoaded ? state.events : <EventWithRegistration>[];

            return _CalendarBody(
              events: events,
              focusedMonth: _focusedMonth,
              selectedDay: _selectedDay,
              onMonthChanged: (m) => setState(() => _focusedMonth = m),
              onDaySelected: (d) => setState(() => _selectedDay = d),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CalendarBody extends StatelessWidget {
  final List<EventWithRegistration> events;
  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDaySelected;

  const _CalendarBody({
    required this.events,
    required this.focusedMonth,
    required this.selectedDay,
    required this.onMonthChanged,
    required this.onDaySelected,
  });

  /// Returns all events whose startAt falls on [day].
  List<EventWithRegistration> _eventsForDay(DateTime day) {
    return events.where((e) {
      final d = e.event.startAt;
      return d.year == day.year && d.month == day.month && d.day == day.day;
    }).toList();
  }

  /// Returns events shown in the list below — either selected-day events or
  /// ALL events in the focused month when no day is selected.
  List<EventWithRegistration> get _listedEvents {
    if (selectedDay != null) return _eventsForDay(selectedDay!);
    return events.where((e) {
      final d = e.event.startAt;
      return d.year == focusedMonth.year && d.month == focusedMonth.month;
    }).toList()
      ..sort((a, b) => a.event.startAt.compareTo(b.event.startAt));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(
            children: [
              const Text(
                'Kalender',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.teal),
                onPressed: () {
                  final userId =
                      Supabase.instance.client.auth.currentUser?.id;
                  if (userId != null) {
                    context
                        .read<EventBloc>()
                        .add(LoadCalendarEvents(userId: userId));
                  }
                },
              ),
            ],
          ),
        ),

        // ── Calendar widget ────────────────────────────────────
        _MonthCalendar(
          focusedMonth: focusedMonth,
          selectedDay: selectedDay,
          eventsForDay: _eventsForDay,
          onMonthChanged: onMonthChanged,
          onDaySelected: onDaySelected,
        ),

        const SizedBox(height: 8),

        // ── Legend ────────────────────────────────────────────
        const _Legend(),

        const SizedBox(height: 8),

        // ── Event list ────────────────────────────────────────
        Expanded(
          child: _listedEvents.isEmpty
              ? Center(
                  child: Text(
                    selectedDay != null
                        ? 'Tidak ada event pada hari ini'
                        : 'Tidak ada event bulan ini',
                    style: const TextStyle(color: Colors.black45),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _listedEvents.length,
                  itemBuilder: (context, i) {
                    return _CalendarEventCard(
                      eventWithReg: _listedEvents[i],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _MonthCalendar extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final List<EventWithRegistration> Function(DateTime) eventsForDay;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDaySelected;

  const _MonthCalendar({
    required this.focusedMonth,
    required this.selectedDay,
    required this.eventsForDay,
    required this.onMonthChanged,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateUtils.getDaysInMonth(focusedMonth.year, focusedMonth.month);
    final firstWeekday = DateTime(focusedMonth.year, focusedMonth.month, 1)
        .weekday; // 1=Mon … 7=Sun
    final leadingBlanks = firstWeekday % 7; // Sun=0, Mon=1, …

    final monthLabel =
        DateFormat('MMMM yyyy', 'id_ID').format(focusedMonth);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Month navigator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.teal),
                  onPressed: () => onMonthChanged(
                    DateTime(focusedMonth.year, focusedMonth.month - 1),
                  ),
                ),
                Text(
                  monthLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.teal),
                  onPressed: () => onMonthChanged(
                    DateTime(focusedMonth.year, focusedMonth.month + 1),
                  ),
                ),
              ],
            ),

            // Weekday headers
            Row(
              children: const ['M', 'S', 'R', 'K', 'J', 'S', 'M']
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 4),

            // Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                childAspectRatio: 1,
              ),
              itemCount: leadingBlanks + daysInMonth,
              itemBuilder: (context, index) {
                if (index < leadingBlanks) return const SizedBox.shrink();

                final day = index - leadingBlanks + 1;
                final date =
                    DateTime(focusedMonth.year, focusedMonth.month, day);
                final dayEvents = eventsForDay(date);
                final isSelected = selectedDay != null &&
                    DateUtils.isSameDay(date, selectedDay);
                final isToday = DateUtils.isSameDay(date, DateTime.now());

                return _DayCell(
                  date: date,
                  dayEvents: dayEvents,
                  isSelected: isSelected,
                  isToday: isToday,
                  onTap: () => onDaySelected(date),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final List<EventWithRegistration> dayEvents;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.dayEvents,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Pick the "highest priority" dot colour if multiple events on same day.
    // Priority: green > teal > yellow > red > grey
    CalendarDotColor? dominantColor;
    if (dayEvents.isNotEmpty) {
      const priority = [
        CalendarDotColor.green,
        CalendarDotColor.teal,
        CalendarDotColor.yellow,
        CalendarDotColor.red,
        CalendarDotColor.grey,
      ];
      for (final p in priority) {
        if (dayEvents.any((e) => e.dotColor == p)) {
          dominantColor = p;
          break;
        }
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.transparent,
          shape: BoxShape.circle,
          border: isToday && !isSelected
              ? Border.all(color: Colors.teal, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : isToday
                        ? Colors.teal
                        : Colors.black87,
              ),
            ),
            if (dominantColor != null)
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: _dotColorValue(dominantColor, isSelected),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _dotColorValue(CalendarDotColor c, bool onSelected) {
    if (onSelected) return Colors.white;
    switch (c) {
      case CalendarDotColor.teal:
        return Colors.teal;
      case CalendarDotColor.yellow:
        return Colors.amber;
      case CalendarDotColor.red:
        return Colors.red;
      case CalendarDotColor.green:
        return Colors.green;
      case CalendarDotColor.grey:
        return Colors.grey;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: const [
          _LegendItem(color: Colors.teal, label: 'Belum daftar'),
          _LegendItem(color: Colors.amber, label: 'Pending'),
          _LegendItem(color: Colors.green, label: 'Diterima'),
          _LegendItem(color: Colors.red, label: 'Ditolak/Dibatalkan'),
          _LegendItem(color: Colors.grey, label: 'Selesai'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CalendarEventCard extends StatelessWidget {
  final EventWithRegistration eventWithReg;

  const _CalendarEventCard({required this.eventWithReg});

  Color get _accentColor {
    switch (eventWithReg.dotColor) {
      case CalendarDotColor.teal:
        return Colors.teal;
      case CalendarDotColor.yellow:
        return Colors.amber;
      case CalendarDotColor.red:
        return Colors.red;
      case CalendarDotColor.green:
        return Colors.green;
      case CalendarDotColor.grey:
        return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (eventWithReg.dotColor) {
      case CalendarDotColor.teal:
        return 'Belum daftar';
      case CalendarDotColor.yellow:
        return 'Menunggu konfirmasi';
      case CalendarDotColor.red:
        return eventWithReg.event.status == 'cancelled'
            ? 'Event dibatalkan'
            : 'Pendaftaran ditolak';
      case CalendarDotColor.green:
        return 'Diterima';
      case CalendarDotColor.grey:
        return 'Selesai';
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = eventWithReg.event;
    final dateFormatter = DateFormat('d MMM yyyy', 'id_ID');

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
          border: Border(
            left: BorderSide(color: _accentColor, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Dot indicator
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 12, top: 2),
                decoration: BoxDecoration(
                  color: _accentColor,
                  shape: BoxShape.circle,
                ),
              ),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    if (event.genre != null)
                      Text(
                        event.genre!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.teal[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 11,
                          color: Colors.black45,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${dateFormatter.format(event.startAt)} – '
                          '${dateFormatter.format(event.endAt)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _accentColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: _accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EventDetailSheet(
        event: eventWithReg.event,
        getpostDiscsUseCase: serviceLocator(),
        getRepliesUseCase: serviceLocator(),
        postCommentUseCase: serviceLocator(),
        postReplyUseCase: serviceLocator(),
      ),
    );
  }
}
