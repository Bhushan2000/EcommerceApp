import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';
import '../services/firestore_service.dart';

enum ProductSortOption {
  featured,
  priceLowToHigh,
  priceHighToLow,
  highestRated;

  String get displayName {
    switch (this) {
      case ProductSortOption.featured:
        return 'Featured';
      case ProductSortOption.priceLowToHigh:
        return 'Price: Low to High';
      case ProductSortOption.priceHighToLow:
        return 'Price: High to Low';
      case ProductSortOption.highestRated:
        return 'Highest Rated';
    }
  }
}

class ProductProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _selectedCategory;
  String _searchQuery = '';
  ProductSortOption _sortOption = ProductSortOption.featured;
  double? _maxPrice;

  ProductProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService() {
    loadData();
  }

  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  ProductSortOption get sortOption => _sortOption;
  double? get maxPrice => _maxPrice;

  List<ProductModel> get featuredProducts =>
      _products.where((p) => p.isFeatured).toList();

  List<ProductModel> get flashSaleProducts =>
      _products.where((p) => p.isFlashSale).toList();

  List<ProductModel> get filteredProducts {
    var result = List<ProductModel>.from(_products);

    // Category filter
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      result = result.where((p) => p.categoryId == _selectedCategory).toList();
    }

    // Search query
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      result = result.where((p) {
        final titleMatch = p.title.toLowerCase().contains(query);
        final descMatch = p.description.toLowerCase().contains(query);
        final tagMatch = p.tags.any((t) => t.toLowerCase().contains(query));
        return titleMatch || descMatch || tagMatch;
      }).toList();
    }

    // Max price
    if (_maxPrice != null && _maxPrice! > 0) {
      result = result.where((p) => p.price <= _maxPrice!).toList();
    }

    // Sorting
    switch (_sortOption) {
      case ProductSortOption.featured:
        result.sort((a, b) => (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0));
        break;
      case ProductSortOption.priceLowToHigh:
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceHighToLow:
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.highestRated:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    return result;
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedCategories = await _firestoreService.getCategories();
      final fetchedProducts = await _firestoreService.getProducts();

      _categories = fetchedCategories;
      _products = fetchedProducts;
    } catch (e) {
      debugPrint('Error loading product data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String? categoryId) {
    if (_selectedCategory == categoryId) {
      _selectedCategory = null;
    } else {
      _selectedCategory = categoryId;
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(ProductSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void setMaxPrice(double? price) {
    _maxPrice = price;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategory = null;
    _searchQuery = '';
    _sortOption = ProductSortOption.featured;
    _maxPrice = null;
    notifyListeners();
  }

  Future<void> addReview(String productId, ReviewModel review) async {
    await _firestoreService.addProductReview(productId, review);
    // Reload local product data
    final updatedProduct = await _firestoreService.getProductById(productId);
    if (updatedProduct != null) {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }
    }
  }

  Future<String?> seedFirestore() async {
    final error = await _firestoreService.seedInitialDataToFirestore();
    if (error == null) {
      await loadData();
    }
    return error;
  }
}
