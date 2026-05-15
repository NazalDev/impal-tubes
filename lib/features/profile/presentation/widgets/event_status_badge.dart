import 'package:flutter/material.dart';

class EventStatusBadge extends StatelessWidget {
  final String status;
  const EventStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _backgroundColor, width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _backgroundColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (status.toLowerCase()) {
      case 'published':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'dibatalkan':
        return Colors.red;
      case 'selesai':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }
}
