import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:volync/features/event/domain/entity/post_disc.dart';
import 'package:volync/features/event/domain/entity/reply_post_disc.dart';
import 'package:volync/features/event/domain/usecase/get_post_disc_usecase.dart';

/// Preview strip shown at the bottom of each event card.
/// Shows the most recent postDisc and a tap-to-expand action.
class PostDiscPreview extends StatefulWidget {
  final String eventId;
  final GetPostDiscsUseCase getpostDiscsUseCase;
  final GetRepliesUseCase getRepliesUseCase;

  const PostDiscPreview({
    super.key,
    required this.eventId,
    required this.getpostDiscsUseCase,
    required this.getRepliesUseCase,
  });

  @override
  State<PostDiscPreview> createState() => _PostDiscPreviewState();
}

class _PostDiscPreviewState extends State<PostDiscPreview> {
  PostDiscEntity? _latestpostDisc;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchLatest();
  }

  Future<void> _fetchLatest() async {
    try {
      final postDiscs = await widget.getpostDiscsUseCase(
        eventId: widget.eventId,
        limit: 1,
      );
      if (mounted) {
        setState(() {
          _latestpostDisc = postDiscs.isNotEmpty ? postDiscs.first : null;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showAllpostDiscs(context),
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(8),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.comment_outlined, size: 16, color: Colors.black45),
            const SizedBox(width: 8),
            Expanded(
              child: _loading
                  ? const Text(
                      'Memuat komentar...',
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    )
                  : _latestpostDisc == null
                  ? const Text(
                      'Belum ada komentar. Jadilah yang pertama!',
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    )
                  : RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${_latestpostDisc!.userName}: ',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextSpan(
                            text: _latestpostDisc!.content,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  void _showAllpostDiscs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PostDiscSheet(
        eventId: widget.eventId,
        getpostDiscsUseCase: widget.getpostDiscsUseCase,
        getRepliesUseCase: widget.getRepliesUseCase,
      ),
    );
  }
}

// ── Full postDisc sheet ────────────────────────────────────────────────────────

class _PostDiscSheet extends StatefulWidget {
  final String eventId;
  final GetPostDiscsUseCase getpostDiscsUseCase;
  final GetRepliesUseCase getRepliesUseCase;

  const _PostDiscSheet({
    required this.eventId,
    required this.getpostDiscsUseCase,
    required this.getRepliesUseCase,
  });

  @override
  State<_PostDiscSheet> createState() => _PostDiscSheetState();
}

class _PostDiscSheetState extends State<_PostDiscSheet> {
  final List<PostDiscEntity> _postDiscs = [];
  bool _loading = true;
  bool _hasMore = true;
  int _offset = 0;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (!_hasMore) return;
    setState(() => _loading = true);

    try {
      final fetched = await widget.getpostDiscsUseCase(
        eventId: widget.eventId,
        limit: _pageSize,
        offset: _offset,
      );
      setState(() {
        _postDiscs.addAll(fetched);
        _offset += fetched.length;
        _hasMore = fetched.length == _pageSize;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // handle + title
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Komentar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 20),
                  ],
                ),
              ),

              Expanded(
                child: _loading && _postDiscs.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.teal),
                      )
                    : _postDiscs.isEmpty
                    ? const Center(child: Text('Belum ada komentar.'))
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: _postDiscs.length + (_hasMore ? 1 : 0),
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          if (index == _postDiscs.length) {
                            return _loading
                                ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.teal,
                                      ),
                                    ),
                                  )
                                : TextButton(
                                    onPressed: _loadMore,
                                    child: const Text(
                                      'Muat lebih banyak',
                                      style: TextStyle(color: Colors.teal),
                                    ),
                                  );
                          }
                          return _PostDiscTile(
                            postDisc: _postDiscs[index],
                            getRepliesUseCase: widget.getRepliesUseCase,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Single postDisc tile with reply expansion ──────────────────────────────────

class _PostDiscTile extends StatefulWidget {
  final PostDiscEntity postDisc;
  final GetRepliesUseCase getRepliesUseCase;

  const _PostDiscTile({
    required this.postDisc,
    required this.getRepliesUseCase,
  });

  @override
  State<_PostDiscTile> createState() => _PostDiscTileState();
}

class _PostDiscTileState extends State<_PostDiscTile> {
  List<ReplyPostDiscEntity> _replies = [];
  bool _showReplies = false;
  bool _loadingReplies = false;

  final _timeFormat = DateFormat('d MMM, HH:mm', 'id_ID');

  Future<void> _toggleReplies() async {
    if (_showReplies) {
      setState(() => _showReplies = false);
      return;
    }
    if (_replies.isEmpty) {
      setState(() => _loadingReplies = true);
      try {
        final fetched = await widget.getRepliesUseCase(
          parentCommentId: widget.postDisc.id,
        );
        setState(() {
          _replies = fetched;
          _loadingReplies = false;
          _showReplies = true;
        });
      } catch (_) {
        setState(() => _loadingReplies = false);
      }
    } else {
      setState(() => _showReplies = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + name + time
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.teal.withAlpha(40),
                backgroundImage: widget.postDisc.userAvatarUrl != null
                    ? NetworkImage(widget.postDisc.userAvatarUrl!)
                    : null,
                child: widget.postDisc.userAvatarUrl == null
                    ? Text(
                        widget.postDisc.userName[0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.teal[700],
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.postDisc.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _timeFormat.format(widget.postDisc.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // postDisc content
          Text(
            widget.postDisc.content,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 6),

          // Reply toggle
          GestureDetector(
            onTap: _toggleReplies,
            child: _loadingReplies
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.teal,
                    ),
                  )
                : Text(
                    _showReplies ? 'Sembunyikan balasan' : 'Lihat balasan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.teal[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),

          // Replies
          if (_showReplies && _replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 28, top: 8),
              child: Column(
                children: _replies
                    .map(
                      (reply) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.grey.withAlpha(40),
                              backgroundImage: reply.userAvatarUrl != null
                                  ? NetworkImage(reply.userAvatarUrl!)
                                  : null,
                              child: reply.userAvatarUrl == null
                                  ? Text(
                                      (reply.userName ?? 'A')[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reply.userName ?? 'Anonymous',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    reply.body,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    _timeFormat.format(reply.createdAt),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
