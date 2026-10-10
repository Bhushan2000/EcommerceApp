import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';

class OrderProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  OrderProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService() {
    // Initial fetch so orders are immediately ready across the app
    loadUserOrders('');
  }

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> loadUserOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _firestoreService.getUserOrders(userId);
    } catch (e) {
      debugPrint('Error loading orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createOrder(OrderModel order) async {
    _isLoading = true;
    notifyListeners();

    try {
      final orderId = await _firestoreService.placeOrder(order);
      _orders.removeWhere((o) => o.id == order.id);
      _orders.insert(0, order);
      _isLoading = false;
      notifyListeners();
      return orderId;
    } catch (e) {
      debugPrint('Error placing order: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    String? cancellationReason,
    String? refundReason,
    String? exchangeReason,
    String? note,
  }) async {
    try {
      final updated = await _firestoreService.updateOrderStatus(
        orderId,
        newStatus,
        cancellationReason: cancellationReason,
        refundReason: refundReason,
        exchangeReason: exchangeReason,
        note: note,
      );

      if (updated != null) {
        final idx = _orders.indexWhere((o) => o.id == orderId);
        if (idx != -1) {
          _orders[idx] = updated;
        } else {
          _orders.insert(0, updated);
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
    }
    return false;
  }
}
