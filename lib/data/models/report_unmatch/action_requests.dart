class UnmatchRequest {
  final String userId;
  final String matchedUserId;
  final String reasonKey;

  const UnmatchRequest({
    required this.userId,
    required this.matchedUserId,
    required this.reasonKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'matchedUserId': matchedUserId,
      'reasonKey': reasonKey,
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
    return {
      'reporterUserId': reporterUserId,
      'reportedUserId': reportedUserId,
      'reasonKey': reasonKey,
      if (details != null && details!.isNotEmpty) 'details': details,
    };
  }
}
