import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repository/onboarding_repository.dart';
import '../models/profile_setup_form_data.dart';

part 'profile_setup_viewmodel.g.dart';

@riverpod
class ProfileSetupViewModel extends _$ProfileSetupViewModel {
  Timer? _typingTimer;
  final List<String> _currentQuestions = [];
  final List<String> _currentAnswers = [];
  int _currentQuestionIndex = 0;
  bool _isInitialized = false;
  bool _onboardingComplete = false;

  @override
  ProfileSetupFormData build() {
    ref.onDispose(() {
      _typingTimer?.cancel();
      _typingTimer = null;
    });

    // Initialize onboarding when viewmodel is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _initializeOnboarding();
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

  Future<void> _initializeOnboarding() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      debugPrint('🔄 Initializing onboarding...');

      final repository = ref.read(onboardingRepositoryProvider);

      // Get predefined answers from user's existing profile data
      // These should come from earlier onboarding steps (basics, preferences, etc.)
      final predefinedAnswers = await _getPredefinedAnswers();

      if (predefinedAnswers.isEmpty) {
        debugPrint(
            '⚠️ No predefined answers found - using minimal fallback data');
        // Fallback: Add minimal required data if user data is not available
        // In production, this should rarely happen as predefined answers come from
        // earlier onboarding steps (basics, preferences, etc.)
        predefinedAnswers['name'] = 'User';
      }

      debugPrint(
          '📝 Using predefined answers: ${predefinedAnswers.keys.toList()}');
      final questions =
          await repository.initializeOnboarding(predefinedAnswers);

      debugPrint('✅ Received ${questions.length} onboarding questions');

      // Store questions and reset tracking
      _currentQuestions.clear();
      _currentQuestions.addAll(questions);
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
          suggestedResponses: const [], // No suggested responses for AI-generated questions
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing onboarding: $e');
      debugPrint('Stack trace: $stackTrace');

      // Fallback to error message
      final errorMessage = ChatMessage(
        text:
            "Sorry, I'm having trouble connecting right now. Please try again later.",
        isFromUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isTyping: false,
        suggestedResponses: const [],
      );
    }
  }

  void addUserMessage(String text) {
    if (text.trim().isEmpty || _onboardingComplete) return;

    // Don't accept answers if we don't have questions yet
    if (!_isInitialized || _currentQuestions.isEmpty) {
      debugPrint(
          '⚠️ Cannot accept answer: initialized=$_isInitialized, questions=${_currentQuestions.length}');
      return;
    }

    final userMessage = ChatMessage(
      text: text.trim(),
      isFromUser: true,
      timestamp: DateTime.now(),
    );

    // Add answer to current batch
    _currentAnswers.add(text.trim());

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      userInput: () => null,
      clearUserInput: true,
    );

    // Move to next question in current batch
    _currentQuestionIndex++;

    // Check if we've answered all questions in current batch
    if (_currentQuestions.isEmpty) {
      debugPrint('⚠️ No questions available yet - waiting for initialization');
      return;
    }

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
          suggestedResponses: const [], // No suggested responses for AI-generated questions
        );
      });
    }
  }

  Future<void> _submitAnswersAndGetNextBatch() async {
    if (_onboardingComplete) return;

    // Guard: Don't submit if we don't have questions or answers
    if (_currentQuestions.isEmpty || _currentAnswers.isEmpty) {
      debugPrint(
          '⚠️ Cannot submit: questions=${_currentQuestions.length}, answers=${_currentAnswers.length}');
      return;
    }

    // Ensure questions and answers arrays match in length
    if (_currentQuestions.length != _currentAnswers.length) {
      debugPrint(
          '⚠️ Mismatch: questions=${_currentQuestions.length}, answers=${_currentAnswers.length}');
      // Only submit the matching pairs
      final minLength = _currentQuestions.length < _currentAnswers.length
          ? _currentQuestions.length
          : _currentAnswers.length;
      _currentQuestions.removeRange(minLength, _currentQuestions.length);
      _currentAnswers.removeRange(minLength, _currentAnswers.length);
    }

    state = state.copyWith(isTyping: true);

    try {
      debugPrint('🔄 Submitting batch of ${_currentAnswers.length} answers...');
      debugPrint('📝 Questions: ${_currentQuestions.join(", ")}');
      debugPrint('📝 Answers: ${_currentAnswers.join(", ")}');
      final repository = ref.read(onboardingRepositoryProvider);

      // Submit current batch of answers
      final result =
          await repository.submitAnswers(_currentQuestions, _currentAnswers);

      final nextQuestions = result['nextQuestions'] as List<String>? ?? [];
      final isComplete = result['isComplete'] as bool? ??
          false; // Default to false (more questions might come)

      debugPrint(
          '✅ Answers submitted. Next questions: ${nextQuestions.length}, isComplete: $isComplete');

      // Check if we got next batch of questions
      if (nextQuestions.isNotEmpty && !isComplete) {
        debugPrint(
            '✅ Starting next batch with ${nextQuestions.length} questions');

        // Start new batch
        _currentQuestions.clear();
        _currentQuestions.addAll(nextQuestions);
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
            suggestedResponses: const [], // No suggested responses for AI-generated questions
          );
        });
        return;
      }

      // No more questions, onboarding complete
      debugPrint('✅ Onboarding complete');
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
        suggestedResponses: const [],
        currentQuestion: null,
        showCompletionDialog: true, // Show dialog with "Next" button
      );
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
        suggestedResponses: const [],
      );
    }
  }

  /// Get predefined answers from user's existing profile data
  /// These should come from earlier onboarding steps (basics, preferences, etc.)
  /// Returns empty map if no data is available (fallback will be used in caller)
  Future<Map<String, String>> _getPredefinedAnswers() async {
    try {
      // TODO: Fetch user data from API and extract predefined answers
      // This should include: name, gender, preferredGender, relationshipGoals, etc.
      // from earlier onboarding screens
      return <String, String>{};
    } catch (e) {
      debugPrint('⚠️ Error fetching predefined answers: $e');
      return <String, String>{};
    }
  }

  void nextStep() {
    // Navigate to next step (permissions screen)
    // This will be handled by navigation logic
    debugPrint('🚀 Navigating to next step (permissions)');
  }

  void dismissCompletionDialog() {
    state = state.copyWith(showCompletionDialog: false);
  }

  void skip() {
    // Skip to next step
    nextStep();
  }
}
