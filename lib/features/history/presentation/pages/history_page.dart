import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:volync/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:volync/core/theme/app_pallete.dart';
import 'package:volync/features/event/domain/entity/event.dart';
import 'package:volync/features/event/domain/usecase/get_post_disc_usecase.dart';
import 'package:volync/features/event/presentation/bloc/event_bloc.dart';
import 'package:volync/features/event/presentation/widgets/event_detail_sheet.dart';
import 'package:volync/features/history/domain/entity/user_registration_entity.dart';
import 'package:volync/features/history/domain/entity/user_post_entity.dart';
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

  // In-memory caches – items are only fetched from DB when not already present.
  final List<UserRegistrationEntity> _registrations = [];
  final List<UserPostEntity> _posts = [];

  // Track which tab has ever been loaded so we don't re-fetch unnecessarily.
  bool _registrationsLoaded = false;
  bool _postsLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureRegistrationsLoaded();
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _onTabChanged();
    });
  }

  void _onTabChanged() {
    if (_tabController.index == 0) {
      _ensureRegistrationsLoaded();
    } else {
      _ensurePostsLoaded();
    }
  }

  /// Fetches registrations from DB only when the local cache is empty.
  void _ensureRegistrationsLoaded() {
    if (_registrationsLoaded && _registrations.isNotEmpty) return;
    final userId = _currentUserId();
    if (userId == null) return;
    context.read<HistoryBloc>().add(HistoryLoadRegistrations(userId: userId));
  }

  /// Fetches posts from DB only when the local cache is empty.
  void _ensurePostsLoaded() {
    if (_postsLoaded && _posts.isNotEmpty) return;
    final userId = _currentUserId();
    if (userId == null) return;
    context.read<HistoryBloc>().add(HistoryLoadPosts(userId: userId));
  }

  /// Force-refresh the currently visible tab from DB regardless of cache.
  void _forceRefreshCurrentTab() {
    final userId = _currentUserId();
    if (userId == null) return;
    if (_tabController.index == 0) {
      _registrationsLoaded = false;
      context
          .read<HistoryBloc>()
          .add(HistoryLoadRegistrations(userId: userId));
    } else {
      _postsLoaded = false;
      context.read<HistoryBloc>().add(HistoryLoadPosts(userId: userId));
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
            // ── Header ──────────────────────────────────────────────
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
                    onPressed: _forceRefreshCurrentTab,
                    tooltip: 'Muat ulang',
                  ),
                ],
              ),
            ),

            // ── Tab bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppPallete.whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppPallete.blackColor.withOpacity(0.06),
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
                  labelColor: AppPallete.whiteColor,
                  unselectedLabelColor: AppPallete.borderColor,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  dividerColor: AppPallete.transparentColor,
                  tabs: const [
                    Tab(text: 'Pendaftaran'),
                    Tab(text: 'Diskusi'),
                  ],
                ),
              ),
            ),

            // ── Tab views ───────────────────────────────────────────
            Expanded(
              child: BlocConsumer<HistoryBloc, HistoryState>(
                listener: (context, state) {
                  if (state is HistoryActionSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppPallete.focusedColor,
                      ),
                    );
                  } else if (state is HistoryFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppPallete.errorColor,
                      ),
                    );
                  } else if (state is HistoryRegistrationsLoaded) {
                    // Merge: add only items not already in cache (by id).
                    final existingIds = _registrations.map((r) => r.id).toSet();
                    final newItems = state.registrations
                        .where((r) => !existingIds.contains(r.id))
                        .toList();
                    setState(() {
                      _registrations
                        ..clear() // full refresh keeps list in sync with DB order
                        ..addAll(state.registrations);
                      _registrationsLoaded = true;
                    });
                  } else if (state is HistoryPostsLoaded) {
                    setState(() {
                      _posts
                        ..clear()
                        ..addAll(state.posts);
                      _postsLoaded = true;
                    });
                  }
                },
                builder: (context, state) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _RegistrationsTab(
                        registrations: _registrations,
                        isLoading: state is HistoryLoading &&
                            _tabController.index == 0,
                        onCancel: (reg) => _confirmCancel(context, reg),
                        onTap: (reg) => _openEventDetail(context, reg),
                        onRefresh: () async {
                          final userId = _currentUserId();
                          if (userId != null) {
                            _registrationsLoaded = false;
                            context.read<HistoryBloc>().add(
                              HistoryLoadRegistrations(userId: userId),
                            );
                          }
                        },
                      ),
                      _PostsTab(
                        posts: _posts,
                        isLoading: state is HistoryLoading &&
                            _tabController.index == 1,
                        onTap: (eventId, postId) =>
                            _openEventDetailById(context, eventId),
                        onRefresh: () async {
                          final userId = _currentUserId();
                          if (userId != null) {
                            _postsLoaded = false;
                            context
                                .read<HistoryBloc>()
                                .add(HistoryLoadPosts(userId: userId));
                          }
                        },
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
            child: Text(
              'Tidak',
              style: TextStyle(color: AppPallete.focusedColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.errorColor,
            ),
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
              style: TextStyle(color: AppPallete.whiteColor),
            ),
          ),
        ],
      ),
    );
  }

  void _openEventDetail(BuildContext context, UserRegistrationEntity reg) {
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
    // 1. Check in-memory registration cache first
    for (final reg in _registrations) {
      if (reg.eventId == eventId) {
        _openEventDetail(context, reg);
        return;
      }
    }

    // 2. Check in-memory posts cache for image/title metadata
    final matchingPost = _posts.where((p) => p.eventId == eventId).toList();

    // 3. Check EventBloc cache
    final currentState = context.read<EventBloc>().state;
    if (currentState is EventLoaded) {
      final match = currentState.events.where((e) => e.id == eventId).toList();
      if (match.isNotEmpty) {
        _showDetailSheet(context, match.first);
        return;
      }
    }

    // 4. Not found in any cache — trigger a DB fetch and notify the user
    context.read<EventBloc>().add(LoadEvents(reset: true));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Memuat kegiatan dari server...'),
        backgroundColor: AppPallete.focusedColor,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, EventEntity event) {
    final eventBloc = context.read<EventBloc>();
    eventBloc.add(ResetEventState());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppPallete.transparentColor,
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
  final List<UserRegistrationEntity> registrations;
  final bool isLoading;
  final void Function(UserRegistrationEntity) onCancel;
  final void Function(UserRegistrationEntity) onTap;
  final Future<void> Function() onRefresh;

  const _RegistrationsTab({
    required this.registrations,
    required this.isLoading,
    required this.onCancel,
    required this.onTap,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && registrations.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: AppPallete.focusedColor),
      );
    }

    if (registrations.isEmpty) {
      return _EmptyState(
        icon: Icons.event_busy_outlined,
        message: 'Belum ada pendaftaran kegiatan',
      );
    }

    return RefreshIndicator(
      color: AppPallete.focusedColor,
      onRefresh: onRefresh,
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
}

// ── Posts tab ──────────────────────────────────────────────────────────────────
class _PostsTab extends StatelessWidget {
  final List<UserPostEntity> posts;
  final bool isLoading;
  final void Function(int eventId, String postId) onTap;
  final Future<void> Function() onRefresh;

  const _PostsTab({
    required this.posts,
    required this.isLoading,
    required this.onTap,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && posts.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: AppPallete.focusedColor),
      );
    }

    if (posts.isEmpty) {
      return _EmptyState(
        icon: Icons.chat_bubble_outline_rounded,
        message: 'Belum ada diskusi atau balasan',
      );
    }

    return RefreshIndicator(
      color: AppPallete.focusedColor,
      onRefresh: onRefresh,
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
          Icon(icon, size: 64, color: AppPallete.borderColor),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: AppPallete.borderColor, fontSize: 14),
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
            Icon(Icons.error_outline, size: 48, color: AppPallete.errorColor),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppPallete.errorColor),
            ),
          ],
        ),
      ),
    );
  }
}
