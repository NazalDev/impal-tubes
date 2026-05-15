import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:volync/core/theme/app_pallete.dart';
import 'package:volync/features/profile/domain/entity/profile_event_entity.dart';
import 'package:volync/features/profile/presentation/widgets/event_status_badge.dart';

class ManageEventCard extends StatelessWidget {
  final ProfileEventEntity event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReport;
  final VoidCallback onManageMembers;
  final VoidCallback onCancel;

  const ManageEventCard({
    super.key,
    required this.event,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
    required this.onManageMembers,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isCancelled = event.status.toLowerCase() == 'dibatalkan';
    final dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppPallete.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / header
          if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                event.imageUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PlaceholderHeader(),
              ),
            )
          else
            _PlaceholderHeader(),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status & title row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    EventStatusBadge(status: event.status),
                  ],
                ),
                const SizedBox(height: 6),

                // Date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${dateFormatter.format(event.startAt)} – ${dateFormatter.format(event.endAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Action buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (!isCancelled) ...[
                      _ActionButton(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        color: AppPallete.buttonColor,
                        onTap: onEdit,
                      ),
                      _ActionButton(
                        icon: Icons.people_outline,
                        label: 'Anggota',
                        color: Colors.teal,
                        onTap: onManageMembers,
                      ),
                      _ActionButton(
                        icon: Icons.cancel_outlined,
                        label: 'Batalkan',
                        color: Colors.orange,
                        onTap: onCancel,
                      ),
                    ],
                    _ActionButton(
                      icon: Icons.bar_chart_outlined,
                      label: 'Laporan',
                      color: Colors.indigo,
                      onTap: onReport,
                    ),
                    _ActionButton(
                      icon: Icons.delete_outline,
                      label: 'Hapus',
                      color: Colors.red,
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        height: 80,
        color: AppPallete.buttonColor.withOpacity(0.3),
        child: Center(
          child: Icon(
            Icons.event_outlined,
            size: 36,
            color: AppPallete.buttonColor,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
