import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _popularKeywords = [
    'Wireless',
    'Leather',
    'Smart Watch',
    'Denim',
    'Running',
    'Audio',
    'Hoodie',
    'Minimalist',
  ];

  @override
  void initState() {
    super.initState();
    final query = context.read<ProductProvider>().searchQuery;
    if (query.isNotEmpty) {
      _searchController.text = query;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterModal(BuildContext context) {
    final productProvider = context.read<ProductProvider>();
    double tempMaxPrice = productProvider.maxPrice ?? 2000.0;
    ProductSortOption tempSort = productProvider.sortOption;
    String? tempCategory = productProvider.selectedCategory;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter & Sort',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          productProvider.resetFilters();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Reset All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: ProductSortOption.values.map((opt) {
                      final isSelected = tempSort == opt;
                      return ChoiceChip(
                        label: Text(opt.displayName),
                        selected: isSelected,
                        selectedColor: AppColors.primary.withAlpha(35),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : null,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) {
                          setModalState(() {
                            tempSort = opt;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All Categories'),
                        selected: tempCategory == null,
                        selectedColor: AppColors.primary.withAlpha(35),
                        labelStyle: TextStyle(
                          color: tempCategory == null ? AppColors.primary : null,
                          fontWeight: tempCategory == null ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) {
                          setModalState(() {
                            tempCategory = null;
                          });
                        },
                      ),
                      ...productProvider.categories.map((c) {
                        final isSelected = tempCategory == c.id;
                        return ChoiceChip(
                          label: Text(c.name),
                          selected: isSelected,
                          selectedColor: AppColors.primary.withAlpha(35),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : null,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (_) {
                            setModalState(() {
                              tempCategory = c.id;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Max Price',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(
                        Formatters.formatCurrency(tempMaxPrice),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: tempMaxPrice,
                    min: 20.0,
                    max: 2000.0,
                    divisions: 40,
                    activeColor: AppColors.primary,
                    label: Formatters.formatCurrency(tempMaxPrice),
                    onChanged: (val) {
                      setModalState(() {
                        tempMaxPrice = val;
                      });
                    },
                  ),
                  const SizedBox(height: 22),
                  CustomButton(
                    text: 'Apply Filters',
                    onPressed: () {
                      productProvider.setSortOption(tempSort);
                      if (productProvider.selectedCategory != tempCategory) {
                        productProvider.selectCategory(tempCategory);
                      }
                      productProvider.setMaxPrice(tempMaxPrice);
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.filteredProducts;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasActiveFilters = productProvider.selectedCategory != null ||
        productProvider.maxPrice != null ||
        productProvider.sortOption != ProductSortOption.featured;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 44,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: false,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search products, tags, brands...',
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey.shade400,
                fontSize: 14,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      icon: Icon(
                        Icons.cancel_rounded,
                        size: 18,
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        productProvider.setSearchQuery('');
                        setState(() {});
                      },
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (query) {
              productProvider.setSearchQuery(query);
              setState(() {});
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: hasActiveFilters ? AppColors.primary : AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.tune_rounded,
                  color: hasActiveFilters ? Colors.white : AppColors.primary,
                  size: 20,
                ),
                onPressed: () => _showFilterModal(context),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular suggestions pill strip if search is empty
          if (_searchController.text.isEmpty && productProvider.selectedCategory == null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Text(
                'Popular Searches',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                scrollDirection: Axis.horizontal,
                itemCount: _popularKeywords.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final word = _popularKeywords[index];
                  return GestureDetector(
                    onTap: () {
                      _searchController.text = word;
                      productProvider.setSearchQuery(word);
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        word,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 20),
          ],

          // Filter summary row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  '${products.length} products found',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    productProvider.sortOption.displayName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search results
          Expanded(
            child: products.isEmpty
                ? EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: 'No products matched',
                    description:
                        'Try searching for "headphones", "watch", "jacket" or adjust your filters.',
                    buttonText: 'Reset Filters',
                    onButtonPressed: () {
                      _searchController.clear();
                      productProvider.resetFilters();
                      setState(() {});
                    },
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.54,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        heroTag: 'search_${product.id}',
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
