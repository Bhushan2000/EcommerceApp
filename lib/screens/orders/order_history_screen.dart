import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../widgets/empty_state_view.dart';
import 'order_details_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      context.read<OrderProvider>().loadUserOrders(user?.id ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Orders',
            onPressed: () {
              final user = context.read<AuthProvider>().user;
              orderProvider.loadUserOrders(user?.id ?? '');
            },
          ),
        ],
      ),
      body: orderProvider.isLoading && orderProvider.orders.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : orderProvider.orders.isEmpty
              ? EmptyStateView(
                  icon: Icons.receipt_long_outlined,
                  title: 'No Orders Placed Yet',
                  description:
                      'You haven\'t placed any orders yet. Start exploring our catalog to find products you love!',
                  buttonText: 'Browse Catalog',
                  onButtonPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    final user = context.read<AuthProvider>().user;
                    await orderProvider.loadUserOrders(user?.id ?? '');
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: orderProvider.orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final order = orderProvider.orders[index];
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailsScreen(order: order),
                            ),
                          );
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card(context),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.border(context),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(isDark ? 25 : 6),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Order ID & Status Badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.receipt_rounded,
                                          size: 18, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        order.id,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: order.status.statusColor.withAlpha(25),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: order.status.statusColor.withAlpha(60),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          order.status.icon,
                                          size: 13,
                                          color: order.status.statusColor,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          order.status.displayName,
                                          style: TextStyle(
                                            color: order.status.statusColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    Formatters.formatDateTime(order.createdAt),
                                    style: TextStyle(
                                      color: AppColors.textSecondary(context),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    order.trackingNumber,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primary.withAlpha(200),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Items thumbnail preview row
                              if (order.items.isNotEmpty)
                                SizedBox(
                                  height: 54,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: order.items.length > 4 ? 4 : order.items.length,
                                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                                    itemBuilder: (context, i) {
                                      final it = order.items[i];
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          width: 54,
                                          height: 54,
                                          color: isDark ? Colors.white10 : Colors.grey.shade100,
                                          child: CachedNetworkImage(
                                            imageUrl: it.product.mainImage,
                                            fit: BoxFit.cover,
                                            errorWidget: (_, _, _) => const Icon(
                                              Icons.image_not_supported_outlined,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                              const Divider(height: 22),

                              Row(
                                children: [
                                  Text(
                                    '${order.items.length} ${order.items.length == 1 ? "item" : "items"}',
                                    style: TextStyle(
                                      color: AppColors.textSecondary(context),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    Formatters.formatCurrency(order.total),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                      color: AppColors.primary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
