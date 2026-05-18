import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:volync/core/theme/app_pallete.dart';
import 'package:volync/features/history/domain/entity/user_registration_entity.dart';

class RegistrationHistoryCard extends StatelessWidget {
  final UserRegistrationEntity registration;
  final VoidCallback onTap;
  final VoidCallback? onCancel;

  const RegistrationHistoryCard({
    super.key,
    required this.registration,
    required this.onTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('d MMM yyyy', 'id_ID');
    final canCancel =
        registration.status == 'pending' || registration.status == 'approved';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppPallete.cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image
            if (registration.eventImageUrl != null &&
                registration.eventImageUrl!.startsWith('http'))
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  registration.eventImageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 120,
                    color: AppPallete.borderColor,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: _statusColor(registration.status),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Genre + status badge row
                  Row(
                    children: [
                      if (registration.eventGenre != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppPallete.backgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            registration.eventGenre!,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppPallete.focusedColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      const Spacer(),
                      _RegistrationStatusBadge(status: registration.status),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Event title
                  Text(
                    registration.eventTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppPallete.blackColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          registration.eventLocation,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Dates
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${dateFormatter.format(registration.eventStartAt)} – ${dateFormatter.format(registration.eventEndAt)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Registered at
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Didaftarkan: ${dateFormatter.format(registration.registeredAt)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),

                  // Cancel button
                  if (canCancel && onCancel != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: const Text('Batalkan Pendaftaran'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

class _RegistrationStatusBadge extends StatelessWidget {
  final String status;
  const _RegistrationStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status.toLowerCase()) {
      'approved' => ('Diterima', Colors.green[700]!, Colors.green[50]!),
      'pending' => ('Menunggu', Colors.orange[700]!, Colors.orange[50]!),
      'rejected' => ('Ditolak', Colors.red[700]!, Colors.red[50]!),
      'cancelled' => ('Dibatalkan', Colors.grey[700]!, Colors.grey[100]!),
      _ => ('Unknown', Colors.grey[700]!, Colors.grey[100]!),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
