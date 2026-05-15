import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:volync/features/event/domain/entity/event.dart';
import 'package:volync/features/event/domain/usecase/get_post_disc_usecase.dart';

import 'package:volync/features/event/presentation/widgets/event_detail_sheet.dart';
import 'package:volync/features/event/presentation/widgets/post_disc_section.dart';

class EventCard extends StatelessWidget {
  final EventEntity event;
  final GetPostDiscsUseCase getpostDiscsUseCase;
  final GetRepliesUseCase getRepliesUseCase;

  const EventCard({
    super.key,
    required this.event,
    required this.getpostDiscsUseCase,
    required this.getRepliesUseCase,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('d MMM yyyy, HH:mm', 'id_ID');

    return InkWell(
      onTap: () => EventDetailSheet.show(context, event),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              spreadRadius: 1,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Main card row ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: text info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status chip
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal.withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            event.status,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.teal[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Title
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Location
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: Colors.black45,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                event.location,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),

                        // Date
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: Colors.black45,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              formatter.format(event.startAt),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Right: image OR daftar button
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: event.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              event.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _DaftarButton(event: event),
                            ),
                          )
                        : _DaftarButton(event: event),
                  ),
                ],
              ),
            ),

            // ── postDisc preview strip ──────────────────────────
            PostDiscPreview(
              eventId: event.userId, // replace with event.id when available
              getpostDiscsUseCase: getpostDiscsUseCase,
              getRepliesUseCase: getRepliesUseCase,
            ),
          ],
        ),
      ),
    );
  }
}

class _DaftarButton extends StatelessWidget {
  final EventEntity event;

  const _DaftarButton({required this.event});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => EventDetailSheet.show(context, event),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.zero,
      ),
      child: const Text(
        'Daftar',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
