import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repository/onboarding_repository.dart';
import '../models/profile_setup_form_data.dart';

part 'profile_setup_viewmodel.g.dart';

@riverpod
class ProfileSetupViewModel extends _$ProfileSetupViewModel {
  Timer? _typingTimer;
  List<String> _currentQuestions = [];
  final List<String> _currentAnswers = [];
  List<String> _allQuestions = []; // All questions from current batch
  final List<String> _allAnswers = []; // All answers collected so far
  int _currentQuestionIndex = 0; // Track which question we're showing
  bool _isInitialized = false;
  bool _onboardingComplete = false;

  @override
  ProfileSetupFormData build() {
    final repository = ref.read(onboardingRepositoryProvider);

    ref.onDispose(() {
      _typingTimer?.cancel();
      _typingTimer = null;
    });

    // Initialize onboarding when viewmodel is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _initializeOnboarding(repository);
      }
    });

    // Show initial welcome message
    final initialMessage = ChatMessage(
      text:
          "Hey there! 👋 I'm here to help create your perfect profile. Let me get to know you better...",
      isFromUser: false,
      timestamp: DateTime.now(),
    );

    return ProfileSetupFormData(
      messages: [initialMessage],
      suggestedResponses: const [],
      currentQuestion: null,
      currentStep: 2, // Step 2 of 3
      isTyping: true, // Show typing while initializing
      showCompletionDialog: false,
    );
  }

  Future<void> _initializeOnboarding(OnboardingRepository repository) async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      debugPrint('🔄 Initializing onboarding...');

      // Get predefined answers from user's existing profile data
      // These should come from earlier onboarding steps (basics, preferences, etc.)
      final predefinedAnswers = await _getPredefinedAnswers();

      if (predefinedAnswers.isEmpty) {
        debugPrint('⚠️ No predefined answers found - user profile may be incomplete');
        // Continue with empty map - backend will handle validation
      }

      debugPrint(
          '📝 Using predefined answers: ${predefinedAnswers.keys.toList()}');
      final questions =
          await repository.initializeOnboarding(predefinedAnswers);

      debugPrint('✅ Received ${questions.length} onboarding questions');

      // Store all questions and reset tracking for new batch
      _allQuestions = questions;
      _currentQuestions = questions;
      _currentQuestionIndex = 0;
      _currentAnswers.clear();

      // Show first question as AI message
      if (questions.isNotEmpty) {
        final firstQuestion = ChatMessage(
          text: questions[0],
          isFromUser: false,
          timestamp: DateTime.now(),
        );

        state = state.copyWith(
          messages: [...state.messages, firstQuestion],
          isTyping: false,
          currentQuestion: questions[0],
          suggestedResponses: [], // No suggested responses for AI-generated questions
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing onboarding: $e');
      debugPrint('Stack trace: $stackTrace');

      // Fallback to hardcoded message on error
      final errorMessage = ChatMessage(
        text:
            "Hey there! 👋 I'm here to help create your perfect profile. Let's start easy - what do you love doing on a lazy Sunday?",
        isFromUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isTyping: false,
        currentQuestion: "What do you love doing on a lazy Sunday?",
        suggestedResponses: const [
          "Hiking in nature ⛰️",
          "Brunch and coffee ☕",
          "Reading a good book 📚",
          "Exploring new places 🏞️",
        ],
      );
    }
  }

  void addUserMessage(String text) {
    if (text.trim().isEmpty || _onboardingComplete) return;

    final userMessage = ChatMessage(
      text: text.trim(),
      isFromUser: true,
      timestamp: DateTime.now(),
    );

    // Add answer to both current batch and all answers
    final answer = text.trim();
    _currentAnswers.add(answer);
    _allAnswers.add(answer);

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      userInput: () => null,
      clearUserInput: true,
    );

    // Move to next question in current batch
    _currentQuestionIndex++;

    // Check if we've answered all questions in current batch
    if (_currentQuestionIndex >= _currentQuestions.length) {
      // All questions in this batch answered, submit and get next batch
      _submitAnswersAndGetNextBatch();
    } else {
      // Show next question from current batch
      _showNextQuestion();
    }
  }

  void selectSuggestedResponse(String response) {
    addUserMessage(response);
  }

  void updateUserInput(String? input) {
    state = state.copyWith(userInput: () => input);
  }

  void _showNextQuestion() {
    if (_currentQuestionIndex < _currentQuestions.length) {
      final nextQuestion = _currentQuestions[_currentQuestionIndex];

      // Set typing indicator
      state = state.copyWith(isTyping: true);

      // Show next question after short delay
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(milliseconds: 800), () {
        final questionMessage = ChatMessage(
          text: nextQuestion,
          isFromUser: false,
          timestamp: DateTime.now(),
        );

        state = state.copyWith(
          messages: [...state.messages, questionMessage],
          isTyping: false,
          currentQuestion: nextQuestion,
          suggestedResponses: [], // No suggested responses for AI-generated questions
        );
      });
    }
  }

  Future<void> _submitAnswersAndGetNextBatch() async {
    if (_onboardingComplete) return;

    state = state.copyWith(isTyping: true);

    try {
      debugPrint('🔄 Submitting batch of ${_currentAnswers.length} answers...');
      final repository = ref.read(onboardingRepositoryProvider);

      // Submit current batch of answers - this now returns next questions if available
      final nextQuestions =
          await repository.submitAnswers(_currentQuestions, _currentAnswers);

      debugPrint(
          '✅ Answers submitted. Received ${nextQuestions.length} next questions');

      // Check if we got next batch of questions
      if (nextQuestions.isNotEmpty) {
        debugPrint(
            '✅ Starting next batch with ${nextQuestions.length} questions');

        // Start new batch
        _currentQuestions = nextQuestions;
        _allQuestions.addAll(nextQuestions);
        _currentAnswers.clear();
        _currentQuestionIndex = 0;

        // Show first question of next batch after short delay
        _typingTimer?.cancel();
        _typingTimer = Timer(const Duration(milliseconds: 500), () {
          final nextQuestion = ChatMessage(
            text: nextQuestions[0],
            isFromUser: false,
            timestamp: DateTime.now(),
          );

          state = state.copyWith(
            messages: [...state.messages, nextQuestion],
            isTyping: false,
            currentQuestion: nextQuestions[0],
            suggestedResponses: [], // No suggested responses for AI-generated questions
          );
        });
        return;
      }

      // No more questions, onboarding complete
      debugPrint('✅ Onboarding complete - no more questions');
      _onboardingComplete = true;

      final completionMessage = ChatMessage(
        text:
            "Perfect! I've got everything I need. Your profile is looking great! 🎉",
        isFromUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, completionMessage],
        isTyping: false,
        suggestedResponses: [],
        currentQuestion: null,
        showCompletionDialog: true, // Trigger completion dialog
      );

      // Don't auto-navigate - let user click "Next" in dialog
    } catch (e, stackTrace) {
      debugPrint('❌ Error submitting answers: $e');
      debugPrint('Stack trace: $stackTrace');

      final errorMessage = ChatMessage(
        text:
            "Thanks for sharing! I've saved your responses. Let's continue building your profile.",
        isFromUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isTyping: false,
        suggestedResponses: [],
      );
    }
  }

  void nextStep() {
    // Clear completion dialog flag and navigate to next step
    state = state.copyWith(showCompletionDialog: false);
    // Navigation will be handled by the screen
  }

  void onCompletionDialogDismissed() {
    // Clear the dialog flag when dismissed
    state = state.copyWith(showCompletionDialog: false);
  }

  void skip() {
    // Skip to next step
    nextStep();
  }

  /// Get predefined answers from user's existing profile data
  /// In a real flow, these would come from earlier onboarding steps
  Future<Map<String, String>> _getPredefinedAnswers() async {
    try {
      // TODO: Fetch user data from API and extract predefined answers
      // For now, return empty map - test data will be added by caller
      return <String, String>{};
    } catch (e) {
      debugPrint('⚠️ Error fetching predefined answers: $e');
      return <String, String>{};
    }
  }
}
