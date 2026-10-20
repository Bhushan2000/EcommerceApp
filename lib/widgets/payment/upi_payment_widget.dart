import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../bouncy_tap.dart';
import '../custom_text_field.dart';

/// Interactive UPI & QR payment widget
class UpiPaymentWidget extends StatefulWidget {
  final TextEditingController upiController;
  final double totalAmount;

  const UpiPaymentWidget({
    super.key,
    required this.upiController,
    required this.totalAmount,
  });

  @override
  State<UpiPaymentWidget> createState() => _UpiPaymentWidgetState();
}

class _UpiPaymentWidgetState extends State<UpiPaymentWidget> {
  bool _showQrCode = false;

  final List<String> _upiHandles = [
    '@okaxis',
    '@okhdfcbank',
    '@ybl',
    '@paytm',
    '@upi',
  ];

  final List<Map<String, String>> _upiApps = [
    {'name': 'Google Pay', 'icon': 'GPay'},
    {'name': 'PhonePe', 'icon': 'Pe'},
    {'name': 'Paytm', 'icon': 'PTM'},
    {'name': 'BHIM', 'icon': 'BHIM'},
  ];

  void _appendHandle(String handle) {
    final current = widget.upiController.text.trim();
    if (current.isEmpty) {
      widget.upiController.text = 'username$handle';
    } else if (current.contains('@')) {
      final prefix = current.split('@').first;
      widget.upiController.text = '$prefix$handle';
    } else {
      widget.upiController.text = '$current$handle';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App Quick Chooser row
        Text(
          'POPULAR UPI APPS',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _upiApps.map((app) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: BouncyTap(
                  onTap: () {
                    if (widget.upiController.text.isEmpty) {
                      widget.upiController.text = 'user@${app['icon']!.toLowerCase()}';
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.15),
                          child: Text(
                            app['icon']!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          app['name']!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // UPI ID Input
        CustomTextField(
          controller: widget.upiController,
          label: 'Virtual Payment Address (VPA / UPI ID)',
          hint: 'e.g. mobileNumber@upi or name@bank',
          prefixIcon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10),

        // Quick Handles
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _upiHandles.map((handle) {
            return BouncyTap(
              onTap: () => _appendHandle(handle),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.3)),
                ),
                child: Text(
                  handle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // QR Code toggle option
        BouncyTap(
          onTap: () {
            setState(() {
              _showQrCode = !_showQrCode;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _showQrCode
                    ? AppColors.sunsetCoral
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.qr_code_2_rounded,
                  color: _showQrCode ? AppColors.sunsetCoral : AppColors.primaryTeal,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Show Dynamic Order QR Code',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        'Scan and pay directly using any banking app',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _showQrCode ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ],
            ),
          ),
        ),

        if (_showQrCode) ...[
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black87, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 110,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'AURA MERCH: \$${widget.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
