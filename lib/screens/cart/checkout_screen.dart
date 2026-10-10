import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/address_lookup_service.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../checkout/map_address_picker_screen.dart';
import '../orders/order_details_screen.dart';
import '../orders/order_history_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();

  String _paymentMethod = 'Credit / Debit Card';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = user.displayName;
      _streetController.text = user.street ?? '';
      _cityController.text = user.city ?? '';
      _stateController.text = user.state ?? '';
      _zipController.text = user.zipCode ?? '';
      _phoneController.text = user.phoneNumber ?? '';
    } else {
      _nameController.text = 'Alex Morgan';
      _streetController.text = '742 Evergreen Terrace';
      _cityController.text = 'Springfield';
      _stateController.text = 'OR';
      _zipController.text = '97477';
      _phoneController.text = '+1 (555) 019-2834';
    }

    // Auto-fetch state whenever user enters city
    _cityController.addListener(_onCityChanged);
  }

  void _onCityChanged() {
    final query = _cityController.text.trim();
    if (query.isNotEmpty) {
      final detectedState = AddressLookupService.lookupState(query);
      if (detectedState != null && _stateController.text != detectedState) {
        setState(() {
          _stateController.text = detectedState;
        });
      }
    }
  }

  @override
  void dispose() {
    _cityController.removeListener(_onCityChanged);
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => MapAddressPickerScreen(
          initialStreet: _streetController.text,
          initialCity: _cityController.text,
          initialState: _stateController.text,
          initialZip: _zipController.text,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        if (result['street']?.isNotEmpty == true) {
          _streetController.text = result['street']!;
        }
        if (result['city']?.isNotEmpty == true) {
          _cityController.text = result['city']!;
        }
        if (result['state']?.isNotEmpty == true) {
          _stateController.text = result['state']!;
        }
        if (result['zip']?.isNotEmpty == true) {
          _zipController.text = result['zip']!;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text('Address loaded from Map: ${_streetController.text}'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _handlePlaceOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();

    setState(() {
      _isProcessing = true;
    });

    final shippingAddress =
        '${_nameController.text.trim()}, ${_streetController.text.trim()}, ${_cityController.text.trim()}, ${_stateController.text.trim()} ${_zipController.text.trim()} (Phone: ${_phoneController.text.trim()})';

    final orderId = 'ORD-${const Uuid().v4().substring(0, 8).toUpperCase()}';

    final newOrder = OrderModel(
      id: orderId,
      userId: auth.user?.id ?? 'guest_shopper',
      userEmail: auth.user?.email ?? 'guest@aura.com',
      items: List.from(cart.itemList),
      subtotal: cart.subtotal,
      discount: cart.discountAmount,
      tax: cart.taxAmount,
      shippingFee: cart.shippingFee,
      total: cart.totalAmount,
      shippingAddress: shippingAddress,
      paymentMethod: _paymentMethod,
      status: OrderStatus.processing,
      createdAt: DateTime.now(),
    );

    final placedId = await orderProvider.createOrder(newOrder);

    setState(() {
      _isProcessing = false;
    });

    if (placedId != null && mounted) {
      cart.clearCart();
      _showSuccessDialog(newOrder);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to place order. Please check your connection.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showSuccessDialog(OrderModel order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success.withAlpha(40),
                    AppColors.success.withAlpha(20),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 64,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Order Placed Successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Order ID: ${order.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Thank you for your purchase. We are preparing your order for shipment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Track Order Status',
              icon: Icons.local_shipping_outlined,
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)),
                );
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.receipt_long_rounded, size: 18),
              label: const Text('View All Orders'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                );
              },
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Visual Step Indicator
              Row(
                children: [
                  _buildStepBadge(step: '1', title: 'Address', isActive: true, isDone: false, isDark: isDark),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: AppColors.primary,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  _buildStepBadge(step: '2', title: 'Payment', isActive: true, isDone: false, isDark: isDark),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isDark ? Colors.white12 : Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  _buildStepBadge(step: '3', title: 'Confirm', isActive: false, isDone: false, isDark: isDark),
                ],
              ),

              const SizedBox(height: 24),

              // Shipping Address Card with Google Map Button
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 20 : 5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Shipping Address',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        // Google Map Picker Button
                        GestureDetector(
                          onTap: _openMapPicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: AppGradients.primaryGradient,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withAlpha(60),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.map_rounded, color: Colors.white, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Pick on Map',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'e.g. Alex Morgan',
                      prefixIcon: Icons.person_outline,
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _streetController,
                      label: 'Street Address',
                      hint: 'e.g. 742 Evergreen Terrace',
                      prefixIcon: Icons.home_outlined,
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _cityController,
                            label: 'City (Auto-fetches State)',
                            hint: 'e.g. Springfield / Mumbai / LA',
                            validator: (val) =>
                                val == null || val.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _stateController,
                            label: 'State / Province',
                            hint: 'e.g. OR / Maharashtra / CA',
                            validator: (val) =>
                                val == null || val.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _zipController,
                            label: 'ZIP / Postal Code',
                            hint: 'e.g. 97477',
                            keyboardType: TextInputType.number,
                            validator: (val) =>
                                val == null || val.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _phoneController,
                            label: 'Contact Phone',
                            hint: 'e.g. +1 555-019-2834',
                            keyboardType: TextInputType.phone,
                            validator: (val) =>
                                val == null || val.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Payment Method Section
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 20 : 5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.payment_rounded, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Payment Method',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildPaymentOption(
                      title: 'Credit / Debit Card',
                      icon: Icons.credit_card_rounded,
                      subtitle: 'Visa, Mastercard, Amex',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentOption(
                      title: 'Apple Pay / Google Pay',
                      icon: Icons.contactless_rounded,
                      subtitle: 'Instant one-tap digital checkout',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentOption(
                      title: 'Cash on Delivery',
                      icon: Icons.local_atm_rounded,
                      subtitle: 'Pay cash upon package arrival',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Final Bill Overview
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Items in Cart',
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              fontSize: 13,
                            )),
                        Text('${cart.itemCount} items',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal',
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              fontSize: 13,
                            )),
                        Text(Formatters.formatCurrency(cart.subtotal),
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    if (cart.discountAmount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Discount',
                              style: TextStyle(color: AppColors.secondary, fontSize: 13)),
                          Text('-${Formatters.formatCurrency(cart.discountAmount)}',
                              style: const TextStyle(
                                  color: AppColors.secondary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount Payable',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          Formatters.formatCurrency(cart.totalAmount),
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

              const SizedBox(height: 28),

              CustomButton(
                text: 'Confirm & Place Order',
                icon: Icons.check_circle_outline,
                isLoading: _isProcessing,
                onPressed: _handlePlaceOrder,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepBadge({
    required String step,
    required String title,
    required bool isActive,
    required bool isDone,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : (isDark ? Colors.white12 : Colors.grey.shade300),
          ),
          child: Center(
            child: Text(
              step,
              style: TextStyle(
                color: isActive ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.primary : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required IconData icon,
    required String subtitle,
    required bool isDark,
  }) {
    final isSelected = _paymentMethod == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentMethod = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(isDark ? 30 : 15)
              : (isDark ? Colors.white.withAlpha(5) : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.white12 : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(30)
                    : (isDark ? Colors.white10 : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
