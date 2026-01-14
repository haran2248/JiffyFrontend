import 'package:json_annotation/json_annotation.dart';

part 'suggestion_candidate.g.dart';

enum BucketType {
  @JsonValue('top_pick')
  topPick,
  @JsonValue('good_match')
  goodMatch,
  @JsonValue('potential')
  potential,
}

@JsonSerializable()
class SuggestionCandidate {
  final String candidateUserId;
  final String? name;
  final dynamic age; // Could be String or int from backend
  final String? imageId;
  final String? imageId2;
  final String? imageId3;
  final String? imageId4;

  /// Presigned URL for the primary image.
  /// This field is transient and populated at runtime.
  /// User updated this to be a List of Strings.
  final List<String>? imageUrl;

  final double? distanceKm;
  final int compatibilityScore;
  final int distanceScore;
  final int attractivenessScore;
  final int finalScore;

  @JsonKey(unknownEnumValue: BucketType.potential)
  final BucketType bucket;

  final String matchReason;
  final Map<String, dynamic> scoreBreakdown;

  SuggestionCandidate({
    required this.candidateUserId,
    this.name,
    this.age,
    this.imageId,
    this.imageId2,
    this.imageId3,
    this.imageId4,
    this.imageUrl,
    this.distanceKm,
    required this.compatibilityScore,
    required this.distanceScore,
    required this.attractivenessScore,
    required this.finalScore,
    required this.bucket,
    required this.matchReason,
    required this.scoreBreakdown,
  });

  factory SuggestionCandidate.fromJson(Map<String, dynamic> json) =>
      _$SuggestionCandidateFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestionCandidateToJson(this);
}
