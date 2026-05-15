import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:volync/core/theme/app_pallete.dart';
import 'package:volync/features/profile/domain/entity/profile_event_entity.dart';
import 'package:volync/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:volync/features/profile/presentation/widgets/member_list_tile.dart';

class ManageMembersPage extends StatefulWidget {
  final ProfileEventEntity event;

  const ManageMembersPage({super.key, required this.event});

  @override
  State<ManageMembersPage> createState() => _ManageMembersPageState();
}

class _ManageMembersPageState extends State<ManageMembersPage> {
  String _filter = 'all'; // 'all' | 'pending' | 'approved' | 'rejected'

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(
      ProfileLoadEventMembers(eventId: widget.event.id),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kelola Anggota',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.event.title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: AppPallete.cardBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Semua',
                    isSelected: _filter == 'all',
                    onTap: () => setState(() => _filter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Menunggu',
                    isSelected: _filter == 'pending',
                    onTap: () => setState(() => _filter = 'pending'),
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Disetujui',
                    isSelected: _filter == 'approved',
                    onTap: () => setState(() => _filter = 'approved'),
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Ditolak',
                    isSelected: _filter == 'rejected',
                    onTap: () => setState(() => _filter = 'rejected'),
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: BlocConsumer<ProfileBloc, ProfileState>(
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
                }
              },
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is ProfileEventMembersLoaded) {
                  final filtered = _filter == 'all'
                      ? state.members
                      : state.members
                            .where((m) => m.status == _filter)
                            .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tidak ada anggota',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final member = filtered[index];
                      return MemberListTile(
                        member: member,
                        onApprove: () => _confirmAction(
                          context,
                          title: 'Setujui Anggota',
                          content:
                              'Setujui ${member.username} untuk bergabung ke event ini?',
                          confirmLabel: 'Setujui',
                          confirmColor: Colors.green,
                          onConfirm: () => context.read<ProfileBloc>().add(
                            ProfileApproveMember(
                              registrationId: member.id,
                              eventId: widget.event.id,
                            ),
                          ),
                        ),
                        onReject: () => _confirmAction(
                          context,
                          title: 'Tolak Anggota',
                          content:
                              'Tolak pendaftaran ${member.username} dari event ini?',
                          confirmLabel: 'Tolak',
                          confirmColor: Colors.red,
                          onConfirm: () => context.read<ProfileBloc>().add(
                            ProfileRejectMember(
                              registrationId: member.id,
                              eventId: widget.event.id,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmAction(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: Text(confirmLabel, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color = Colors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade400,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
