import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/navigation/navigation_service.dart';
import 'package:jiffy/core/navigation/app_routes.dart';
import 'package:jiffy/presentation/widgets/progress_bar.dart';
import 'viewmodels/profile_setup_viewmodel.dart';
import 'widgets/chat_message_list.dart';
import 'widgets/suggested_responses.dart';
import 'widgets/chat_input_field.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients &&
        _scrollController.position.hasContentDimensions) {
      Future.microtask(() {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(profileSetupViewModelProvider.notifier);
    final formData = ref.watch(profileSetupViewModelProvider);

    // Scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollToBottom();
      }
    });

    // Show completion dialog when onboarding is complete
    if (formData.showCompletionDialog == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showCompletionDialog(context, viewModel);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.popRoute(),
        ),
        title: const Text("Profile Setup"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              viewModel.skip();
              // Navigate to home after skipping profile setup
              context.goToRoute(AppRoutes.home);
            },
            child: Text(
              "Skip",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            ProgressBar(
              currentStep: formData.currentStep,
              totalSteps: 3,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      reverse: true,
                      child: Column(
                        children: [
                          ChatMessageList(
                            messages: formData.messages,
                            isTyping: formData.isTyping,
                          ),
                          SuggestedResponses(
                            responses: formData.suggestedResponses,
                            onSelect: (response) {
                              viewModel.selectSuggestedResponse(response);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  ChatInputField(
                    initialValue: formData.userInput,
                    onSend: (text) {
                      viewModel.addUserMessage(text);
                    },
                    isEnabled: !formData.isTyping,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog(
      BuildContext context, ProfileSetupViewModel viewModel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          title: const Text(
            'Profile Setup Complete! 🎉',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Perfect! I've got everything I need. Your profile is looking great!",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                viewModel.onCompletionDialogDismissed();
                Navigator.of(context).pop();
                // Navigate to home screen
                context.goToRoute(AppRoutes.home);
              },
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
