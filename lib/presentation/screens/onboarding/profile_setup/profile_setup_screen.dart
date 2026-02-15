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
  bool _isCompletionDialogShowing = false;

  @override
  void dispose() {
    _isCompletionDialogShowing = false;
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

    // Show completion dialog when onboarding is complete (only once)
    if (formData.showCompletionDialog && !_isCompletionDialogShowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isCompletionDialogShowing) {
          _isCompletionDialogShowing = true;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Profile Setup Complete! 🎉'),
              content: const Text(
                "Perfect! I've got everything I need. Your profile is looking great!",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    viewModel.dismissCompletionDialog();
                    Navigator.of(context).pop();
                    _isCompletionDialogShowing = false;
                    // Navigate to next screen (permissions)
                    context.goToRoute(AppRoutes.onboardingPermissions);
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
          );
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
              // Navigate to permissions after skipping profile setup
              context.goToRoute(AppRoutes.onboardingPermissions);
            },
            child: Text(
              "Skip",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
}
