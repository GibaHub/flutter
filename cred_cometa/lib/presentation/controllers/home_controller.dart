import 'package:flutter/material.dart';
import '../../data/models/carousel_item_model.dart';
import '../../data/models/product_highlight_model.dart';
import '../../data/models/news_model.dart';
import '../../data/services/sync_service.dart';

class HomeController extends ChangeNotifier {
  final SyncService _syncService;

  List<CarouselItemModel> _banners = [];
  List<ProductHighlightModel> _highlights = [];
  List<NewsModel> _news = [];
  bool _isLoading = false;

  HomeController(this._syncService);

  List<CarouselItemModel> get banners => _banners;
  List<ProductHighlightModel> get highlights => _highlights;
  List<NewsModel> get news => _news;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // First load local data to show something immediately
      _banners = await _syncService.getCarousel();
      _highlights = await _syncService.getProducts();
      _news = await _syncService.getNews();
      notifyListeners();

      // Then try to sync with server
      await _syncService.syncAll();
      
      // Reload local data after sync
      _banners = await _syncService.getCarousel();
      _highlights = await _syncService.getProducts();
      _news = await _syncService.getNews();
    } catch (e) {
      print('Error loading home data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
