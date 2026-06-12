import 'package:dio/dio.dart';
import 'models/checkin_models.dart';

class CheckInsApi {
  final Dio _dio;
  CheckInsApi(this._dio);

  Future<DailyCheckInResponseDto?> getByDate(String date) async {
    final res = await _dio.get('/api/checkins/$date');

    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
      );
    }

    return DailyCheckInResponseDto.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<DailyCheckInAiInsightResponseDto?> getInsightByDate(String date) async {
    final res = await _dio.get('/api/checkins/$date/insight');

    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
      );
    }

    return DailyCheckInAiInsightResponseDto.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<DailyCheckInResponseDto> create(String date, SaveDailyCheckInRequestDto req) async {
    final res = await _dio.post('/api/checkins/$date', data: req.toJson());

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
      );
    }

    return DailyCheckInResponseDto.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<DailyCheckInResponseDto> update(String date, SaveDailyCheckInRequestDto req) async {
    final res = await _dio.put('/api/checkins/$date', data: req.toJson());

    if (res.statusCode != 200) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
      );
    }

    return DailyCheckInResponseDto.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<List<DailyCheckInResponseDto>> listRange({
    required String from,
    required String to,
  }) async {
    final res = await _dio.get(
      '/api/checkins',
      queryParameters: {
        'from': from,
        'to': to,
      },
    );

    if (res.statusCode != 200) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
      );
    }

    final data = (res.data as List? ?? const []);
    return data
        .whereType<Map>()
        .map((e) => DailyCheckInResponseDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}