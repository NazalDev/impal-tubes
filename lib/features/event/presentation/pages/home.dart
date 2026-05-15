import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:volync/features/event/event_injector.dart';
import 'package:volync/features/event/presentation/bloc/event_bloc.dart';
import 'package:volync/features/event/presentation/widgets/event_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the BLoC to the subtree
    return BlocProvider(
      create: (_) => EventInjector.eventBloc()..add(LoadEvents(reset: true)),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _searchController = TextEditingController();

  static const _filters = ['Semua', 'Seminar', 'Penggalangan Dana', 'Konser'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 246, 243),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          spacing: 24,
          children: [
            Image.asset(
              'lib/assets/images/volync_logo.png',
              width: 200,
              height: 200,
              fit: BoxFit.fitHeight,
            ),

            // ── Search bar ──────────────────────────────────────
            TextField(
              controller: _searchController,
              onChanged: (value) =>
                  context.read<EventBloc>().add(SearchEvents(value)),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.black38,
                  size: 28,
                ),
                hintText: 'Cari Event Kampus...',
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide(color: Colors.teal[700]!, width: 2),
                ),
              ),
            ),

            // ── Filter chips ────────────────────────────────────
            BlocBuilder<EventBloc, EventBlocState>(
              buildWhen: (prev, curr) =>
                  curr is EventLoaded &&
                  (prev is! EventLoaded ||
                      prev.activeFilter != curr.activeFilter),
              builder: (context, state) {
                final active = state is EventLoaded
                    ? state.activeFilter
                    : 'Semua';
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 8,
                    children: _filters.map((filter) {
                      final isActive = filter == active;
                      return FilterChip(
                        label: Text(filter),
                        selected: isActive,
                        onSelected: (_) =>
                            context.read<EventBloc>().add(FilterEvents(filter)),
                        selectedColor: Colors.teal,
                        labelStyle: TextStyle(
                          color: isActive ? Colors.white : Colors.black87,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        checkmarkColor: Colors.white,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: isActive ? Colors.teal : Colors.black26,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),

            // ── Event list ──────────────────────────────────────
            Expanded(
              child: BlocBuilder<EventBloc, EventBlocState>(
                builder: (context, state) {
                  if (state is EventLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.teal),
                    );
                  }

                  if (state is EventError) {
                    return Center(child: Text(state.message));
                  }

                  if (state is EventLoaded) {
                    if (state.events.isEmpty) {
                      return const Center(
                        child: Text('Tidak ada event tersedia.'),
                      );
                    }

                    return ListView.separated(
                      itemCount: state.events.length + (state.hasMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        if (index == state.events.length) {
                          return Center(
                            child: TextButton(
                              onPressed: () =>
                                  context.read<EventBloc>().add(LoadEvents()),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.teal[700],
                              ),
                              child: const Text(
                                'Lihat Lebih Banyak',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        }

                        return EventCard(
                          event: state.events[index],
                          getRepliesUseCase: EventInjector.getRepliesUseCase,
                          getpostDiscsUseCase: EventInjector.getCommentsUseCase,
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
      ),
    );
  }
}
