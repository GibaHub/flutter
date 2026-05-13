import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/news_model.dart';

class NewsRepositoryImpl {
  final Dio _dio;
  String? _accessToken;

  NewsRepositoryImpl(this._dio);

  Future<void> _authenticate() async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.authEndpoint}',
        queryParameters: {
          'grant_type': 'password',
          'username': 'cometa.service',
          'password': '103020',
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        _accessToken = data['access_token'];
      } else {
        throw Exception('Failed to authenticate: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Authentication error: $e');
    }
  }

  Future<List<NewsModel>> getNews() async {
    if (_accessToken == null) {
      await _authenticate();
    }

    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.getNews}',
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => NewsModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      // If endpoint not found (404), maybe return empty list or throw?
      // User wants connection, so we should try to connect.
      throw Exception('Error fetching news: $e');
    }
  }

  Future<void> createNews(NewsModel news) async {
    if (_accessToken == null) {
      await _authenticate();
    }

    final response = await _dio.post(
      '${ApiConstants.baseUrl}${ApiConstants.postNews}',
      data: news.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create news: ${response.statusCode}');
    }
  }

  Future<void> updateNews(NewsModel news) async {
    if (_accessToken == null) {
      await _authenticate();
    }

    final response = await _dio.put(
      '${ApiConstants.baseUrl}${ApiConstants.postNews}/${news.id}',
      data: news.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update news: ${response.statusCode}');
    }
  }

  Future<void> deleteNews(String id) async {
    if (_accessToken == null) {
      await _authenticate();
    }

    final response = await _dio.delete(
      '${ApiConstants.baseUrl}${ApiConstants.postNews}/$id',
      options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete news: ${response.statusCode}');
    }
  }
}
