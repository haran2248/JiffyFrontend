import 'package:dio/dio.dart';
import 'package:jiffy/core/auth/auth_repository.dart';
import 'package:jiffy/core/network/dio_provider.dart';
import 'package:jiffy/core/network/errors/api_error.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'matches_repository.g.dart';

@riverpod
MatchesRepository matchesRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  return MatchesRepository(dio, authRepo);
}

class MatchesRepository {
  final Dio _dio;
  final AuthRepository _authRepo;

  MatchesRepository(this._dio, this._authRepo);

  Future<List<Map<String, dynamic>>> fetchMatches() async {
    try {
      final user = _authRepo.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      final uid = user.uid;
      // The API endpoint is: /api/v1/match/myMatches?uid=$uid
      // BaseURL is already configured in Dio.

      final response = await _dio.get(
        '/api/v1/match/myMatches',
        queryParameters: {'uid': uid},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw ApiError(
          type: ApiErrorType.server,
          message: "Failed to fetch matches: ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(
        type: ApiErrorType.unknown,
        message: "Error fetching matches: $e",
      );
    }
  }

  Future<void> addMatch(String matchUid, {String? eventName}) async {
    try {
      final user = _authRepo.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      final uid = user.uid;

      final response = await _dio.post(
        '/api/v1/match/addMatch',
        queryParameters: {
          'uid': uid,
          'matchUid': matchUid,
          if (eventName != null) 'eventName': eventName,
        },
      );

      if (response.statusCode != 200) {
        throw ApiError(
          type: ApiErrorType.server,
          message: "Failed to add match: ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(
        type: ApiErrorType.unknown,
        message: "Error adding match: $e",
      );
    }
  }

  Future<void> removeMatch(String matchUid) async {
    try {
      final user = _authRepo.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      final uid = user.uid;

      final response = await _dio.post(
        '/api/users/removeMatch',
        data: {
          'uid': uid,
          'matchedUid': matchUid,
        },
      );

      if (response.statusCode != 200) {
        throw ApiError(
          type: ApiErrorType.server,
          message: "Failed to remove match: ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(
        type: ApiErrorType.unknown,
        message: "Error removing match: $e",
      );
    }
  }
}
