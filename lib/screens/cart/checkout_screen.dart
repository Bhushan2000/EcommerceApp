import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/address_lookup_service.dart';
import '../../services/payment/payment_method_model.dart';
import '../../services/payment/payment_processor.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../widgets/bouncy_tap.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/payment/payment_widgets.dart';
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

  // Address Controllers
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();

  // Payment Controllers & State
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _saveCard = true;

  final _upiController = TextEditingController();
  String _selectedWallet = 'Apple Pay';
  String _selectedBank = 'HDFC Bank';
  int _selectedInstallments = 3;
  bool _codConfirmed = true;

  late final PaymentProcessor _paymentProcessor;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _paymentProcessor = PaymentProcessor();

    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = user.displayName;
      _streetController.text = user.street ?? '';
      _cityController.text = user.city ?? '';
      _stateController.text = user.state ?? '';
      _zipController.text = user.zipCode ?? '';
      _phoneController.text = user.phoneNumber ?? '';
      _cardHolderController.text = user.displayName.toUpperCase();
    } else {
      _nameController.text = 'Alex Morgan';
      _streetController.text = '742 Evergreen Terrace';
      _cityController.text = 'Springfield';
      _stateController.text = 'OR';
      _zipController.text = '97477';
      _phoneController.text = '+1 (555) 019-2834';
      _cardHolderController.text = 'ALEX MORGAN';
    }

    _cardNumberController.text = '4242 4242 4242 4242';
    _expiryController.text = '12/28';
    _cvvController.text = '888';
    _upiController.text = 'alex.shopper@okaxis';

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

    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _upiController.dispose();

    _paymentProcessor.dispose();
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
              Expanded(
                child: Text('Address pinned from Map: ${_streetController.text}'),
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

  PaymentDetails _buildCurrentPaymentDetails() {
    return PaymentDetails(
      methodType: _paymentProcessor.selectedMethod,
      cardNumber: _cardNumberController.text,
      cardHolder: _cardHolderController.text,
      expiryDate: _expiryController.text,
      cvv: _cvvController.text,
      upiId: _upiController.text,
      walletName: _selectedWallet,
      bankName: _selectedBank,
      installmentsCount: _selectedInstallments,
      codConfirmed: _codConfirmed,
    );
  }

  Future<void> _handlePlaceOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();

    final paymentDetails = _buildCurrentPaymentDetails();
    final validation = _paymentProcessor.validateDetails(paymentDetails);

    if (!validation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(validation.errorMessage ?? 'Please check payment details')),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final txResult = await _paymentProcessor.processPayment(
      details: paymentDetails,
      amount: cart.totalAmount,
    );

    if (!txResult.isSuccess) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(txResult.message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

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
      paymentMethod:
          '${_paymentProcessor.selectedMethod.displayName} (${txResult.transactionId})',
      status: OrderStatus.processing,
      createdAt: DateTime.now(),
    );

    final placedId = await orderProvider.createOrder(newOrder);

    setState(() {
      _isProcessing = false;
    });

    if (placedId != null && mounted) {
      cart.clearCart();
      _showSuccessDialog(newOrder, txResult);
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

  void _showSuccessDialog(OrderModel order, PaymentTransactionResult tx) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success.withValues(alpha: 0.25),
                    AppColors.success.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 60,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Order Placed Successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Order ID: ${order.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: AppColors.primaryTeal,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment Method:',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      Text(
                        _paymentProcessor.selectedMethod.displayName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reference ID:',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      Text(
                        tx.transactionId,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
            CustomButton(
              text: 'View All Orders',
              variant: ButtonVariant.outlined,
              icon: Icons.receipt_long_rounded,
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

  Widget _buildDynamicPaymentForm() {
    switch (_paymentProcessor.selectedMethod) {
      case PaymentMethodType.card:
        return CardPaymentWidget(
          cardNumberController: _cardNumberController,
          cardHolderController: _cardHolderController,
          expiryController: _expiryController,
          cvvController: _cvvController,
          saveCard: _saveCard,
          onSaveCardChanged: (val) => setState(() => _saveCard = val),
        );
      case PaymentMethodType.upi:
        final cart = context.read<CartProvider>();
        return UpiPaymentWidget(
          upiController: _upiController,
          totalAmount: cart.totalAmount,
        );
      case PaymentMethodType.wallets:
        return _buildWalletsWidget();
      case PaymentMethodType.netBanking:
        return NetBankingWidget(
          selectedBank: _selectedBank,
          onBankSelected: (bank) => setState(() => _selectedBank = bank),
        );
      case PaymentMethodType.bnpl:
        final cart = context.read<CartProvider>();
        return BnplWidget(
          totalAmount: cart.totalAmount,
          selectedInstallments: _selectedInstallments,
          onInstallmentsChanged: (count) => setState(() => _selectedInstallments = count),
        );
      case PaymentMethodType.cod:
        return CodWidget(
          isConfirmed: _codConfirmed,
          onConfirmationChanged: (val) => setState(() => _codConfirmed = val),
        );
    }
  }

  Widget _buildWalletsWidget() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wallets = [
      {'name': 'Apple Pay', 'icon': Icons.apple_rounded},
      {'name': 'Google Wallet', 'icon': Icons.account_balance_wallet_rounded},
      {'name': 'Aura Express Pay', 'icon': Icons.flash_on_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: wallets.map((w) {
        final isSelected = _selectedWallet == w['name'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: BouncyTap(
            onTap: () => setState(() => _selectedWallet = w['name'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryTeal.withValues(alpha: isDark ? 0.2 : 0.08)
                    : (isDark ? AppColors.darkCard : AppColors.lightCard),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryTeal
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(w['icon'] as IconData,
                      color: isSelected ? AppColors.primaryTeal : Colors.grey, size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      w['name'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.radio_button_off,
                    color: isSelected ? AppColors.primaryTeal : Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Checkout',
        subtitle: 'Review & Complete Payment',
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
                  _buildStepBadge(
                      step: '1', title: 'Address', isActive: true, isDark: isDark),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: AppColors.primaryTeal,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  _buildStepBadge(
                      step: '2', title: 'Payment', isActive: true, isDark: isDark),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: AppColors.primaryTeal.withValues(alpha: 0.4),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  _buildStepBadge(
                      step: '3', title: 'Confirm', isActive: false, isDark: isDark),
                ],
              ),
              const SizedBox(height: 24),

              // Shipping Address Card with Google Map Pin Button
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: AppColors.primaryTeal, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Shipping Address',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        // Google Map Picker Button with Bouncy Micro-interaction
                        BouncyTap(
                          onTap: _openMapPicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryTeal.withValues(alpha: 0.3),
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
                      prefixIcon: Icons.person_outline_rounded,
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

              // Interactive Payment Selector & Dynamic Subforms
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PaymentMethodSelector(
                      selectedMethod: _paymentProcessor.selectedMethod,
                      onMethodSelected: (m) {
                        setState(() {
                          _paymentProcessor.selectMethod(m);
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    _buildDynamicPaymentForm(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Final Bill Overview
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Items in Cart',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
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
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
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
                              style: TextStyle(
                                  color: AppColors.sunsetCoral, fontSize: 13)),
                          Text('-${Formatters.formatCurrency(cart.discountAmount)}',
                              style: const TextStyle(
                                  color: AppColors.sunsetCoral,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Payable',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          Formatters.formatCurrency(cart.totalAmount),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryTeal,
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
                text: 'Authorize & Place Order',
                icon: Icons.lock_outline_rounded,
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
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.primaryTeal
                : (isDark ? AppColors.darkBorder : Colors.grey.shade300),
          ),
          child: Center(
            child: Text(
              step,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : (isDark ? AppColors.darkTextSecondary : Colors.grey.shade700),
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
            color: isActive
                ? AppColors.primaryTeal
                : (isDark ? AppColors.darkTextSecondary : Colors.grey.shade500),
          ),
        ),
      ],
    );
  }
}
