import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/storage_service.dart';

class WishlistProvider extends ChangeNotifier {
  final Set<String> _wishlistIds = {};

  Set<String> get wishlistIds => _wishlistIds;
  int get count => _wishlistIds.length;

  WishlistProvider() {
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final ids = await StorageService.getWishlistIds();
    _wishlistIds.addAll(ids);
    notifyListeners();
  }

  bool isInWishlist(String productId) {
    return _wishlistIds.contains(productId);
  }

  Future<void> toggleWishlist(String productId) async {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
    } else {
      _wishlistIds.add(productId);
    }
    notifyListeners();
    await StorageService.saveWishlistIds(_wishlistIds.toList());
  }

  List<ProductModel> getWishlistProducts(List<ProductModel> allProducts) {
    return allProducts.where((p) => _wishlistIds.contains(p.id)).toList();
  }
}
