import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jiffy/core/network/dio_provider.dart';
import 'package:jiffy/core/network/errors/api_error.dart';
import 'package:jiffy/core/services/api/coupon_api_endpoints.dart';

part 'coupon_repository.g.dart';

@riverpod
CouponRepository couponRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return CouponRepository(dio);
}

class CouponRepository {
  final Dio _dio;

  CouponRepository(this._dio);

  /// Activates locked referral coupons based on the referral code.
  Future<String> activateReferral(String code, String userId) async {
    try {
      final response = await _dio.post(
        CouponApiEndpoints.activateReferral,
        queryParameters: {
          'referralCode': code,
          'newUserId': userId,
        },
        options: Options(responseType: ResponseType.plain),
      );
      
      // Attempt to return the success message string from the backend
      if (response.data is String) {
        return response.data as String;
      }
      return 'Coupons activated successfully.';
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    } catch (e) {
      throw ApiError.unknown(
        message: 'Failed to apply referral code.',
        originalError: e,
        requestPath: CouponApiEndpoints.activateReferral,
      );
    }
  }
}
