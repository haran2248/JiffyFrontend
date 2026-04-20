class VibeCheckApiEndpoints {
  VibeCheckApiEndpoints._();

  static const String _base = '/api/chip-probe';

  static String chat(String userId, String chipId) =>
      '$_base/$userId/$chipId/chat';

  static String status(String userId, String chipId) =>
      '$_base/$userId/$chipId/status';
}
