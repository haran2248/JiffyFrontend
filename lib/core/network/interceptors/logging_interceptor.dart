import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor that logs HTTP requests and responses in debug mode.
///
/// This interceptor provides pretty-printed logs for debugging API calls.
/// It is completely disabled in release mode for performance and security.
///
/// Design decisions:
/// - No-op in release mode (uses [kDebugMode] check)
/// - Redacts sensitive headers (Authorization, Cookie, etc.)
/// - Uses [debugPrint] per project guidelines
/// - Pretty-formats JSON for readability
/// - Truncates large payloads to prevent console overflow
///
/// Log format example:
/// ```
/// ┌─────────────────────────────────────────────────────────
/// │ REQUEST: GET https://api.example.com/users/123
/// │ Headers: { Content-Type: application/json, Authorization: [REDACTED] }
/// │ Body: null
/// └─────────────────────────────────────────────────────────
/// ```
class LoggingInterceptor extends Interceptor {
  /// Headers that should be redacted in logs for security.
  static const List<String> _sensitiveHeaders = [
    'Authorization',
    'authorization',
    'Cookie',
    'cookie',
    'Set-Cookie',
    'set-cookie',
    'X-Auth-Token',
    'x-auth-token',
    'Api-Key',
    'api-key',
  ];

  /// Maximum length of body content to log.
  final int maxBodyLength;

  /// Whether to log request headers.
  final bool logHeaders;

  /// Whether to log request/response body.
  final bool logBody;

  LoggingInterceptor({
    this.maxBodyLength = 1000,
    this.logHeaders = true,
    this.logBody = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _logRequest(options);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _logResponse(response);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _logError(err);
    }
    handler.next(err);
  }

  void _logRequest(RequestOptions options) {
    final buffer = StringBuffer();
    buffer.writeln('┌─────────────────────────────────────────────────────────');
    buffer.writeln('│ 📤 REQUEST: ${options.method} ${options.uri}');

    if (logHeaders) {
      final headers = _redactHeaders(options.headers);
      buffer.writeln('│ Headers: $headers');
    }

    if (logBody && options.data != null) {
      final body = _formatBody(options.data);
      buffer.writeln('│ Body: $body');
    }

    buffer.writeln('└─────────────────────────────────────────────────────────');
    debugPrint(buffer.toString());
  }

  void _logResponse(Response response) {
    final duration = response.requestOptions.extra['_startTime'] != null
        ? DateTime.now()
            .difference(response.requestOptions.extra['_startTime'] as DateTime)
        : null;

    final buffer = StringBuffer();
    buffer.writeln('┌─────────────────────────────────────────────────────────');
    buffer.writeln(
      '│ 📥 RESPONSE: ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
    );

    if (duration != null) {
      buffer.writeln('│ Duration: ${duration.inMilliseconds}ms');
    }

    if (logBody && response.data != null) {
      final body = _formatBody(response.data);
      buffer.writeln('│ Body: $body');
    }

    buffer.writeln('└─────────────────────────────────────────────────────────');
    debugPrint(buffer.toString());
  }

  void _logError(DioException err) {
    final buffer = StringBuffer();
    buffer.writeln('┌─────────────────────────────────────────────────────────');
    buffer.writeln(
      '│ ❌ ERROR: ${err.type.name} ${err.requestOptions.method} ${err.requestOptions.uri}',
    );

    if (err.response?.statusCode != null) {
      buffer.writeln('│ Status: ${err.response!.statusCode}');
    }

    buffer.writeln('│ Message: ${err.message ?? err.error?.toString() ?? "Unknown error"}');

    if (logBody && err.response?.data != null) {
      final body = _formatBody(err.response!.data);
      buffer.writeln('│ Response: $body');
    }

    buffer.writeln('└─────────────────────────────────────────────────────────');
    debugPrint(buffer.toString());
  }

  /// Redacts sensitive headers for security.
  Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    final redacted = Map<String, dynamic>.from(headers);
    for (final key in redacted.keys.toList()) {
      if (_sensitiveHeaders.contains(key)) {
        redacted[key] = '[REDACTED]';
      }
    }
    return redacted;
  }

  /// Formats body content for logging, with truncation.
  String _formatBody(dynamic data) {
    try {
      String formatted;
      if (data is Map || data is List) {
        const encoder = JsonEncoder.withIndent('  ');
        formatted = encoder.convert(data);
      } else {
        formatted = data.toString();
      }

      // Truncate if too long
      if (formatted.length > maxBodyLength) {
        return '${formatted.substring(0, maxBodyLength)}... [TRUNCATED]';
      }

      return formatted;
    } catch (e) {
      return '[Unable to format: $e]';
    }
  }
}
