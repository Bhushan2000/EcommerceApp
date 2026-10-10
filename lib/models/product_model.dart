import 'review_model.dart';

class ProductModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? originalPrice;
  final String categoryId;
  final String categoryName;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final int stock;
  final List<String> availableColors;
  final List<String> availableSizes;
  final bool isFeatured;
  final bool isFlashSale;
  final List<String> tags;
  final List<ReviewModel> reviews;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.categoryId,
    required this.categoryName,
    required this.images,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.stock = 25,
    this.availableColors = const [],
    this.availableSizes = const [],
    this.isFeatured = false,
    this.isFlashSale = false,
    this.tags = const [],
    this.reviews = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  String get mainImage => images.isNotEmpty ? images.first : '';

  bool get isInStock => stock > 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'stock': stock,
      'availableColors': availableColors,
      'availableSizes': availableSizes,
      'isFeatured': isFeatured,
      'isFlashSale': isFlashSale,
      'tags': tags,
      'reviews': reviews.map((r) => r.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final rawReviews = map['reviews'] as List<dynamic>? ?? [];
    final parsedReviews = rawReviews
        .map((r) => ReviewModel.fromMap(Map<String, dynamic>.from(r)))
        .toList();

    return ProductModel(
      id: id ?? map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (map['originalPrice'] as num?)?.toDouble(),
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      availableColors: List<String>.from(map['availableColors'] ?? []),
      availableSizes: List<String>.from(map['availableSizes'] ?? []),
      isFeatured: map['isFeatured'] ?? false,
      isFlashSale: map['isFlashSale'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      reviews: parsedReviews,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    double? originalPrice,
    String? categoryId,
    String? categoryName,
    List<String>? images,
    double? rating,
    int? reviewCount,
    int? stock,
    List<String>? availableColors,
    List<String>? availableSizes,
    bool? isFeatured,
    bool? isFlashSale,
    List<String>? tags,
    List<ReviewModel>? reviews,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stock: stock ?? this.stock,
      availableColors: availableColors ?? this.availableColors,
      availableSizes: availableSizes ?? this.availableSizes,
      isFeatured: isFeatured ?? this.isFeatured,
      isFlashSale: isFlashSale ?? this.isFlashSale,
      tags: tags ?? this.tags,
      reviews: reviews ?? this.reviews,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
