import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../utils/constants.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItemModel> _items = {};
  String? _appliedPromoCode;
  double _discountPercentage = 0.0;

  Map<String, CartItemModel> get items => _items;
  List<CartItemModel> get itemList => _items.values.toList();

  int get itemCount {
    int total = 0;
    for (var item in _items.values) {
      total += item.quantity;
    }
    return total;
  }

  bool get isEmpty => _items.isEmpty;

  double get subtotal {
    double total = 0.0;
    for (var item in _items.values) {
      total += item.totalPrice;
    }
    return total;
  }

  String? get appliedPromoCode => _appliedPromoCode;
  double get discountPercentage => _discountPercentage;

  double get discountAmount => subtotal * _discountPercentage;

  double get shippingFee {
    if (isEmpty) return 0.0;
    if (subtotal >= AppConstants.freeShippingThreshold) return 0.0;
    return AppConstants.standardShippingFee;
  }

  double get taxAmount {
    if (isEmpty) return 0.0;
    final taxable = subtotal - discountAmount;
    return taxable > 0 ? taxable * AppConstants.taxRate : 0.0;
  }

  double get totalAmount {
    if (isEmpty) return 0.0;
    final total = (subtotal - discountAmount) + taxAmount + shippingFee;
    return total > 0 ? total : 0.0;
  }

  String _generateKey(String productId, String? color, String? size) {
    return '${productId}_${color ?? "default"}_${size ?? "default"}';
  }

  void addItem(
    ProductModel product, {
    int quantity = 1,
    String? selectedColor,
    String? selectedSize,
  }) {
    final key = _generateKey(product.id, selectedColor, selectedSize);

    if (_items.containsKey(key)) {
      _items[key]!.quantity += quantity;
    } else {
      _items[key] = CartItemModel(
        id: key,
        product: product,
        quantity: quantity,
        selectedColor: selectedColor,
        selectedSize: selectedSize,
      );
    }
    notifyListeners();
  }

  void updateQuantity(String cartItemId, int newQuantity) {
    if (_items.containsKey(cartItemId)) {
      if (newQuantity <= 0) {
        _items.remove(cartItemId);
      } else {
        _items[cartItemId]!.quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void removeItem(String cartItemId) {
    _items.remove(cartItemId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedPromoCode = null;
    _discountPercentage = 0.0;
    notifyListeners();
  }

  bool applyPromoCode(String code) {
    final clean = code.trim().toUpperCase();
    if (AppConstants.promoCodes.containsKey(clean)) {
      _appliedPromoCode = clean;
      _discountPercentage = AppConstants.promoCodes[clean]!;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removePromoCode() {
    _appliedPromoCode = null;
    _discountPercentage = 0.0;
    notifyListeners();
  }
}
