import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final productProvider = context.watch<ProductProvider>();
    final items = wishlist.getWishlistProducts(productProvider.products);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Wishlist', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${items.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
      body: items.isEmpty
          ? EmptyStateView(
              icon: Icons.favorite_border_rounded,
              title: 'Your Wishlist is Empty',
              description:
                  'Save your favorite products to keep track of items you love and want to purchase later.',
              buttonText: 'Discover Products',
              onButtonPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            )
          : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.54,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final product = items[index];
                return ProductCard(
                  product: product,
                  heroTag: 'wishlist_${product.id}',
                );
              },
            ),
    );
  }
}
