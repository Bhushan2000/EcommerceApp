import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../screens/catalog/product_details_screen.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isCardPressed = false;
  bool _isWishlistBouncing = false;

  void _onWishlistTap(WishlistProvider wishlistProvider, bool isWishlisted) {
    setState(() => _isWishlistBouncing = true);
    wishlistProvider.toggleWishlist(widget.product.id);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _isWishlistBouncing = false);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isWishlisted ? 'Removed from wishlist' : 'Saved to wishlist ❤️',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = context.watch<WishlistProvider>();
    final cartProvider = context.read<CartProvider>();
    final isWishlisted = wishlistProvider.isInWishlist(widget.product.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isCardPressed = true),
      onTapUp: (_) {
        setState(() => _isCardPressed = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: widget.product),
          ),
        );
      },
      onTapCancel: () => setState(() => _isCardPressed = false),
      child: AnimatedScale(
        scale: _isCardPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(AppStyles.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
            boxShadow: AppStyles.softShadow(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Image Container with badges and wishlist button
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppStyles.radiusMd - 1),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.25,
                      child: Hero(
                        tag: 'product_img_${widget.product.id}',
                        child: CachedNetworkImage(
                          imageUrl: widget.product.mainImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: isDark
                                ? AppColors.cardDarkElevated
                                : Colors.grey.shade100,
                            child: const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: isDark
                                ? AppColors.cardDarkElevated
                                : Colors.grey.shade100,
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Top subtle gradient shadow on image for badge contrast
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppStyles.radiusMd - 1),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black.withAlpha(50),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Discount Badge
                  if (widget.product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.secondaryGradient,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withAlpha(60),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '-${widget.product.discountPercentage}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                  // Wishlist Button with heart bounce
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () =>
                          _onWishlistTap(wishlistProvider, isWishlisted),
                      child: AnimatedScale(
                        scale: _isWishlistBouncing ? 1.3 : 1.0,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutBack,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.black : Colors.white)
                                .withAlpha(210),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            isWishlisted
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 17,
                            color: isWishlisted
                                ? AppColors.secondary
                                : (isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Product Details
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category tag
                    Text(
                      widget.product.categoryName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.9,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    // Product Title
                    Text(
                      widget.product.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: AppColors.textPrimary(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 15, color: AppColors.accent),
                        const SizedBox(width: 3),
                        Text(
                          widget.product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${widget.product.reviewCount})',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textMuted(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Price and Add to Cart Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Formatters.formatCurrency(widget.product.price),
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                              if (widget.product.hasDiscount)
                                Text(
                                  Formatters.formatCurrency(
                                      widget.product.originalPrice!),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted(context),
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Add Button with subtle gradient
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              cartProvider.addItem(
                                widget.product,
                                selectedColor:
                                    widget.product.availableColors.isNotEmpty
                                        ? widget.product.availableColors.first
                                        : null,
                                selectedSize:
                                    widget.product.availableSizes.isNotEmpty
                                        ? widget.product.availableSizes.first
                                        : null,
                              );
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Added ${widget.product.title} to cart 🛍️'),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  action: SnackBarAction(
                                    label: 'VIEW CART',
                                    textColor: AppColors.accentLight,
                                    onPressed: () {},
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(7.5),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(60),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
