import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/product_card.dart';

class CategoryProductsScreen extends StatelessWidget {
  final CategoryModel category;

  const CategoryProductsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products
        .where((p) => p.categoryId == category.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
      ),
      body: products.isEmpty
          ? EmptyStateView(
              icon: category.iconData,
              title: 'No products found',
              description:
                  'We are currently restocking products in the ${category.name} category.',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.54,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductCard(product: products[index]);
              },
            ),
    );
  }
}
