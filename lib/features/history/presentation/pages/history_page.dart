import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:volync/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:volync/core/theme/app_pallete.dart';
import 'package:volync/features/event/domain/entity/event.dart';
import 'package:volync/features/event/domain/usecase/get_post_disc_usecase.dart';
import 'package:volync/features/event/presentation/bloc/event_bloc.dart';
import 'package:volync/features/event/presentation/widgets/event_detail_sheet.dart';
import 'package:volync/features/history/domain/entity/user_registration_entity.dart';
import 'package:volync/features/history/presentation/bloc/history_bloc.dart';
import 'package:volync/features/history/presentation/widgets/post_history_card.dart';
import 'package:volync/features/history/presentation/widgets/registration_history_card.dart';
import 'package:volync/init_dependencies.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = _currentUserId();
      if (userId == null) return;
      // Only load the first tab initially
      context.read<HistoryBloc>().add(HistoryLoadRegistrations(userId: userId));
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _onTabChanged();
    });
  }

  void _onTabChanged() {
    final userId = _currentUserId();
    if (userId == null) return;
    final bloc = context.read<HistoryBloc>();
    if (_tabController.index == 0) {
      bloc.add(HistoryLoadRegistrations(userId: userId));
    } else {
      bloc.add(HistoryLoadPosts(userId: userId));
    }
  }

  String? _currentUserId() {
    final state = context.read<AppUserCubit>().state;
    if (state is AppUserLoggedIn) return state.user.id;
    return null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  const Text(
                    'Riwayat',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppPallete.blackColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    color: AppPallete.focusedColor,
                    onPressed: _onTabChanged,
                    tooltip: 'Muat ulang',
                  ),
                ],
              ),
            ),

            // ── Tab bar ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppPallete.focusedColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[600],
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Pendaftaran'),
                    Tab(text: 'Diskusi'),
                  ],
                ),
              ),
            ),

            // ── Tab views ─────────────────────────────────────────
            Expanded(
              child: BlocConsumer<HistoryBloc, HistoryState>(
                listener: (context, state) {
                  if (state is HistoryActionSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.teal,
                      ),
                    );
                  } else if (state is HistoryFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red[700],
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _RegistrationsTab(
                        state: state,
                        onCancel: (reg) => _confirmCancel(context, reg),
                        onTap: (reg) => _openEventDetail(context, reg),
                      ),
                      _PostsTab(
                        state: state,
                        onTap: (eventId, postId) =>
                            _openEventDetailById(context, eventId),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, UserRegistrationEntity reg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Pendaftaran'),
        content: Text(
          'Apakah kamu yakin ingin membatalkan pendaftaran untuk "${reg.eventTitle}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              final userId = _currentUserId();
              if (userId == null) return;
              context.read<HistoryBloc>().add(
                HistoryCancelRegistration(
                  registrationId: reg.id,
                  userId: userId,
                ),
              );
            },
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _openEventDetail(BuildContext context, UserRegistrationEntity reg) {
    // Build a minimal EventEntity from registration data to open the detail sheet
    final event = EventEntity(
      id: reg.eventId,
      userId: '',
      title: reg.eventTitle,
      description: reg.eventDescription,
      location: reg.eventLocation,
      status: reg.eventStatus,
      startAt: reg.eventStartAt,
      endAt: reg.eventEndAt,
      imageUrl: reg.eventImageUrl,
      genre: reg.eventGenre,
    );
    _showDetailSheet(context, event);
  }

  void _openEventDetailById(BuildContext context, int eventId) {
    // Navigate and fetch the event by ID via EventBloc then open sheet
    // We load events and find the one with matching id
    final currentState = context.read<EventBloc>().state;
    if (currentState is EventLoaded) {
      final match = currentState.events.where((e) => e.id == eventId).toList();
      if (match.isNotEmpty) {
        _showDetailSheet(context, match.first);
        return;
      }
    }
    // If not in cache, load events then try again
    context.read<EventBloc>().add(LoadEvents(reset: true));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Membuka kegiatan...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, EventEntity event) {
    final eventBloc = context.read<EventBloc>();
    eventBloc.add(ResetEventState());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: eventBloc,
        child: EventDetailSheet(
          event: event,
          getpostDiscsUseCase: serviceLocator<GetPostDiscsUseCase>(),
          getRepliesUseCase: serviceLocator<GetRepliesUseCase>(),
          postCommentUseCase: serviceLocator<PostCommentUseCase>(),
          postReplyUseCase: serviceLocator<PostReplyUseCase>(),
        ),
      ),
    );
  }
}

// ── Registrations tab ──────────────────────────────────────────────────────────
class _RegistrationsTab extends StatelessWidget {
  final HistoryState state;
  final void Function(UserRegistrationEntity) onCancel;
  final void Function(UserRegistrationEntity) onTap;

  const _RegistrationsTab({
    required this.state,
    required this.onCancel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (state is HistoryLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.teal));
    }

    if (state is HistoryRegistrationsLoaded) {
      final registrations = (state as HistoryRegistrationsLoaded).registrations;
      if (registrations.isEmpty) {
        return _EmptyState(
          icon: Icons.event_busy_outlined,
          message: 'Belum ada pendaftaran kegiatan',
        );
      }
      return RefreshIndicator(
        color: Colors.teal,
        onRefresh: () async {
          final userId =
              (context.read<AppUserCubit>().state as AppUserLoggedIn?)?.user.id;
          if (userId != null) {
            context.read<HistoryBloc>().add(
              HistoryLoadRegistrations(userId: userId),
            );
          }
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: registrations.length,
          itemBuilder: (context, index) {
            final reg = registrations[index];
            return RegistrationHistoryCard(
              registration: reg,
              onTap: () => onTap(reg),
              onCancel: (reg.status == 'pending' || reg.status == 'approved')
                  ? () => onCancel(reg)
                  : null,
            );
          },
        ),
      );
    }

    if (state is HistoryFailure) {
      return _ErrorState(message: (state as HistoryFailure).message);
    }

    return const SizedBox.shrink();
  }
}

// ── Posts tab ──────────────────────────────────────────────────────────────────
class _PostsTab extends StatelessWidget {
  final HistoryState state;
  final void Function(int eventId, String postId) onTap;

  const _PostsTab({required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (state is HistoryLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.teal));
    }

    if (state is HistoryPostsLoaded) {
      final posts = (state as HistoryPostsLoaded).posts;
      if (posts.isEmpty) {
        return _EmptyState(
          icon: Icons.chat_bubble_outline_rounded,
          message: 'Belum ada diskusi atau balasan',
        );
      }
      return RefreshIndicator(
        color: Colors.teal,
        onRefresh: () async {
          final userId =
              (context.read<AppUserCubit>().state as AppUserLoggedIn?)?.user.id;
          if (userId != null) {
            context.read<HistoryBloc>().add(HistoryLoadPosts(userId: userId));
          }
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostHistoryCard(
              post: post,
              onTap: () => onTap(post.eventId, post.id),
            );
          },
        ),
      );
    }

    if (state is HistoryFailure) {
      return _ErrorState(message: (state as HistoryFailure).message);
    }

    return const SizedBox.shrink();
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
