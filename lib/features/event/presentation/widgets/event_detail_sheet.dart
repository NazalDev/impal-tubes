import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volync/features/event/domain/entity/event.dart';
import 'package:volync/features/event/domain/usecase/get_post_disc_usecase.dart';
import 'package:volync/features/event/presentation/bloc/event_bloc.dart';
import 'package:volync/features/event/presentation/widgets/post_disc_section.dart';

class EventDetailSheet extends StatelessWidget {
  final EventEntity event;
  final GetPostDiscsUseCase getpostDiscsUseCase;
  final GetRepliesUseCase getRepliesUseCase;
  final PostCommentUseCase postCommentUseCase;
  final PostReplyUseCase postReplyUseCase;

  const EventDetailSheet({
    super.key,
    required this.event,
    required this.getpostDiscsUseCase,
    required this.getRepliesUseCase,
    required this.postCommentUseCase,
    required this.postReplyUseCase,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('EEEE, d MMMM yyyy – HH:mm', 'id_ID');

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const _DragHandle(),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (event.imageUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            event.imageUrl!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('IMAGE ERROR: $error');
                              return Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey[400],
                                  size: 48,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.teal,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event.status,
                          style: TextStyle(
                            color: Colors.teal[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        text: event.location,
                      ),
                      const SizedBox(height: 6),
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        text: formatter.format(event.startAt),
                      ),
                      const SizedBox(height: 6),
                      _InfoRow(
                        icon: Icons.flag_outlined,
                        text: 'Selesai ${formatter.format(event.endAt)}',
                      ),
                      const Divider(height: 32),

                      const Text(
                        'Tentang Event',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Discussion / Comments section ──────────
                      const Text(
                        'Diskusi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      PostDiscPreview(
                        eventId: event.id,
                        getpostDiscsUseCase: getpostDiscsUseCase,
                        getRepliesUseCase: getRepliesUseCase,
                        postCommentUseCase: postCommentUseCase,
                        postReplyUseCase: postReplyUseCase,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              _DaftarBottomBar(event: event),
            ],
          ),
        );
      },
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.teal[700]),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}

class _DaftarBottomBar extends StatelessWidget {
  final EventEntity event;

  const _DaftarBottomBar({required this.event});

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventBloc, EventBlocState>(
      listenWhen: (_, current) =>
          current is EventRegistering ||
          current is EventRegistered ||
          current is EventAlreadyRegistered ||
          current is EventRegisterError,
      listener: (context, state) {
        if (state is EventRegistered) {
          context.read<EventBloc>().add(LoadEvents(reset: true));
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berhasil mendaftar ke ${event.title}!'),
              backgroundColor: Colors.teal,
            ),
          );
        } else if (state is EventAlreadyRegistered) {
          // Do NOT close the sheet — just show the snackbar.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kamu sudah mendaftar ke event ini'),
              backgroundColor: Colors.orange,
            ),
          );
        } else if (state is EventRegisterError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red[700],
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: BlocBuilder<EventBloc, EventBlocState>(
          buildWhen: (_, current) =>
              current is EventRegistering ||
              current is EventRegistered ||
              current is EventAlreadyRegistered ||
              current is EventRegisterError ||
              current is EventLoaded ||
              current is EventInitial,
          builder: (context, state) {
            final isLoading = state is EventRegistering;
            final user = Supabase.instance.client.auth.currentUser;

            return SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Sesi berakhir, silakan login kembali.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        context.read<EventBloc>().add(
                          RegisterEvent(eventId: event.id, userId: user.id),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Daftar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
