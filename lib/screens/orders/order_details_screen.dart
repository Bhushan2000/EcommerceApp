import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../widgets/custom_button.dart';
import '../catalog/product_details_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late OrderModel _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  void _showCancelDialog() {
    String selectedReason = 'Ordered by mistake';
    final customReasonController = TextEditingController();

    final reasons = [
      'Ordered by mistake',
      'Need to change shipping address',
      'Found better price elsewhere',
      'Delivery time is too long',
      'Other reason',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
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
                  const Text(
                    'Cancel Order',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Please select the reason for cancelling order ${_currentOrder.id}. Any payments made will be refunded within 2-3 business days.',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RadioGroup<String>(
                    groupValue: selectedReason,
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedReason = val;
                        });
                      }
                    },
                    child: Column(
                      children: reasons.map((r) {
                        return RadioListTile<String>(
                          title: Text(r, style: const TextStyle(fontSize: 14)),
                          value: r,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.error,
                        );
                      }).toList(),
                    ),
                  ),
                  if (selectedReason == 'Other reason') ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: customReasonController,
                      decoration: InputDecoration(
                        hintText: 'Please specify reason...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Confirm Cancellation',
                    icon: Icons.cancel_outlined,
                    onPressed: () async {
                      final reason = selectedReason == 'Other reason'
                          ? customReasonController.text.trim()
                          : selectedReason;

                      final orderProvider = context.read<OrderProvider>();
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final nav = Navigator.of(ctx);

                      final success = await orderProvider.updateOrderStatus(
                            _currentOrder.id,
                            OrderStatus.cancelled,
                            cancellationReason: reason,
                            note: 'Customer requested cancellation: $reason',
                          );

                      if (success && mounted) {
                        nav.pop();
                        final updated = orderProvider
                            .orders
                            .firstWhere((o) => o.id == _currentOrder.id);
                        setState(() {
                          _currentOrder = updated;
                        });
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Text('Order cancelled. Refund initiated to original payment method.'),
                              ],
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.error,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRefundDialog() {
    String refundReason = 'Defective / damaged item';
    final reasons = [
      'Defective / damaged item',
      'Item not as described',
      'Received wrong product',
      'Quality not satisfactory',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Request Return & Refund',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Returns are free within 14 days. Our courier will pick up the package from your delivery address.',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RadioGroup<String>(
                    groupValue: refundReason,
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          refundReason = val;
                        });
                      }
                    },
                    child: Column(
                      children: reasons.map((r) {
                        return RadioListTile<String>(
                          title: Text(r, style: const TextStyle(fontSize: 14)),
                          value: r,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Submit Return Request',
                    icon: Icons.currency_exchange_rounded,
                    onPressed: () async {
                      final orderProvider = context.read<OrderProvider>();
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final nav = Navigator.of(ctx);

                      final success = await orderProvider.updateOrderStatus(
                            _currentOrder.id,
                            OrderStatus.refunded,
                            refundReason: refundReason,
                            note: 'Return pickup initiated: $refundReason',
                          );

                      if (success && mounted) {
                        nav.pop();
                        final updated = orderProvider
                            .orders
                            .firstWhere((o) => o.id == _currentOrder.id);
                        setState(() {
                          _currentOrder = updated;
                        });
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Text('Return pickup scheduled! Refund will be issued upon pickup.'),
                              ],
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.success,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showExchangeDialog() {
    String exchangeReason = 'Need different size / fit';
    final reasons = [
      'Need different size / fit',
      'Prefer different color',
      'Damaged part - replace with same item',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Request Product Exchange',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose your exchange reason. A fresh replacement unit will be dispatched upon return pickup.',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RadioGroup<String>(
                    groupValue: exchangeReason,
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          exchangeReason = val;
                        });
                      }
                    },
                    child: Column(
                      children: reasons.map((r) {
                        return RadioListTile<String>(
                          title: Text(r, style: const TextStyle(fontSize: 14)),
                          value: r,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Confirm Exchange Request',
                    icon: Icons.swap_horiz_rounded,
                    onPressed: () async {
                      final orderProvider = context.read<OrderProvider>();
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final nav = Navigator.of(ctx);

                      final success = await orderProvider.updateOrderStatus(
                            _currentOrder.id,
                            OrderStatus.exchanged,
                            exchangeReason: exchangeReason,
                            note: 'Exchange replacement requested: $exchangeReason',
                          );

                      if (success && mounted) {
                        nav.pop();
                        final updated = orderProvider
                            .orders
                            .firstWhere((o) => o.id == _currentOrder.id);
                        setState(() {
                          _currentOrder = updated;
                        });
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Text('Exchange requested! Replacement item is being dispatched.'),
                              ],
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showTrackingStatusSimulator() {
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
              const Row(
                children: [
                  Icon(Icons.tune_rounded, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Simulate Tracking Workflow',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Test any stage of the order lifecycle in real-time:',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: OrderStatus.values.map((status) {
                  final isCurrent = _currentOrder.status == status;
                  return ActionChip(
                    avatar: Icon(status.icon, size: 14, color: isCurrent ? Colors.white : status.statusColor),
                    label: Text(status.displayName),
                    labelStyle: TextStyle(
                      color: isCurrent ? Colors.white : status.statusColor,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    backgroundColor: isCurrent ? status.statusColor : status.statusColor.withAlpha(20),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final orderProvider = context.read<OrderProvider>();
                      await orderProvider.updateOrderStatus(
                            _currentOrder.id,
                            status,
                            note: 'Simulated stage transition: ${status.displayName}',
                          );
                      if (!mounted) return;
                      final updated = orderProvider
                          .orders
                          .firstWhere((o) => o.id == _currentOrder.id);
                      setState(() {
                        _currentOrder = updated;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order ${_currentOrder.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: 'Workflow Tools',
            onPressed: _showTrackingStatusSimulator,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _currentOrder.status.statusColor.withAlpha(isDark ? 25 : 18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _currentOrder.status.statusColor.withAlpha(70),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _currentOrder.status.statusColor.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _currentOrder.status.icon,
                          color: _currentOrder.status.statusColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentOrder.status.displayName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _currentOrder.status.statusColor,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Placed on ${Formatters.formatDateTime(_currentOrder.createdAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  // Carrier and Tracking ID row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tracking Number',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _currentOrder.trackingNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.copy_rounded, size: 14),
                        label: const Text('Copy', style: TextStyle(fontSize: 12)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tracking code copied: ${_currentOrder.trackingNumber}'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Visual Tracking Progress Stepper
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 25 : 5),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Shipment Tracking Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildTrackStep(
                        'Placed',
                        Icons.check_circle_rounded,
                        true,
                        isDark,
                      ),
                      _buildTrackDivider(_currentOrder.status != OrderStatus.pending &&
                          _currentOrder.status != OrderStatus.cancelled),
                      _buildTrackStep(
                        'Processing',
                        Icons.inventory_2_rounded,
                        _currentOrder.status != OrderStatus.pending &&
                            _currentOrder.status != OrderStatus.cancelled,
                        isDark,
                      ),
                      _buildTrackDivider(_currentOrder.status == OrderStatus.shipped ||
                          _currentOrder.status == OrderStatus.outForDelivery ||
                          _currentOrder.status == OrderStatus.delivered ||
                          _currentOrder.status == OrderStatus.refunded ||
                          _currentOrder.status == OrderStatus.exchanged),
                      _buildTrackStep(
                        'Shipped',
                        Icons.local_shipping_rounded,
                        _currentOrder.status == OrderStatus.shipped ||
                            _currentOrder.status == OrderStatus.outForDelivery ||
                            _currentOrder.status == OrderStatus.delivered ||
                            _currentOrder.status == OrderStatus.refunded ||
                            _currentOrder.status == OrderStatus.exchanged,
                        isDark,
                      ),
                      _buildTrackDivider(_currentOrder.status == OrderStatus.outForDelivery ||
                          _currentOrder.status == OrderStatus.delivered ||
                          _currentOrder.status == OrderStatus.refunded ||
                          _currentOrder.status == OrderStatus.exchanged),
                      _buildTrackStep(
                        'Delivered',
                        Icons.task_alt_rounded,
                        _currentOrder.status == OrderStatus.delivered ||
                            _currentOrder.status == OrderStatus.refunded ||
                            _currentOrder.status == OrderStatus.exchanged,
                        isDark,
                      ),
                    ],
                  ),

                  // Special banners for cancelled, refunded, exchanged
                  if (_currentOrder.status == OrderStatus.cancelled) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withAlpha(50)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Cancelled: ${_currentOrder.cancellationReason ?? "Customer request"}',
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (_currentOrder.status == OrderStatus.refunded) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.secondary.withAlpha(50)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.currency_exchange_rounded,
                              color: AppColors.secondary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Refund Approved: ${_currentOrder.refundReason ?? "Return confirmed"}',
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (_currentOrder.status == OrderStatus.exchanged) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withAlpha(50)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.swap_horiz_rounded,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Exchange Active: ${_currentOrder.exchangeReason ?? "Replacement dispatched"}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Customer Action Workflow Buttons
            if (_currentOrder.status == OrderStatus.pending ||
                _currentOrder.status == OrderStatus.processing) ...[
              OutlinedButton.icon(
                icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                label: const Text('Cancel Order', style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _showCancelDialog,
              ),
              const SizedBox(height: 20),
            ],

            if (_currentOrder.status == OrderStatus.delivered) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.currency_exchange_rounded, size: 16),
                      label: const Text('Refund / Return'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _showRefundDialog,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                      label: const Text('Exchange Item'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _showExchangeDialog,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Milestone Event Timeline History
            const Text(
              'Tracking Milestones',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _currentOrder.timeline.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final event = _currentOrder.timeline[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                        if (index < _currentOrder.timeline.length - 1)
                          Container(
                            width: 2,
                            height: 40,
                            color: isDark ? Colors.white12 : Colors.grey.shade300,
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                event.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                Formatters.formatDateTime(event.timestamp),
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            event.description,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Items Purchased (Clickable to Product Details)
            Text(
              'Items in this Order (${_currentOrder.items.length})',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _currentOrder.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _currentOrder.items[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(product: item.product),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 64,
                            height: 64,
                            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                            child: CachedNetworkImage(
                              imageUrl: item.product.mainImage,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => const Icon(
                                Icons.image_not_supported_outlined,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Qty: ${item.quantity} • ${item.selectedColor ?? "Standard"}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(item.totalPrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Shipping Destination
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.grey.shade200,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.location_on_outlined,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _currentOrder.shippingAddress,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Order Receipt
            const Text(
              'Payment & Receipt',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal',
                          style: TextStyle(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontSize: 13,
                          )),
                      Text(Formatters.formatCurrency(_currentOrder.subtotal),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  if (_currentOrder.discount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Discount',
                            style: TextStyle(color: AppColors.secondary, fontSize: 13)),
                        Text(
                          '-${Formatters.formatCurrency(_currentOrder.discount)}',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tax (8%)',
                          style: TextStyle(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontSize: 13,
                          )),
                      Text(Formatters.formatCurrency(_currentOrder.tax),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Shipping Fee',
                          style: TextStyle(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontSize: 13,
                          )),
                      Text(
                        _currentOrder.shippingFee == 0
                            ? 'FREE'
                            : Formatters.formatCurrency(_currentOrder.shippingFee),
                        style: TextStyle(
                          color: _currentOrder.shippingFee == 0 ? AppColors.success : null,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Paid',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        Formatters.formatCurrency(_currentOrder.total),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackStep(String title, IconData icon, bool isActive, bool isDark) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : (isDark ? Colors.white10 : Colors.grey.shade200),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isActive ? Colors.white : Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.primary : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildTrackDivider(bool isActive) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.only(bottom: 16),
        color: isActive ? AppColors.primary : Colors.grey.shade300,
      ),
    );
  }
}
