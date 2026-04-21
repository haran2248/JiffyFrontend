import 'package:jiffy/presentation/screens/chat/models/chat_message.dart';

enum ProbeStatus { notStarted, inProgress, scoring, completed }

class VibeCheckState {
  final ProbeStatus status;
  final List<ChatMessage> messages;
  final bool isStreaming;
  final String streamBuffer;
  final int userAnswerCount;
  final int? score;
  final String? story;
  final String? error;

  const VibeCheckState({
    this.status = ProbeStatus.notStarted,
    this.messages = const [],
    this.isStreaming = false,
    this.streamBuffer = '',
    this.userAnswerCount = 0,
    this.score,
    this.story,
    this.error,
  });

  VibeCheckState copyWith({
    ProbeStatus? status,
    List<ChatMessage>? messages,
    bool? isStreaming,
    String? streamBuffer,
    int? userAnswerCount,
    int? score,
    String? story,
    String? Function()? error,
  }) {
    return VibeCheckState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      streamBuffer: streamBuffer ?? this.streamBuffer,
      userAnswerCount: userAnswerCount ?? this.userAnswerCount,
      score: score ?? this.score,
      story: story ?? this.story,
      error: error != null ? error() : this.error,
    );
  }
}
