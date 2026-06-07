import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:volync/features/event/domain/entity/post_disc.dart';
import 'package:volync/features/event/domain/entity/reply_post_disc.dart';
import 'package:volync/features/event/domain/usecase/get_post_disc_usecase.dart';
import 'package:volync/features/report/presentation/bloc/report_bloc.dart';
import 'package:volync/features/report/presentation/widgets/report_dialog.dart';
import 'package:volync/init_dependencies.dart';

/// Preview strip shown at the bottom of each event card.
/// Shows the most recent postDisc and a tap-to-expand action.
class PostDiscPreview extends StatefulWidget {
  final int eventId;
  final GetPostDiscsUseCase getpostDiscsUseCase;
  final GetRepliesUseCase getRepliesUseCase;
  final PostCommentUseCase postCommentUseCase;
  final PostReplyUseCase postReplyUseCase;

  const PostDiscPreview({
    super.key,
    required this.eventId,
    required this.getpostDiscsUseCase,
    required this.getRepliesUseCase,
    required this.postCommentUseCase,
    required this.postReplyUseCase,
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
    } catch (e, st) {
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
                            text: _latestpostDisc!.body,
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
        postCommentUseCase: widget.postCommentUseCase,
        postReplyUseCase: widget.postReplyUseCase,
        onNewComment: (newComment) {
          setState(() => _latestpostDisc = newComment);
        },
      ),
    );
  }
}

// ── Full postDisc sheet ────────────────────────────────────────────────────────

class _PostDiscSheet extends StatefulWidget {
  final int eventId;
  final GetPostDiscsUseCase getpostDiscsUseCase;
  final GetRepliesUseCase getRepliesUseCase;
  final PostCommentUseCase postCommentUseCase;
  final PostReplyUseCase postReplyUseCase;
  final void Function(PostDiscEntity)? onNewComment;

  const _PostDiscSheet({
    required this.eventId,
    required this.getpostDiscsUseCase,
    required this.getRepliesUseCase,
    required this.postCommentUseCase,
    required this.postReplyUseCase,
    this.onNewComment,
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

  final _commentController = TextEditingController();
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
    } catch (e, st) {
      setState(() => _loading = false);
    }
  }

  Future<void> _submitComment() async {
    final body = _commentController.text.trim();
    if (body.isEmpty) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi berakhir, silakan login kembali.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _posting = true);
    try {
      final newComment = await widget.postCommentUseCase(
        eventId: widget.eventId,
        userId: user.id,
        body: body,
      );

      _commentController.clear();
      setState(() {
        _postDiscs.insert(0, newComment);
        _offset += 1;
        _posting = false;
      });
      widget.onNewComment?.call(newComment);
    } catch (e) {
      setState(() => _posting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim komentar: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
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
                        separatorBuilder: (_, _) => const Divider(height: 1),
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
                            postReplyUseCase: widget.postReplyUseCase,
                          );
                        },
                      ),
              ),

              // ── Comment input bar ──────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  8 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.black12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Tulis komentar...',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black38,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _posting
                        ? const SizedBox(
                            width: 40,
                            height: 40,
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.teal,
                              ),
                            ),
                          )
                        : IconButton(
                            onPressed: _submitComment,
                            icon: const Icon(Icons.send_rounded),
                            color: Colors.teal,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.teal.withAlpha(20),
                            ),
                          ),
                  ],
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
  final PostReplyUseCase postReplyUseCase;

  const _PostDiscTile({
    required this.postDisc,
    required this.getRepliesUseCase,
    required this.postReplyUseCase,
  });

  @override
  State<_PostDiscTile> createState() => _PostDiscTileState();
}

class _PostDiscTileState extends State<_PostDiscTile> {
  List<ReplyPostDiscEntity> _replies = [];
  bool _showReplies = false;
  bool _loadingReplies = false;
  bool _showReplyInput = false;
  bool _postingReply = false;
  final _replyController = TextEditingController();

  final _timeFormat = DateFormat('d MMM, HH:mm', 'id_ID');

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

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

  Future<void> _submitReply() async {
    final body = _replyController.text.trim();
    if (body.isEmpty) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi berakhir, silakan login kembali.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _postingReply = true);
    try {
      final newReply = await widget.postReplyUseCase(
        postId: widget.postDisc.id,
        userId: user.id,
        body: body,
      );
      _replyController.clear();
      setState(() {
        _replies.add(newReply);
        _showReplies = true;
        _showReplyInput = false;
        _postingReply = false;
      });
    } catch (e) {
      setState(() => _postingReply = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim balasan: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
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
              // 3-dots report menu for comment author
              BlocProvider.value(
                value: serviceLocator<ReportBloc>(),
                child: Builder(
                  builder: (ctx) => PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      size: 16,
                      color: Colors.black38,
                    ),
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      if (value == 'report') {
                        showReportDialog(
                          ctx,
                          reportedUserId: widget.postDisc.userId,
                          targetName: widget.postDisc.userName,
                        );
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              color: Colors.red,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Laporkan Pengguna',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // postDisc content
          Text(
            widget.postDisc.body,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 6),

          // Action row
          Row(
            children: [
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
                        _showReplies
                            ? 'Sembunyikan balasan'
                            : _replies.isNotEmpty
                            ? 'Lihat ${_replies.length} balasan'
                            : 'Lihat balasan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.teal[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => setState(() => _showReplyInput = !_showReplyInput),
                child: Text(
                  'Balas',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Inline reply input
          if (_showReplyInput) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      autofocus: true,
                      minLines: 1,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Tulis balasan...',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Colors.black38,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _postingReply
                      ? const SizedBox(
                          width: 32,
                          height: 32,
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.teal,
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: _submitReply,
                          icon: const Icon(Icons.send_rounded, size: 18),
                          color: Colors.teal,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                ],
              ),
            ),
          ],

          // Replies list
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
                            // 3-dots report for reply author
                            BlocProvider.value(
                              value: serviceLocator<ReportBloc>(),
                              child: Builder(
                                builder: (ctx) => PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    size: 14,
                                    color: Colors.black26,
                                  ),
                                  padding: EdgeInsets.zero,
                                  onSelected: (value) {
                                    if (value == 'report') {
                                      showReportDialog(
                                        ctx,
                                        reportedUserId: reply.userId,
                                        targetName:
                                            reply.userName ?? 'Pengguna',
                                      );
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                      value: 'report',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.flag_outlined,
                                            color: Colors.red,
                                            size: 16,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Laporkan Pengguna',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
