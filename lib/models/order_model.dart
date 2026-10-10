import 'package:flutter/material.dart';
import 'cart_item_model.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
  refunded,
  exchanged;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Order Placed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
      case OrderStatus.exchanged:
        return 'Exchanged';
    }
  }

  Color get statusColor {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFFF59E0B); // Amber
      case OrderStatus.processing:
        return const Color(0xFF3B82F6); // Blue
      case OrderStatus.shipped:
        return const Color(0xFF8B5CF6); // Purple
      case OrderStatus.outForDelivery:
        return const Color(0xFF06B6D4); // Cyan
      case OrderStatus.delivered:
        return const Color(0xFF10B981); // Emerald Green
      case OrderStatus.cancelled:
        return const Color(0xFFEF4444); // Red
      case OrderStatus.refunded:
        return const Color(0xFFEC4899); // Pink / Coral
      case OrderStatus.exchanged:
        return const Color(0xFF6366F1); // Indigo
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.shopping_bag_outlined;
      case OrderStatus.processing:
        return Icons.inventory_2_outlined;
      case OrderStatus.shipped:
        return Icons.local_shipping_outlined;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining_outlined;
      case OrderStatus.delivered:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
      case OrderStatus.refunded:
        return Icons.currency_exchange_rounded;
      case OrderStatus.exchanged:
        return Icons.swap_horiz_rounded;
    }
  }

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'outfordelivery':
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
      case 'refunded':
      case 'refund':
        return OrderStatus.refunded;
      case 'exchanged':
      case 'exchange':
        return OrderStatus.exchanged;
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderTimelineEvent {
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isCompleted;

  OrderTimelineEvent({
    required this.title,
    required this.description,
    required this.timestamp,
    this.isCompleted = true,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'isCompleted': isCompleted,
      };

  factory OrderTimelineEvent.fromMap(Map<String, dynamic> map) =>
      OrderTimelineEvent(
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        timestamp: map['timestamp'] != null
            ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
            : DateTime.now(),
        isCompleted: map['isCompleted'] ?? true,
      );
}

class OrderModel {
  final String id;
  final String userId;
  final String userEmail;
  final List<CartItemModel> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double shippingFee;
  final double total;
  final String shippingAddress;
  final String paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;
  final String trackingNumber;
  final String carrier;
  final String? cancellationReason;
  final String? refundReason;
  final String? exchangeReason;
  final List<OrderTimelineEvent> timeline;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.shippingFee,
    required this.total,
    required this.shippingAddress,
    required this.paymentMethod,
    this.status = OrderStatus.processing,
    DateTime? createdAt,
    String? trackingNumber,
    String? carrier,
    this.cancellationReason,
    this.refundReason,
    this.exchangeReason,
    List<OrderTimelineEvent>? timeline,
  })  : createdAt = createdAt ?? DateTime.now(),
        trackingNumber = trackingNumber ?? 'AURA-${id.replaceAll('ORD-', '')}-EXP',
        carrier = carrier ?? 'Aura Priority Courier',
        timeline = timeline ?? _generateDefaultTimeline(status, createdAt ?? DateTime.now());

  static List<OrderTimelineEvent> _generateDefaultTimeline(
      OrderStatus status, DateTime orderDate) {
    final list = <OrderTimelineEvent>[
      OrderTimelineEvent(
        title: 'Order Placed',
        description: 'Your order was successfully verified and received.',
        timestamp: orderDate,
        isCompleted: true,
      ),
    ];

    if (status != OrderStatus.pending && status != OrderStatus.cancelled) {
      list.add(
        OrderTimelineEvent(
          title: 'Order Processing',
          description: 'Items packed in warehouse & shipping label generated.',
          timestamp: orderDate.add(const Duration(minutes: 35)),
          isCompleted: true,
        ),
      );
    }

    if (status == OrderStatus.shipped ||
        status == OrderStatus.outForDelivery ||
        status == OrderStatus.delivered ||
        status == OrderStatus.refunded ||
        status == OrderStatus.exchanged) {
      list.add(
        OrderTimelineEvent(
          title: 'Shipped & In Transit',
          description: 'Package departed carrier sorting facility.',
          timestamp: orderDate.add(const Duration(hours: 4)),
          isCompleted: true,
        ),
      );
    }

    if (status == OrderStatus.outForDelivery ||
        status == OrderStatus.delivered ||
        status == OrderStatus.refunded ||
        status == OrderStatus.exchanged) {
      list.add(
        OrderTimelineEvent(
          title: 'Out for Delivery',
          description: 'Courier agent is en route to your shipping address.',
          timestamp: orderDate.add(const Duration(hours: 18)),
          isCompleted: true,
        ),
      );
    }

    if (status == OrderStatus.delivered ||
        status == OrderStatus.refunded ||
        status == OrderStatus.exchanged) {
      list.add(
        OrderTimelineEvent(
          title: 'Delivered',
          description: 'Package handed to recipient with signature confirmation.',
          timestamp: orderDate.add(const Duration(hours: 24)),
          isCompleted: true,
        ),
      );
    }

    if (status == OrderStatus.cancelled) {
      list.add(
        OrderTimelineEvent(
          title: 'Order Cancelled',
          description: 'Order was cancelled per customer request. Refund initiated.',
          timestamp: orderDate.add(const Duration(minutes: 15)),
          isCompleted: true,
        ),
      );
    }

    if (status == OrderStatus.refunded) {
      list.add(
        OrderTimelineEvent(
          title: 'Refund Issued',
          description: 'Return inspected and full refund issued to original payment method.',
          timestamp: orderDate.add(const Duration(days: 2)),
          isCompleted: true,
        ),
      );
    }

    if (status == OrderStatus.exchanged) {
      list.add(
        OrderTimelineEvent(
          title: 'Exchange Replacement Shipped',
          description: 'Replacement item was verified and dispatched.',
          timestamp: orderDate.add(const Duration(days: 2)),
          isCompleted: true,
        ),
      );
    }

    return list;
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? userEmail,
    List<CartItemModel>? items,
    double? subtotal,
    double? discount,
    double? tax,
    double? shippingFee,
    double? total,
    String? shippingAddress,
    String? paymentMethod,
    OrderStatus? status,
    DateTime? createdAt,
    String? trackingNumber,
    String? carrier,
    String? cancellationReason,
    String? refundReason,
    String? exchangeReason,
    List<OrderTimelineEvent>? timeline,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      shippingFee: shippingFee ?? this.shippingFee,
      total: total ?? this.total,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      carrier: carrier ?? this.carrier,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      refundReason: refundReason ?? this.refundReason,
      exchangeReason: exchangeReason ?? this.exchangeReason,
      timeline: timeline ?? this.timeline,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'shippingFee': shippingFee,
      'total': total,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'trackingNumber': trackingNumber,
      'carrier': carrier,
      'cancellationReason': cancellationReason,
      'refundReason': refundReason,
      'exchangeReason': exchangeReason,
      'timeline': timeline.map((e) => e.toMap()).toList(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    final parsedItems = rawItems
        .map((i) => CartItemModel.fromMap(Map<String, dynamic>.from(i)))
        .toList();

    final rawTimeline = map['timeline'] as List<dynamic>? ?? [];
    final parsedTimeline = rawTimeline
        .map((e) => OrderTimelineEvent.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    final orderStatus = OrderStatus.fromString(map['status'] ?? 'processing');
    final orderDate = map['createdAt'] != null
        ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
        : DateTime.now();

    return OrderModel(
      id: id ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      items: parsedItems,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (map['tax'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (map['shippingFee'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      shippingAddress: map['shippingAddress'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'Credit Card',
      status: orderStatus,
      createdAt: orderDate,
      trackingNumber: map['trackingNumber'],
      carrier: map['carrier'],
      cancellationReason: map['cancellationReason'],
      refundReason: map['refundReason'],
      exchangeReason: map['exchangeReason'],
      timeline: parsedTimeline.isNotEmpty
          ? parsedTimeline
          : _generateDefaultTimeline(orderStatus, orderDate),
    );
  }
}
