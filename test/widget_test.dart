import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/services/address_lookup_service.dart';

void main() {
  group('E-commerce Business Logic Tests', () {
    test('Cart calculations with discount and tax', () {
      final cart = CartProvider();

      final product = ProductModel(
        id: 'p1',
        title: 'Wireless Headphones',
        description: 'Test description',
        price: 100.0,
        originalPrice: 120.0,
        categoryId: 'cat_electronics',
        categoryName: 'Electronics',
        images: ['https://example.com/img.jpg'],
      );

      // Add 2 items
      cart.addItem(product, quantity: 2);
      expect(cart.itemCount, 2);
      expect(cart.subtotal, 200.0);

      // Apply 20% promo
      final applied = cart.applyPromoCode('SAVE20');
      expect(applied, true);
      expect(cart.discountAmount, 40.0);

      // Tax on 160.0 (8%) = 12.8
      expect(cart.taxAmount, 12.8);

      // Shipping over 100 is 0
      expect(cart.shippingFee, 0.0);

      // Total = 160 + 12.8 = 172.8
      expect(cart.totalAmount, 172.8);
    });

    test('Product discount calculation helper', () {
      final product = ProductModel(
        id: 'p2',
        title: 'Shoes',
        description: 'Test shoes',
        price: 75.0,
        originalPrice: 100.0,
        categoryId: 'cat_sports',
        categoryName: 'Sports',
        images: ['https://example.com/shoe.jpg'],
      );

      expect(product.hasDiscount, true);
      expect(product.discountPercentage, 25);
    });

    test('Address auto-state lookup service', () {
      expect(AddressLookupService.lookupState('Springfield'), 'IL');
      expect(AddressLookupService.lookupState('Portland'), 'OR');
      expect(AddressLookupService.lookupState('Los Angeles'), 'CA');
      expect(AddressLookupService.lookupState('Mumbai'), 'Maharashtra');
      expect(AddressLookupService.lookupState('Bengaluru'), 'Karnataka');
      expect(AddressLookupService.lookupState('New York'), 'NY');
    });

    test('Order status workflow parsing & tracking', () {
      expect(OrderStatus.fromString('shipped'), OrderStatus.shipped);
      expect(OrderStatus.fromString('delivered'), OrderStatus.delivered);
      expect(OrderStatus.fromString('cancelled'), OrderStatus.cancelled);
      expect(OrderStatus.fromString('refunded'), OrderStatus.refunded);
      expect(OrderStatus.fromString('exchanged'), OrderStatus.exchanged);

      final order = OrderModel(
        id: 'ORD-TEST1',
        userId: 'test_u',
        userEmail: 'test@example.com',
        items: [],
        subtotal: 50.0,
        discount: 0.0,
        tax: 4.0,
        shippingFee: 15.0,
        total: 69.0,
        shippingAddress: '123 Test St, Springfield, OR',
        paymentMethod: 'Card',
        status: OrderStatus.processing,
      );

      expect(order.timeline.isNotEmpty, true);
      expect(order.status, OrderStatus.processing);

      final cancelledOrder = order.copyWith(
        status: OrderStatus.cancelled,
        cancellationReason: 'Ordered by mistake',
      );
      expect(cancelledOrder.status, OrderStatus.cancelled);
      expect(cancelledOrder.cancellationReason, 'Ordered by mistake');
    });
  });
}
