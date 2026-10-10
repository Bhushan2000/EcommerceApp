import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';
import 'mock_data_service.dart';

class FirestoreService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // In-memory fallbacks when Firebase is not active
  final List<ProductModel> _mockProducts = MockDataService.getProducts();
  final List<CategoryModel> _mockCategories = MockDataService.getCategories();
  static final List<OrderModel> _globalOrders = [];
  final Map<String, AppUser> _mockUsers = {};

  static const String _localOrdersKey = 'aura_cached_orders';

  // Collections
  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _db.collection('products');
  CollectionReference<Map<String, dynamic>> get _categoriesRef =>
      _db.collection('categories');
  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      _db.collection('orders');
  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection('users');

  // ================= CATEGORIES =================
  Future<List<CategoryModel>> getCategories() async {
    if (FirebaseService.isInitialized) {
      try {
        final snapshot = await _categoriesRef.get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => CategoryModel.fromMap(doc.data(), id: doc.id))
              .toList();
        }
      } catch (e) {
        debugPrint('Firestore getCategories error: $e. Falling back to mock.');
      }
    }
    return _mockCategories;
  }

  // ================= PRODUCTS =================
  Future<List<ProductModel>> getProducts() async {
    if (FirebaseService.isInitialized) {
      try {
        final snapshot = await _productsRef.get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data(), id: doc.id))
              .toList();
        }
      } catch (e) {
        debugPrint('Firestore getProducts error: $e. Falling back to mock.');
      }
    }
    return _mockProducts;
  }

  Future<ProductModel?> getProductById(String id) async {
    if (FirebaseService.isInitialized) {
      try {
        final doc = await _productsRef.doc(id).get();
        if (doc.exists && doc.data() != null) {
          return ProductModel.fromMap(doc.data()!, id: doc.id);
        }
      } catch (e) {
        debugPrint('Firestore getProductById error: $e');
      }
    }
    try {
      return _mockProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addProductReview(String productId, ReviewModel review) async {
    if (FirebaseService.isInitialized) {
      try {
        await _productsRef.doc(productId).update({
          'reviews': FieldValue.arrayUnion([review.toMap()]),
        });
        return;
      } catch (e) {
        debugPrint('Firestore addProductReview error: $e');
      }
    }

    final index = _mockProducts.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final updatedReviews = List<ReviewModel>.from(_mockProducts[index].reviews)
        ..add(review);
      final newRating = updatedReviews.map((r) => r.rating).reduce((a, b) => a + b) /
          updatedReviews.length;
      _mockProducts[index] = _mockProducts[index].copyWith(
        reviews: updatedReviews,
        rating: double.parse(newRating.toStringAsFixed(1)),
        reviewCount: updatedReviews.length,
      );
    }
  }

  // ================= ORDERS =================

  /// Persist orders to local storage (SharedPreferences)
  Future<void> _saveOrdersLocally(List<OrderModel> orders) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = orders.map((o) => o.toMap()).toList();
      await prefs.setString(_localOrdersKey, jsonEncode(listJson));
    } catch (e) {
      debugPrint('Error saving orders locally: $e');
    }
  }

  /// Load orders from local storage
  Future<List<OrderModel>> _loadOrdersLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localOrdersKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw);
        return decoded
            .map((item) => OrderModel.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error reading orders from local cache: $e');
    }
    return [];
  }

  Future<String> placeOrder(OrderModel order) async {
    // 1. Immediately cache in memory
    _globalOrders.removeWhere((o) => o.id == order.id);
    _globalOrders.insert(0, order);

    // 2. Persist in SharedPreferences
    final localOrders = await _loadOrdersLocally();
    localOrders.removeWhere((o) => o.id == order.id);
    localOrders.insert(0, order);
    await _saveOrdersLocally(localOrders);

    // 3. Sync to Cloud Firestore if connected
    if (FirebaseService.isInitialized) {
      try {
        final doc = _ordersRef.doc(order.id.isEmpty ? null : order.id);
        await doc.set(order.toMap());
        debugPrint('✅ Order ${order.id} placed to Cloud Firestore!');
        return doc.id;
      } catch (e) {
        debugPrint('Firestore placeOrder error: $e. Saved to local persistent cache.');
      }
    }

    return order.id;
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    final Map<String, OrderModel> merged = {};

    // 1. Load from SharedPreferences
    final localOrders = await _loadOrdersLocally();
    for (final o in localOrders) {
      merged[o.id] = o;
    }

    // 2. Load from global in-memory list
    for (final o in _globalOrders) {
      merged[o.id] = o;
    }

    // 3. Fetch from Cloud Firestore if available
    if (FirebaseService.isInitialized) {
      try {
        // Query orders without composite index constraints (sort in memory)
        final snapshot = await _ordersRef.get();
        for (final doc in snapshot.docs) {
          final order = OrderModel.fromMap(doc.data(), id: doc.id);
          // Match by userId or show if user matches or if guest
          if (userId.isEmpty ||
              userId == 'guest_shopper' ||
              order.userId == userId ||
              order.userId == 'guest_shopper' ||
              order.userId.isEmpty) {
            merged[order.id] = order;
          }
        }
      } catch (e) {
        debugPrint('Firestore getUserOrders error: $e. Utilizing cached orders.');
      }
    }

    // If still no orders (e.g. brand new fresh install before placing any order),
    // provide sample tracking orders so the user can immediately experience the workflow!
    if (merged.isEmpty) {
      final sample1 = OrderModel(
        id: 'ORD-781A92BF',
        userId: userId.isNotEmpty ? userId : 'guest_shopper',
        userEmail: 'alex.shopper@example.com',
        items: [
          CartItemModel(
            id: 'item_sample_1',
            product: _mockProducts.first,
            quantity: 1,
            selectedColor: 'Obsidian Black',
            selectedSize: 'Standard',
          ),
        ],
        subtotal: _mockProducts.first.price,
        discount: 0.0,
        tax: _mockProducts.first.price * 0.08,
        shippingFee: 0.0,
        total: _mockProducts.first.price * 1.08,
        shippingAddress: '742 Evergreen Terrace, Springfield, OR 97477',
        paymentMethod: 'Credit / Debit Card',
        status: OrderStatus.shipped,
        createdAt: DateTime.now().subtract(const Duration(hours: 14)),
      );

      final sample2 = OrderModel(
        id: 'ORD-549C10AA',
        userId: userId.isNotEmpty ? userId : 'guest_shopper',
        userEmail: 'alex.shopper@example.com',
        items: [
          CartItemModel(
            id: 'item_sample_2',
            product: _mockProducts.length > 1 ? _mockProducts[1] : _mockProducts.first,
            quantity: 2,
            selectedColor: 'Navy Blue',
            selectedSize: 'M',
          ),
        ],
        subtotal: (_mockProducts.length > 1 ? _mockProducts[1].price : _mockProducts.first.price) * 2,
        discount: 20.0,
        tax: 15.0,
        shippingFee: 0.0,
        total: ((_mockProducts.length > 1 ? _mockProducts[1].price : _mockProducts.first.price) * 2) - 5.0,
        shippingAddress: '742 Evergreen Terrace, Springfield, OR 97477',
        paymentMethod: 'Apple Pay / Google Pay',
        status: OrderStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      );

      merged[sample1.id] = sample1;
      merged[sample2.id] = sample2;
      await _saveOrdersLocally([sample1, sample2]);
    }

    final resultList = merged.values.toList();
    // Sort in memory by descending creation time
    resultList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Update local cache
    await _saveOrdersLocally(resultList);

    return resultList;
  }

  /// Update order tracking status (e.g. ship, deliver, cancel, refund, exchange)
  Future<OrderModel?> updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    String? cancellationReason,
    String? refundReason,
    String? exchangeReason,
    String? note,
  }) async {
    final orders = await _loadOrdersLocally();
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index == -1 && _globalOrders.indexWhere((o) => o.id == orderId) == -1) {
      return null;
    }

    final targetOrder = index != -1
        ? orders[index]
        : _globalOrders.firstWhere((o) => o.id == orderId);

    final updatedTimeline = List<OrderTimelineEvent>.from(targetOrder.timeline);
    updatedTimeline.add(
      OrderTimelineEvent(
        title: newStatus.displayName,
        description: note ?? 'Status updated to ${newStatus.displayName}',
        timestamp: DateTime.now(),
        isCompleted: true,
      ),
    );

    final updatedOrder = targetOrder.copyWith(
      status: newStatus,
      cancellationReason: cancellationReason ?? targetOrder.cancellationReason,
      refundReason: refundReason ?? targetOrder.refundReason,
      exchangeReason: exchangeReason ?? targetOrder.exchangeReason,
      timeline: updatedTimeline,
    );

    // Update in memory
    final gIdx = _globalOrders.indexWhere((o) => o.id == orderId);
    if (gIdx != -1) {
      _globalOrders[gIdx] = updatedOrder;
    } else {
      _globalOrders.insert(0, updatedOrder);
    }

    // Update local storage
    if (index != -1) {
      orders[index] = updatedOrder;
    } else {
      orders.insert(0, updatedOrder);
    }
    await _saveOrdersLocally(orders);

    // Sync to Firestore
    if (FirebaseService.isInitialized) {
      try {
        await _ordersRef.doc(orderId).set(updatedOrder.toMap(), SetOptions(merge: true));
        debugPrint('✅ Order $orderId status updated in Firestore to ${newStatus.name}');
      } catch (e) {
        debugPrint('Firestore updateOrderStatus error: $e');
      }
    }

    return updatedOrder;
  }

  // ================= USER PROFILE =================
  Future<void> saveUserProfile(AppUser user) async {
    if (FirebaseService.isInitialized) {
      try {
        await _usersRef.doc(user.id).set(user.toMap(), SetOptions(merge: true));
        return;
      } catch (e) {
        debugPrint('Firestore saveUserProfile error: $e');
      }
    }
    _mockUsers[user.id] = user;
  }

  Future<AppUser?> getUserProfile(String userId) async {
    if (FirebaseService.isInitialized) {
      try {
        final doc = await _usersRef.doc(userId).get();
        if (doc.exists && doc.data() != null) {
          return AppUser.fromMap(doc.data()!, id: doc.id);
        }
      } catch (e) {
        debugPrint('Firestore getUserProfile error: $e');
      }
    }
    return _mockUsers[userId];
  }

  // ================= SEED DATA TO FIRESTORE =================
  Future<String?> seedInitialDataToFirestore() async {
    if (!FirebaseService.isInitialized) {
      return 'Firebase is not initialized. If you just configured Firebase, please perform a full app restart.';
    }
    try {
      final batch = _db.batch();

      // Seed categories
      for (final cat in MockDataService.getCategories()) {
        final docRef = _categoriesRef.doc(cat.id);
        batch.set(docRef, cat.toMap());
      }

      // Seed products
      for (final prod in MockDataService.getProducts()) {
        final docRef = _productsRef.doc(prod.id);
        batch.set(docRef, prod.toMap());
      }

      await batch.commit();
      debugPrint('🎉 Successfully seeded initial data to Cloud Firestore!');
      return null;
    } catch (e) {
      debugPrint('Failed to seed Firestore data: $e');
      final errorStr = e.toString();
      if (errorStr.contains('permission-denied') || errorStr.contains('PERMISSION_DENIED')) {
        return 'Permission Denied: Go to Firebase Console > Firestore Database > Rules and set "allow read, write: if true;".';
      }
      if (errorStr.contains('not-found') || errorStr.contains('NOT_FOUND') || errorStr.contains('database (default) does not exist')) {
        return 'Database not created yet: Go to Firebase Console > Build > Firestore Database and click "Create Database".';
      }
      return errorStr;
    }
  }
}
