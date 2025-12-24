import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/profile_setup_form_data.dart';

part 'profile_setup_viewmodel.g.dart';

@riverpod
class ProfileSetupViewModel extends _$ProfileSetupViewModel {
  @override
  ProfileSetupFormData build() {
    // Initialize with first AI message
    final initialMessage = ChatMessage(
      text: "Hey there! 👋 I'm here to help create your perfect profile. Let's start easy - what do you love doing on a lazy Sunday?",
      isFromUser: false,
      timestamp: DateTime.now(),
    );

    return ProfileSetupFormData(
      messages: [initialMessage],
      suggestedResponses: const [
        "Hiking in nature ⛰️",
        "Brunch and coffee ☕",
        "Reading a good book 📚",
        "Exploring new places 🏞️",
      ],
      currentQuestion: "What do you love doing on a lazy Sunday?",
      currentStep: 2, // Step 2 of 3
    );
  }

  void addUserMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text.trim(),
      isFromUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      userInput: () => null,
      clearUserInput: true,
    );

    // Simulate AI typing
    _simulateAITyping();
  }

  void selectSuggestedResponse(String response) {
    addUserMessage(response);
  }

  void updateUserInput(String? input) {
    state = state.copyWith(userInput: () => input);
  }

  void _simulateAITyping() {
    // Set typing indicator
    state = state.copyWith(isTyping: true);

    // Simulate AI response after delay
    Future.delayed(const Duration(seconds: 2), () {
      final aiResponse = ChatMessage(
        text: _generateAIResponse(state.messages.last.text),
        isFromUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiResponse],
        isTyping: false,
        suggestedResponses: _generateSuggestedResponses(aiResponse.text),
        currentQuestion: _extractQuestion(aiResponse.text),
      );
    });
  }

  String _generateAIResponse(String userMessage) {
    // This will be replaced with actual API call later
    // For now, generate contextual responses
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('hiking') || lowerMessage.contains('nature')) {
      return "That sounds amazing! What kind of activities make you lose track of time?";
    } else if (lowerMessage.contains('brunch') || lowerMessage.contains('coffee')) {
      return "Love that! What's your ideal way to spend a weekend morning?";
    } else if (lowerMessage.contains('reading') || lowerMessage.contains('book')) {
      return "That sounds amazing! What kind of activities make you lose track of time?";
    } else if (lowerMessage.contains('exploring') || lowerMessage.contains('places')) {
      return "That sounds amazing! What kind of activities make you lose track of time?";
    } else if (lowerMessage.contains('food') || lowerMessage.contains('sleep')) {
      return "That sounds amazing! What kind of activities make you lose track of time?";
    } else if (lowerMessage.contains('work') || lowerMessage.contains('project')) {
      return "That's awesome! What drives you to work on side projects?";
    } else {
      return "That sounds amazing! What kind of activities make you lose track of time?";
    }
  }

  List<String> _generateSuggestedResponses(String aiMessage) {
    // Generate contextual suggested responses based on AI message
    final lowerMessage = aiMessage.toLowerCase();

    if (lowerMessage.contains('lose track of time') || lowerMessage.contains('activities')) {
      return const [
        "Working on side projects 💻",
        "Cooking new recipes 🍳",
        "Photography 📸",
        "Playing music 🎵",
      ];
    } else if (lowerMessage.contains('weekend morning')) {
      return const [
        "Sleeping in 😴",
        "Early workout 🏋️",
        "Reading with coffee ☕",
        "Exploring the city 🏙️",
      ];
    } else if (lowerMessage.contains('drives you')) {
      return const [
        "Creative expression 🎨",
        "Problem solving 🧩",
        "Learning new skills 📚",
        "Building something meaningful 🚀",
      ];
    } else {
      return const [
        "Working on side projects 💻",
        "Cooking new recipes 🍳",
        "Photography 📸",
        "Playing music 🎵",
      ];
    }
  }

  String? _extractQuestion(String aiMessage) {
    // Extract question from AI message for context
    if (aiMessage.contains('?')) {
      final questionIndex = aiMessage.indexOf('?');
      final startIndex = aiMessage.lastIndexOf(RegExp(r'[.!?]\s+'), questionIndex - 20);
      return aiMessage.substring(
        startIndex > 0 ? startIndex + 2 : 0,
        questionIndex + 1,
      ).trim();
    }
    return null;
  }

  void nextStep() {
    // Navigate to next step (Step 3)
    // This will be handled by navigation logic
  }

  void skip() {
    // Skip to next step
    nextStep();
  }
}

