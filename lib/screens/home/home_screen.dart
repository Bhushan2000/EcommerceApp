import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/firebase_service.dart';
import '../../utils/constants.dart';
import '../../widgets/banner_carousel.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/product_card.dart';
import '../catalog/search_screen.dart';
import '../checkout/map_address_picker_screen.dart';
import '../orders/order_details_screen.dart';
import '../profile/firebase_config_info_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddressSelector(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final user = auth.user;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Choose Delivery Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Current Address Tile
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Selected Address',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.fullAddress ?? '742 Evergreen Terrace, Springfield, OR',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Pick on Map Action
              OutlinedButton.icon(
                icon: const Icon(Icons.map_rounded, color: AppColors.primary),
                label: const Text(
                  'Select Pin Location from Map',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final result = await Navigator.push<Map<String, String>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapAddressPickerScreen(
                        initialStreet: user?.street,
                        initialCity: user?.city,
                        initialState: user?.state,
                        initialZip: user?.zipCode,
                      ),
                    ),
                  );

                  if (result != null && context.mounted) {
                    final updatedUser = (user ??
                            AppUser(
                              id: 'demo_user_1',
                              email: 'alex.shopper@example.com',
                              displayName: 'Alex Morgan',
                            ))
                        .copyWith(
                      street: result['street'],
                      city: result['city'],
                      state: result['state'],
                      zipCode: result['zip'],
                      country: result['country'],
                    );
                    await auth.updateProfile(updatedUser);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Delivery address set: ${result['street']}, ${result['city']}',
                              ),
                            ),
                          ],
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.success,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                }
              },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showNotifications(BuildContext context) {
    final orders = context.read<OrderProvider>().orders;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Notifications & Order Updates',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (orders.isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: orders.first.status.statusColor.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(orders.first.status.icon,
                        color: orders.first.status.statusColor, size: 20),
                  ),
                  title: Text(
                    'Order ${orders.first.id}: ${orders.first.status.displayName}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(
                    'Tracking ID: ${orders.first.trackingNumber}. Tap to view live tracking progress.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailsScreen(order: orders.first),
                      ),
                    );
                  },
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_offer_rounded,
                      color: AppColors.secondary, size: 20),
                ),
                title: const Text(
                  'Exclusive Coupon: SAVE20',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  'Enjoy 20% off on your entire shopping cart today!',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = auth.user;

    final displayAddress = user != null && user.street != null && user.street!.isNotEmpty
        ? '${user.street}, ${user.city ?? ""}'
        : '742 Evergreen Terrace, Springfield';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await productProvider.loadData();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Top Location Bar (Amazon / Blinkit Style)
              SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () => _showAddressSelector(context),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Deliver to: $displayAddress',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Greeting & Action Buttons Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.user != null
                                ? 'Hello, ${auth.user!.displayName.split(' ').first} 👋'
                                : 'Welcome to Aura 👋',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppConstants.appTagline,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Notification Bell with Badge
                          GestureDetector(
                            onTap: () => _showNotifications(context),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.cardDark : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? Colors.white12 : Colors.grey.shade200,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(isDark ? 25 : 5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.notifications_outlined,
                                    size: 20,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.secondary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // User Avatar Link to Profile
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ProfileScreen()),
                              );
                            },
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppGradients.primaryGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(70),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  auth.user != null && auth.user!.displayName.isNotEmpty
                                      ? auth.user!.displayName[0].toUpperCase()
                                      : 'A',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Interactive Search Bar Trigger
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SearchScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.grey.shade200,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(isDark ? 30 : 6),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: isDark ? Colors.white60 : Colors.grey.shade500,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Search products, brands, deals...',
                              style: TextStyle(
                                color: isDark ? Colors.white38 : Colors.grey.shade400,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Firebase Mode Indicator Pill
              if (!FirebaseService.isInitialized)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FirebaseConfigInfoScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary.withAlpha(45),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.cloud_outlined, size: 18, color: AppColors.primary),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Local Catalog Active • Tap to connect Firestore database',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 12, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Banner Carousel
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
                  child: BannerCarousel(),
                ),
              ),

              // Categories Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (productProvider.selectedCategory != null)
                        GestureDetector(
                          onTap: () => productProvider.selectCategory(null),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Clear Filter',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.close_rounded, size: 12, color: AppColors.primary),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Categories Horizontal List
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: SizedBox(
                    height: 50,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: productProvider.categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final cat = productProvider.categories[index];
                        final isSelected = productProvider.selectedCategory == cat.id;
                        return CategoryChip(
                          category: cat,
                          isSelected: isSelected,
                          onTap: () {
                            productProvider.selectCategory(cat.id);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Flash Deals / Featured Section
              if (productProvider.flashSaleProducts.isNotEmpty &&
                  productProvider.selectedCategory == null) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '⚡ Flash Deals',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Visually balanced Ember & Rose Countdown Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF43F5E), Color(0xFFFB7185)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary.withAlpha(50),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.timer_outlined, size: 12, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    '04 : 28 : 15',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Up to 50% Off',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 310,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: productProvider.flashSaleProducts.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: 175,
                          child: ProductCard(
                            product: productProvider.flashSaleProducts[index],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

              // All / Filtered Products Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        productProvider.selectedCategory != null
                            ? 'Selected Category'
                            : 'Popular Products',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          '${productProvider.filteredProducts.length} items',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Product Grid
              if (productProvider.isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                )
              else if (productProvider.filteredProducts.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No products found in this category',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try choosing another category or clearing your filter.',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => productProvider.selectCategory(null),
                          child: const Text('View All Categories'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.54,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ProductCard(
                          product: productProvider.filteredProducts[index],
                        );
                      },
                      childCount: productProvider.filteredProducts.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 48),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
