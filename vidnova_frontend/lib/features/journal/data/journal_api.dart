import 'package:dio/dio.dart';

import 'models/journal_models.dart';

class JournalApi {
  final Dio _dio;
  JournalApi(this._dio);

  Future<List<AbcEntryListItemDto>> listAbc() async {
    final res = await _dio.get('/api/journal/abc');

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
        .map((e) => AbcEntryListItemDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<AbcEntryResponseDto> getAbcById(String id) async {
    final res = await _dio.get('/api/journal/abc/$id');

    if (res.statusCode != 200) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
      );
    }

    return AbcEntryResponseDto.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<AbcEntryResponseDto> createAbc(SaveAbcEntryRequestDto req) async {
    final res = await _dio.post('/api/journal/abc', data: req.toJson());

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
      );
    }

    return AbcEntryResponseDto.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<AbcEntryResponseDto> updateAbc(String id, SaveAbcEntryRequestDto req) async {
    final res = await _dio.put('/api/journal/abc/$id', data: req.toJson());

    if (res.statusCode != 200) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
      );
    }

    return AbcEntryResponseDto.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<void> deleteAbc(String id) async {
    final res = await _dio.delete('/api/journal/abc/$id');

    if (res.statusCode != 204 && res.statusCode != 200) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
      );
    }
  }
}
