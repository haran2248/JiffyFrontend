class ChatMessage {
  final String text;
  final bool isFromUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isFromUser,
    required this.timestamp,
  });

  ChatMessage copyWith({
    String? text,
    bool? isFromUser,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isFromUser: isFromUser ?? this.isFromUser,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class ProfileSetupFormData {
  final List<ChatMessage> messages;
  final List<String> suggestedResponses;
  final String? currentQuestion;
  final bool isTyping;
  final int currentStep;
  final String? userInput;
  final bool showCompletionDialog;

  const ProfileSetupFormData({
    this.messages = const [],
    this.suggestedResponses = const [],
    this.currentQuestion,
    this.isTyping = false,
    this.currentStep = 1,
    this.userInput,
    this.showCompletionDialog = false,
  });

  ProfileSetupFormData copyWith({
    List<ChatMessage>? messages,
    List<String>? suggestedResponses,
    String? currentQuestion,
    bool? isTyping,
    int? currentStep,
    String? Function()? userInput,
    bool clearUserInput = false,
    bool? showCompletionDialog,
  }) {
    return ProfileSetupFormData(
      messages: messages ?? this.messages,
      suggestedResponses: suggestedResponses ?? this.suggestedResponses,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      isTyping: isTyping ?? this.isTyping,
      currentStep: currentStep ?? this.currentStep,
      userInput: clearUserInput
          ? null
          : (userInput != null ? userInput() : this.userInput),
      showCompletionDialog: showCompletionDialog ?? (this.showCompletionDialog),
    );
  }

  bool get canProceed {
    return messages.isNotEmpty &&
        messages.any((msg) => msg.isFromUser) &&
        !isTyping;
  }
}
