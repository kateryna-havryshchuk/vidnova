import 'package:dio/dio.dart';
import 'models/auth_response.dart';
import 'models/change_email_request.dart';
import 'models/change_password_request.dart';
import 'models/google_login_request.dart';
import 'models/login_request.dart';
import 'models/me_response.dart';
import 'models/register_request.dart';
import 'models/set_password_request.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  bool _isSuccess(int? statusCode) {
    if (statusCode == null) return false;
    return statusCode >= 200 && statusCode < 300;
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final res = await _dio.post('/api/auth/register', data: request.toJson());

    if (!_isSuccess(res.statusCode)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
      );
    }

    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AuthResponse> login(LoginRequest request) async {
    final res = await _dio.post('/api/auth/login', data: request.toJson());

    if (!_isSuccess(res.statusCode)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
      );
    }

    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AuthResponse> googleLogin(GoogleLoginRequest request) async {
    final res = await _dio.post('/api/auth/google', data: request.toJson());

    if (!_isSuccess(res.statusCode)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
      );
    }

    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MeResponse> me() async {
    final res = await _dio.get('/api/users/me');

    if (!_isSuccess(res.statusCode)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
      );
    }

    return MeResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> changeEmail(ChangeEmailRequest request) async {
    final res = await _dio.post('/api/users/change-email', data: request.toJson());

    if (!_isSuccess(res.statusCode)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
      );
    }
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    final res = await _dio.post('/api/users/change-password', data: request.toJson());

    if (!_isSuccess(res.statusCode)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
      );
    }
  }

  Future<void> setPassword(SetPasswordRequest request) async {
    final res = await _dio.post('/api/users/set-password', data: request.toJson());

    if (!_isSuccess(res.statusCode)) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
      );
    }
  }
}