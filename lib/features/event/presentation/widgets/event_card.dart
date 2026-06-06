import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:volync/core/theme/app_pallete.dart';
import 'package:volync/features/event/domain/entity/event.dart';
import 'package:volync/features/event/domain/usecase/get_post_disc_usecase.dart';
import 'package:volync/features/event/presentation/bloc/event_bloc.dart';
import 'package:volync/features/event/presentation/widgets/event_detail_sheet.dart';
import 'package:volync/features/event/presentation/widgets/post_disc_section.dart';
import 'package:volync/features/report/presentation/bloc/report_bloc.dart';
import 'package:volync/features/report/presentation/widgets/report_dialog.dart';
import 'package:volync/init_dependencies.dart';

class EventCard extends StatelessWidget {
  final EventEntity event;
  final GetPostDiscsUseCase getpostDiscsUseCase;
  final GetRepliesUseCase getRepliesUseCase;
  final PostCommentUseCase postCommentUseCase;
  final PostReplyUseCase postReplyUseCase;

  const EventCard({
    super.key,
    required this.event,
    required this.getpostDiscsUseCase,
    required this.getRepliesUseCase,
    required this.postCommentUseCase,
    required this.postReplyUseCase,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('d MMM yyyy, HH:mm', 'id_ID');

    return InkWell(
      onTap: () => _openDetail(context),
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
                            color: event.status == 'cancelled'
                                ? AppPallete.errorColor.withAlpha(25)
                                : AppPallete.focusedColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            event.status,
                            style: TextStyle(
                              fontSize: 11,
                              color: event.status == 'cancelled'
                                  ? AppPallete.errorColor
                                  : AppPallete.focusedColor,
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

                  // Right: 3-dots menu + image OR daftar button
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 3-dots menu
                      BlocProvider.value(
                        value: serviceLocator<ReportBloc>(),
                        child: Builder(
                          builder: (ctx) => GestureDetector(
                            onTapDown: (details) => _showEventCardMenu(
                              ctx,
                              details.globalPosition,
                              event,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Icon(
                                Icons.more_vert,
                                size: 18,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        height: 88,
                        child: event.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  event.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('CARD IMAGE ERROR: $error');
                                    return _DaftarButton(
                                      onTap: () => _openDetail(context),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.teal,
                                            ),
                                          ),
                                        );
                                      },
                                ),
                              )
                            : _DaftarButton(onTap: () => _openDetail(context)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── postDisc preview strip ──────────────────────────
            PostDiscPreview(
              eventId: event.id,
              getpostDiscsUseCase: getpostDiscsUseCase,
              getRepliesUseCase: getRepliesUseCase,
              postCommentUseCase: postCommentUseCase,
              postReplyUseCase: postReplyUseCase,
            ),
          ],
        ),
      ),
    );
  }

  // Centralized open detail — context here always has EventBloc from the list
  void _openDetail(BuildContext context) {
    final bloc = context.read<EventBloc>();

    bloc.add(ResetEventState());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: EventDetailSheet(
          event: event,
          getpostDiscsUseCase: getpostDiscsUseCase,
          getRepliesUseCase: getRepliesUseCase,
          postCommentUseCase: postCommentUseCase,
          postReplyUseCase: postReplyUseCase,
        ),
      ),
    );
  }

  void _showEventCardMenu(
    BuildContext context,
    Offset position,
    EventEntity event,
  ) async {
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: const [
        PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              Icon(Icons.flag_outlined, color: Colors.red, size: 18),
              SizedBox(width: 8),
              Text('Laporkan Event', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
    if (result == 'report' && context.mounted) {
      showReportDialog(
        context,
        reportedEventId: event.id.toString(),
        targetName: event.title,
      );
    }
  }
}

class _DaftarButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DaftarButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap, // ← uses the callback instead of reading context
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
