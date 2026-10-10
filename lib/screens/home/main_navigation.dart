import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../utils/constants.dart';
import '../cart/cart_screen.dart';
import '../catalog/search_screen.dart';
import '../profile/profile_screen.dart';
import '../wishlist/wishlist_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    WishlistScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border(
            top: BorderSide(
              color: AppColors.border(context),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 50 : 10),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: NavigationBar(
            height: 68,
            elevation: 0,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: AppColors.card(context),
            indicatorColor: AppColors.primary.withAlpha(isDark ? 45 : 30),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.search_rounded),
                selectedIcon: Icon(Icons.search_rounded, color: AppColors.primary),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: wishlist.count > 0,
                  label: Text('${wishlist.count}'),
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  backgroundColor: AppColors.secondary,
                  child: const Icon(Icons.favorite_border_rounded),
                ),
                selectedIcon: Badge(
                  isLabelVisible: wishlist.count > 0,
                  label: Text('${wishlist.count}'),
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  backgroundColor: AppColors.secondary,
                  child: const Icon(Icons.favorite_rounded, color: AppColors.secondary),
                ),
                label: 'Wishlist',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: cart.itemCount > 0,
                  label: Text('${cart.itemCount}'),
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: cart.itemCount > 0,
                  label: Text('${cart.itemCount}'),
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.shopping_bag_rounded, color: AppColors.primary),
                ),
                label: 'Cart',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
