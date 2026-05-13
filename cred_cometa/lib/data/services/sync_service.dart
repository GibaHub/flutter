import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/carousel_item_model.dart';
import '../models/product_highlight_model.dart';
import '../models/news_model.dart';

class SyncService {
  final Dio _dio = Dio();
  // Using 192.168.1.220:55443 as requested
  final String _baseUrl = 'http://192.168.1.220:55443/api/sync';

  Future<void> syncAll() async {
    await syncEntity('carousel');
    await syncEntity('products');
    await syncEntity('news');
  }

  Future<void> syncEntity(String entity) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncKey = 'last_sync_$entity';
    final dataKey = '${entity}_data';

    final lastSync = prefs.getString(lastSyncKey);

    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'entity': entity,
          if (lastSync != null) 'last_sync': lastSync,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['has_updates'] == true) {
          // Update local data
          final List<dynamic> items = data['data'];
          await prefs.setString(dataKey, jsonEncode(items));

          // Update last sync timestamp
          await prefs.setString(lastSyncKey, data['sync_timestamp']);
          print('Synced $entity: ${items.length} items updated');
        } else {
          print('Synced $entity: No updates');
        }
      }
    } catch (e) {
      print('Error syncing $entity: $e');
      // On error, we just keep using local data
    }
  }

  Future<List<CarouselItemModel>> getCarousel() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('carousel_data');

    if (dataString != null) {
      final List<dynamic> jsonList = jsonDecode(dataString);
      return jsonList.map((json) => CarouselItemModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<ProductHighlightModel>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('products_data');

    if (dataString != null) {
      final List<dynamic> jsonList = jsonDecode(dataString);
      return jsonList
          .map((json) => ProductHighlightModel.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<List<NewsModel>> getNews() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('news_data');

    if (dataString != null) {
      final List<dynamic> jsonList = jsonDecode(dataString);
      return jsonList.map((json) => NewsModel.fromJson(json)).toList();
    }
    return [];
  }
}
