import 'package:flutter/material.dart';

import 'report_bottom_sheet.dart';
import 'unmatch_bottom_sheet.dart';

class ReportUnmatchMenuButton extends StatelessWidget {
  final String currentUserId;
  final String targetUserId;
  final String targetUserName;

  const ReportUnmatchMenuButton({
    super.key,
    required this.currentUserId,
    required this.targetUserId,
    required this.targetUserName,
  });

  void _showUnmatchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UnmatchBottomSheet(
        currentUserId: currentUserId,
        matchedUserId: targetUserId,
        matchedUserName: targetUserName,
      ),
    );
  }

  void _showReportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportBottomSheet(
        currentUserId: currentUserId,
        reportedUserId: targetUserId,
        reportedUserName: targetUserName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<int>(
      icon: Icon(
        Icons.more_vert,
        color: colorScheme.onSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colorScheme.surfaceContainerHigh,
      onSelected: (value) {
        if (value == 0) {
          _showUnmatchSheet(context);
        } else if (value == 1) {
          _showReportSheet(context);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Row(
            children: [
              Icon(Icons.person_remove_outlined,
                  size: 20, color: colorScheme.onSurface),
              const SizedBox(width: 12),
              Text(
                'Unmatch',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.flag_outlined, size: 20, color: colorScheme.error),
              const SizedBox(width: 12),
              Text(
                'Unmatch & Report',
                style: TextStyle(color: colorScheme.error),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
