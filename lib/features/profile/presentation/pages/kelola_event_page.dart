import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:volync/core/theme/app_pallete.dart';
import 'package:volync/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:volync/features/profile/presentation/pages/event_report_page.dart';
import 'package:volync/features/profile/presentation/pages/manage_members_page.dart';
import 'package:volync/features/profile/presentation/widgets/manage_event_card.dart';

class KelolaEventPage extends StatefulWidget {
  final String userId;

  const KelolaEventPage({super.key, required this.userId});

  @override
  State<KelolaEventPage> createState() => _KelolaEventPageState();
}

class _KelolaEventPageState extends State<KelolaEventPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(
      ProfileLoadUserEvents(userId: widget.userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppPallete.cardBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kelola Event',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppPallete.errorColor,
              ),
            );
          }
          if (state is ProfileActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Reload list after any action
            context.read<ProfileBloc>().add(
              ProfileLoadUserEvents(userId: widget.userId),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileUserEventsLoaded) {
            if (state.events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy_outlined,
                      size: 72,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada event yang dibuat',
                      style: TextStyle(fontSize: 15, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.events.length,
              itemBuilder: (context, index) {
                final event = state.events[index];
                return ManageEventCard(
                  event: event,
                  onEdit: () => _showEditDialog(context, event),
                  onDelete: () => _confirmDelete(context, event.id),
                  onReport: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ProfileBloc>(),
                        child: EventReportPage(event: event),
                      ),
                    ),
                  ),
                  onManageMembers: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<ProfileBloc>(),
                          child: ManageMembersPage(event: event),
                        ),
                      ),
                    );
                    // Reload after returning so the list stays fresh
                    if (context.mounted) {
                      context.read<ProfileBloc>().add(
                        ProfileLoadUserEvents(userId: widget.userId),
                      );
                    }
                  },
                  onCancel: () => _confirmCancel(context, event.id),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String eventId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Event'),
        content: const Text(
          'Yakin ingin menghapus event ini? Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProfileBloc>().add(
                ProfileDeleteEvent(eventId: eventId),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context, String eventId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Event'),
        content: const Text(
          'Yakin ingin membatalkan event ini? Status tidak dapat dikembalikan ke Published.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProfileBloc>().add(
                ProfileCancelEvent(eventId: eventId),
              );
            },
            child: const Text(
              'Batalkan Event',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext ctx, dynamic event) {
    final titleController = TextEditingController(text: event.title);
    final descController = TextEditingController(text: event.description);
    final locationController = TextEditingController(text: event.location);

    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Edit Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.buttonColor,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              ctx.read<ProfileBloc>().add(
                ProfileUpdateEvent(
                  eventId: event.id,
                  data: {
                    'title': titleController.text.trim(),
                    'description': descController.text.trim(),
                    'location': locationController.text.trim(),
                  },
                ),
              );
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
