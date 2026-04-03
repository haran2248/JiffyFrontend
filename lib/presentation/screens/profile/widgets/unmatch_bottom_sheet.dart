import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/button.dart';
import '../other_reason_screen.dart';
import '../viewmodels/report_unmatch_viewmodel.dart';
import 'reason_selection_tile.dart';

class UnmatchBottomSheet extends ConsumerStatefulWidget {
  final String currentUserId;
  final String matchedUserId;
  final String matchedUserName;

  const UnmatchBottomSheet({
    super.key,
    required this.currentUserId,
    required this.matchedUserId,
    required this.matchedUserName,
  });

  static Future<void> show(
    BuildContext context, {
    required String currentUserId,
    required String matchedUserId,
    required String matchedUserName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UnmatchBottomSheet(
        currentUserId: currentUserId,
        matchedUserId: matchedUserId,
        matchedUserName: matchedUserName,
      ),
    );
  }

  @override
  ConsumerState<UnmatchBottomSheet> createState() => _UnmatchBottomSheetState();
}

class _UnmatchBottomSheetState extends ConsumerState<UnmatchBottomSheet> {
  final TextEditingController _otherController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportUnmatchViewModelProvider.notifier).clearSelection();
      ref.read(reportUnmatchViewModelProvider.notifier).fetchReasons(forReport: false);
    });
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _handleUnmatch() {
    final state = ref.read(reportUnmatchViewModelProvider);
    final isOther = state.selectedReasonKey?.toLowerCase().contains('other') ?? false;
    final text = _otherController.text.trim();

    if (isOther && text.isEmpty) return;

    ref.read(reportUnmatchViewModelProvider.notifier).submitUnmatch(
          currentUserId: widget.currentUserId,
          matchedUserId: widget.matchedUserId,
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
      // Cap the sheet at 90% of screen so it never goes full-screen,
      // and give the SingleChildScrollView room to work with.
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
                    color: colorScheme.onSurface.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_remove_outlined,
                    size: 32,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Unmatch with ${widget.matchedUserName}?',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'You won\'t be able to message each other anymore and this conversation will be deleted.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Scrollable reasons list — grows safely when keyboard is open
                Flexible(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state.unmatchReasons.isEmpty && state.isLoading)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: CircularProgressIndicator(color: colorScheme.primary),
                          )
                        else
                          ...state.unmatchReasons.map(
                            (reason) => ReasonSelectionTile(
                              reason: reason,
                              isSelected: state.selectedReasonKey == reason.key,
                              isDestructive: false,
                              onTap: () async {
                                if (reason.key.toLowerCase().contains('other')) {
                                  final text = await OtherReasonScreen.show(
                                    context,
                                    hint: 'Describe why you want to unmatch.',
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
                    text: 'Yes, Unmatch',
                    type: ButtonType.primary,
                    isLoading: state.isLoading && state.unmatchReasons.isNotEmpty,
                    onTap: state.isFormValid && !state.isLoading ? _handleUnmatch : () {},
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
