import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/cancel/cancel_registry.dart';
import '../../core/network/dio_provider.dart';
import '../../core/network/errors/api_error.dart';
import '../../core/network/result.dart';
import '../../core/services/api/report_unmatch_api_endpoints.dart';
import '../models/report_unmatch/action_requests.dart';
import '../models/report_unmatch/reason_option.dart';

part 'report_unmatch_repository.g.dart';

class ReportUnmatchRepository {
  final Dio _dio;
  final CancelRegistry _cancelRegistry;

  static const String _tag = 'report_unmatch';

  ReportUnmatchRepository({
    required Dio dio,
    required CancelRegistry cancelRegistry,
  })  : _dio = dio,
        _cancelRegistry = cancelRegistry;

  Future<Result<List<ReasonOption>, ApiError>> fetchReasons(String type) async {
    try {
      final response = await _dio.get(
        ReportUnmatchApiEndpoints.getReasons,
        queryParameters: {'type': type},
        cancelToken: _cancelRegistry.createToken(_tag),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      final reasons = data
          .map((json) => ReasonOption.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(reasons);
    } catch (e) {
      return Result.failure(_extractError(e));
    }
  }

  Future<Result<void, ApiError>> unmatch(UnmatchRequest request) async {
    try {
      await _dio.post(
        ReportUnmatchApiEndpoints.unmatch,
        data: request.toJson(),
        cancelToken: _cancelRegistry.createToken(_tag),
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(_extractError(e));
    }
  }

  Future<Result<void, ApiError>> reportAndUnmatch(ReportRequest request) async {
    try {
      // 1. Send the report
      await _dio.post(
        ReportUnmatchApiEndpoints.report,
        data: request.toJson(),
        cancelToken: _cancelRegistry.createToken(_tag),
      );

      // 2. Automatically trigger unmatch so state on backend is consistent
      final unmatchRequest = UnmatchRequest(
        userId: request.reporterUserId,
        matchedUserId: request.reportedUserId,
        reasonKey: request.reasonKey,
        details: request.details,
      );
      
      final unmatchResult = await unmatch(unmatchRequest);
      if (unmatchResult is Failure) return unmatchResult;

      return Result.success(null);
    } catch (e) {
      return Result.failure(_extractError(e));
    }
  }

  void cancelPendingRequests() {
    _cancelRegistry.cancelByTag(_tag);
  }

  ApiError _extractError(Object error) {
    if (error is ApiError) {
      return error;
    }

    if (error is DioException) {
      if (error.error is ApiError) {
        return error.error as ApiError;
      }
      return ApiError.fromDioException(error);
    }

    return ApiError.unknown(
      message: error.toString(),
      originalError: error,
    );
  }
}

@Riverpod(keepAlive: true)
ReportUnmatchRepository reportUnmatchRepository(Ref ref) {
  return ReportUnmatchRepository(
    dio: ref.watch(dioProvider),
    cancelRegistry: CancelRegistry(),
  );
}
