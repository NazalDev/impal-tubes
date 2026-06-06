import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:volync/core/theme/app_pallete.dart';
import 'package:volync/features/history/domain/entity/user_post_entity.dart';

class PostHistoryCard extends StatelessWidget {
  final UserPostEntity post;
  final VoidCallback onTap;

  const PostHistoryCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('d MMM yyyy • HH:mm', 'id_ID');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppPallete.cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type badge + date
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: post.isReply
                        ? Colors.purple[50]
                        : AppPallete.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        post.isReply
                            ? Icons.reply_rounded
                            : Icons.chat_bubble_outline_rounded,
                        size: 12,
                        color: post.isReply
                            ? Colors.purple[600]
                            : AppPallete.focusedColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.isReply ? 'Balasan' : 'Diskusi',
                        style: TextStyle(
                          fontSize: 11,
                          color: post.isReply
                              ? Colors.purple[600]
                              : AppPallete.focusedColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  dateFormatter.format(post.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Event reference
            Row(
              children: [
                if (post.eventImageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      post.eventImageUrl!,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 36,
                        height: 36,
                        color: AppPallete.borderColor,
                        child:
                            const Icon(Icons.image, size: 18, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    post.eventTitle.isNotEmpty ? post.eventTitle : 'Kegiatan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 10),

            // Post body
            Text(
              post.body,
              style: const TextStyle(
                fontSize: 14,
                color: AppPallete.blackColor,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
