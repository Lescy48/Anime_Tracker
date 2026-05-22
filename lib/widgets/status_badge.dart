// lib/widgets/status_badge.dart

import 'package:flutter/material.dart';
import '../theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool large;

  const StatusBadge({super.key, required this.status, this.large = false});

  Color get _bgColor {
    switch (status) {
      case 'watching':
        return AppColors.watching.withOpacity(0.12);
      case 'completed':
        return AppColors.completed.withOpacity(0.12);
      case 'watchlist':
        return AppColors.watchlist.withOpacity(0.12);
      default:
        return AppColors.paleBlue;
    }
  }

  Color get _textColor {
    switch (status) {
      case 'watching':
        return AppColors.watching;
      case 'completed':
        return AppColors.completed;
      case 'watchlist':
        return AppColors.watchlist;
      default:
        return AppColors.lightBlue;
    }
  }

  IconData get _icon {
    switch (status) {
      case 'watching':
        return Icons.play_circle_filled_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'watchlist':
        return Icons.bookmark_rounded;
      default:
        return Icons.help_outline;
    }
  }

  String get _label {
    switch (status) {
      case 'watching':
        return 'Watching';
      case 'completed':
        return 'Completed';
      case 'watchlist':
        return 'Watchlist';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: large ? 16 : 12, color: _textColor),
          const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(
              fontSize: large ? 13 : 11,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }
}
