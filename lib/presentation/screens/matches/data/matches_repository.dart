import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/auth/auth_repository.dart';
import 'package:jiffy/core/network/dio_provider.dart';
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
        throw Exception("Failed to fetch matches: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching matches: $e");
    }
  }
}
