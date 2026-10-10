import 'product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  int quantity;
  final String? selectedColor;
  final String? selectedSize;

  CartItemModel({
    required this.id,
    required this.product,
    this.quantity = 1,
    this.selectedColor,
    this.selectedSize,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(),
      'quantity': quantity,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] ?? '',
      product: ProductModel.fromMap(Map<String, dynamic>.from(map['product'] ?? {})),
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      selectedColor: map['selectedColor'],
      selectedSize: map['selectedSize'],
    );
  }

  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
    String? selectedColor,
    String? selectedSize,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
    );
  }
}
