import 'package:json_annotation/json_annotation.dart';
import 'suggestion_candidate.dart';

part 'suggestion_response.g.dart';

@JsonSerializable()
class SuggestionResponse {
  final String id;
  final String userId;
  final DateTime generatedAt;
  final DateTime expiresAt;
  final List<SuggestionCandidate> candidates;

  SuggestionResponse({
    required this.id,
    required this.userId,
    required this.generatedAt,
    required this.expiresAt,
    required this.candidates,
  });

  factory SuggestionResponse.fromJson(Map<String, dynamic> json) =>
      _$SuggestionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestionResponseToJson(this);
}
