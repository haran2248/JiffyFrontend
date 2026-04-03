import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/button.dart';
import '../other_reason_screen.dart';
import '../viewmodels/report_unmatch_viewmodel.dart';
import 'reason_selection_tile.dart';

class ReportBottomSheet extends ConsumerStatefulWidget {
  final String currentUserId;
  final String reportedUserId;
  final String reportedUserName;

  const ReportBottomSheet({
    super.key,
    required this.currentUserId,
    required this.reportedUserId,
    required this.reportedUserName,
  });

  static Future<void> show(
    BuildContext context, {
    required String currentUserId,
    required String reportedUserId,
    required String reportedUserName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportBottomSheet(
        currentUserId: currentUserId,
        reportedUserId: reportedUserId,
        reportedUserName: reportedUserName,
      ),
    );
  }

  @override
  ConsumerState<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends ConsumerState<ReportBottomSheet> {
  final TextEditingController _otherController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportUnmatchViewModelProvider.notifier).clearSelection();
      ref.read(reportUnmatchViewModelProvider.notifier).fetchReasons(forReport: true);
    });
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _handleReport() {
    final state = ref.read(reportUnmatchViewModelProvider);
    final isOther = state.selectedReasonKey?.toLowerCase().contains('other') ?? false;
    final text = _otherController.text.trim();

    if (isOther && text.isEmpty) return;

    ref.read(reportUnmatchViewModelProvider.notifier).submitReportAndUnmatch(
          currentUserId: widget.currentUserId,
          reportedUserId: widget.reportedUserId,
          details: text.isNotEmpty ? text : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportUnmatchViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final viewInsets = MediaQuery.of(context).viewInsets;

    ref.listen(reportUnmatchViewModelProvider, (previous, next) {
      if (previous != null && !previous.isSuccess && next.isSuccess) {
        Navigator.of(context).pop();
      }
      if (previous != null && previous.error != next.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!.message),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    });

    final screenHeight = MediaQuery.of(context).size.height;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fixed header
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flag_outlined,
                    size: 32,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Report ${widget.reportedUserName}',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Let us know why you\'re reporting this profile. This will also unmatch you.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Scrollable reasons list — safe when keyboard opens
                Flexible(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state.reportReasons.isEmpty && state.isLoading)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: CircularProgressIndicator(color: colorScheme.primary),
                          )
                        else
                          ...state.reportReasons.map(
                            (reason) => ReasonSelectionTile(
                              reason: reason,
                              isSelected: state.selectedReasonKey == reason.key,
                              isDestructive: true,
                              onTap: () async {
                                if (reason.key.toLowerCase().contains('other')) {
                                  final text = await OtherReasonScreen.show(
                                    context,
                                    hint: 'Describe what happened so we can review this report.',
                                  );
                                  if (text != null && text.trim().isNotEmpty && mounted) {
                                    _otherController.text = text;
                                    ref
                                        .read(reportUnmatchViewModelProvider.notifier)
                                        .selectReason(reason.key);
                                  }
                                } else {
                                  _otherController.clear();
                                  ref
                                      .read(reportUnmatchViewModelProvider.notifier)
                                      .selectReason(reason.key);
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Fixed footer buttons
                SizedBox(
                  width: double.infinity,
                  child: Button(
                    text: 'Submit Report & Unmatch',
                    type: ButtonType.primary,
                    isLoading: state.isLoading && state.reportReasons.isNotEmpty,
                    onTap: state.isFormValid && !state.isLoading ? _handleReport : () {},
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Button(
                    text: 'Cancel',
                    type: ButtonType.ghost,
                    onTap: state.isLoading ? () {} : () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
