class UnmatchRequest {
  final String userId;
  final String matchedUserId;
  final String? details;
  final String reasonKey;

  const UnmatchRequest({
    required this.userId,
    required this.matchedUserId,
    required this.reasonKey,
    this.details,
  });

  Map<String, dynamic> toJson() {
    final trimmedDetails = details?.trim();
    return {
      'userId': userId,
      'matchedUserId': matchedUserId,
      'reasonKey': reasonKey,
      if (trimmedDetails != null && trimmedDetails.isNotEmpty)
        'details': trimmedDetails,
    };
  }
}

class ReportRequest {
  final String reporterUserId;
  final String reportedUserId;
  final String reasonKey;
  final String? details;

  const ReportRequest({
    required this.reporterUserId,
    required this.reportedUserId,
    required this.reasonKey,
    this.details,
  });

  Map<String, dynamic> toJson() {
    final trimmedDetails = details?.trim();
    return {
      'reporterUserId': reporterUserId,
      'reportedUserId': reportedUserId,
      'reasonKey': reasonKey,
      if (trimmedDetails != null && trimmedDetails.isNotEmpty)
        'details': trimmedDetails,
    };
  }
}
