import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String iconName; // e.g., 'devices', 'checkroom', 'chair', etc.
  final String imageUrl;
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.imageUrl,
    this.productCount = 0,
  });

  IconData get iconData {
    switch (iconName) {
      case 'electronics':
      case 'devices':
        return Icons.devices;
      case 'fashion':
      case 'clothing':
        return Icons.checkroom;
      case 'home':
      case 'furniture':
        return Icons.chair_outlined;
      case 'beauty':
        return Icons.spa_outlined;
      case 'sports':
      case 'fitness':
        return Icons.fitness_center;
      case 'books':
        return Icons.menu_book_outlined;
      case 'jewelry':
        return Icons.diamond_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'imageUrl': imageUrl,
      'productCount': productCount,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return CategoryModel(
      id: id ?? map['id'] ?? '',
      name: map['name'] ?? '',
      iconName: map['iconName'] ?? 'category',
      imageUrl: map['imageUrl'] ?? '',
      productCount: map['productCount'] ?? 0,
    );
  }
}
