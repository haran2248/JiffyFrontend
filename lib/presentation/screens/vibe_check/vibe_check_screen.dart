import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/presentation/screens/vibe_check/models/vibe_check_state.dart';
import 'package:jiffy/presentation/screens/vibe_check/viewmodels/vibe_check_viewmodel.dart';
import 'package:jiffy/presentation/screens/vibe_check/widgets/vibe_check_chat_bubble.dart';
import 'package:jiffy/presentation/screens/vibe_check/widgets/vibe_check_input_bar.dart';
import 'package:jiffy/presentation/screens/vibe_check/widgets/vibe_check_progress_dots.dart';
import 'package:jiffy/presentation/screens/vibe_check/widgets/vibe_check_score_sheet.dart';

class VibeCheckScreen extends ConsumerStatefulWidget {
  final String chipId;

  const VibeCheckScreen({required this.chipId, super.key});

  @override
  ConsumerState<VibeCheckScreen> createState() => _VibeCheckScreenState();
}

class _VibeCheckScreenState extends ConsumerState<VibeCheckScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final vm = ref.watch(vibeCheckViewModelProvider(widget.chipId));
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Trigger score sheet when status flips to completed
    ref.listen<VibeCheckState>(
      vibeCheckViewModelProvider(widget.chipId),
      (prev, next) {
        if (prev?.status != ProbeStatus.completed &&
            next.status == ProbeStatus.completed &&
            next.score != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => VibeCheckScoreSheet(
                  score: next.score!,
                  story: next.story ?? '',
                  chipId: widget.chipId,
                ),
              );
            }
          });
        }
      },
    );

    // Auto-scroll to bottom on new messages / streaming
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });

    final inputEnabled = !vm.isStreaming && vm.status == ProbeStatus.inProgress;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            _ChipPill(chipId: widget.chipId),
            const Spacer(),
            VibeCheckProgressDots(filledCount: vm.userAnswerCount.clamp(0, 3)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Skip',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(vm, userId, colorScheme),
          ),
          if (vm.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                vm.error!,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          VibeCheckInputBar(
            controller: _controller,
            enabled: inputEnabled,
            onSend: () {
              ref
                  .read(vibeCheckViewModelProvider(widget.chipId).notifier)
                  .sendAnswer(widget.chipId, _controller.text.trim());
              _controller.clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(
      VibeCheckState vm, String userId, ColorScheme colorScheme) {
    if (vm.status == ProbeStatus.notStarted) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: vm.messages.length +
          (vm.isStreaming ? 1 : 0) +
          (vm.status == ProbeStatus.scoring ? 1 : 0),
      itemBuilder: (context, index) {
        // Scoring state indicator after all messages
        if (vm.status == ProbeStatus.scoring &&
            index == vm.messages.length + (vm.isStreaming ? 1 : 0)) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                'Calculating your score...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          );
        }

        // Streaming bubble — shows incoming tokens or typing dots
        if (vm.isStreaming && index == vm.messages.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 4),
            child: VibeCheckChatBubble(
              message: vm.streamBuffer,
              isUser: false,
              isStreaming: vm.streamBuffer.isEmpty,
            ),
          );
        }

        final msg = vm.messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: VibeCheckChatBubble(
            message: msg.message,
            isUser: msg.senderId == userId,
          ),
        );
      },
    );
  }
}

class _ChipPill extends StatelessWidget {
  final String chipId;

  const _ChipPill({required this.chipId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _chipLabel(chipId),
        style: textTheme.labelMedium?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _chipLabel(String chipId) {
    const labels = {
      'flirty': 'Flirty ✨',
      'fun_chill': 'Fun & Chill',
      'wholesome': 'Wholesome',
      'deep_thinker': 'Deep Thinker',
      'funny': 'Funny',
      'serious_dating': 'Serious Dating',
      'just_exploring': 'Just Exploring',
      'sporty': 'Sporty',
      'creative': 'Creative',
    };
    return labels[chipId] ?? chipId;
  }
}
