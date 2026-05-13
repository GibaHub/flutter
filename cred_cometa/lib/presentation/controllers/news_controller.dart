import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../data/models/news_model.dart';
import '../../data/repositories/news_repository_impl.dart';

class NewsController extends ChangeNotifier {
  final NewsRepositoryImpl repository;

  List<NewsModel> _newsList = [];
  bool _isLoading = false;
  String? _error;

  NewsController(this.repository);

  List<Map<String, dynamic>> get news =>
      _newsList.map((e) => e.toJson()).toList();

  List<Map<String, dynamic>> get promotions => [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _newsList = await repository.getNews();
    } catch (e) {
      _error = "Erro ao carregar novidades: $e";
      // Keep empty list
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNews(Map<String, dynamic> item) async {
    _isLoading = true;
    notifyListeners();
    try {
      String? imageUrl;
      if (item['imageBytes'] != null && item['imageBytes'] is Uint8List) {
        final bytes = item['imageBytes'] as Uint8List;
        final base64String = base64Encode(bytes);
        imageUrl = 'data:image/png;base64,$base64String';
      }

      final model = NewsModel(
        id: '', // Server assigns ID
        title: item['title'] ?? '',
        content: item['content'] ?? '',
        subtitle: item['subtitle'],
        publishedAt:
            item['publishedAt'] != null
                ? DateTime.parse(item['publishedAt'])
                : DateTime.now(),
        imageUrl: imageUrl ?? '',
      );

      await repository.createNews(model);
      await fetchNews();
    } catch (e) {
      _error = "Erro ao adicionar novidade: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNews(String id, Map<String, dynamic> updatedItem) async {
    _isLoading = true;
    notifyListeners();
    try {
      String? imageUrl;
      // Preserve existing URL if not changed
      final existingNews = _newsList.firstWhere(
        (element) => element.id == id,
        orElse:
            () => NewsModel(
              id: '',
              title: '',
              content: '',
              imageUrl: '',
              publishedAt: DateTime.now(),
            ),
      );
      imageUrl = existingNews.imageUrl;

      if (updatedItem['imageBytes'] != null &&
          updatedItem['imageBytes'] is Uint8List) {
        final bytes = updatedItem['imageBytes'] as Uint8List;
        final base64String = base64Encode(bytes);
        imageUrl = 'data:image/png;base64,$base64String';
      }

      final model = NewsModel(
        id: id,
        title: updatedItem['title'] ?? '',
        content: updatedItem['content'] ?? '',
        subtitle: updatedItem['subtitle'],
        publishedAt:
            updatedItem['publishedAt'] != null
                ? DateTime.parse(updatedItem['publishedAt'])
                : existingNews.publishedAt,
        imageUrl: imageUrl,
      );

      await repository.updateNews(model);
      await fetchNews();
    } catch (e) {
      _error = "Erro ao atualizar novidade: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteNews(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await repository.deleteNews(id);
      await fetchNews();
    } catch (e) {
      _error = "Erro ao excluir novidade: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
