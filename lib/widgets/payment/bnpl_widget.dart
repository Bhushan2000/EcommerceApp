import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../bouncy_tap.dart';

/// Reusable Buy Now Pay Later (BNPL / 0% EMI) payment widget
class BnplWidget extends StatelessWidget {
  final double totalAmount;
  final int selectedInstallments;
  final ValueChanged<int> onInstallmentsChanged;

  const BnplWidget({
    super.key,
    required this.totalAmount,
    required this.selectedInstallments,
    required this.onInstallmentsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthlyAmount = totalAmount / selectedInstallments;

    final tenureOptions = [
      {'months': 3, 'tag': '0% Interest'},
      {'months': 6, 'tag': '0% Interest'},
      {'months': 12, 'tag': 'Low Interest'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headline banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.sunsetCoral.withValues(alpha: 0.15),
                AppColors.warmGold.withValues(alpha: 0.12),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.sunsetCoral.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.secondaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pay \$0 Today & Split Later',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.sunsetCoral,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Instant pre-approved credit. No hidden charges or credit score impact.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'CHOOSE INSTALLMENT TENURE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
        ),
        const SizedBox(height: 10),

        Row(
          children: tenureOptions.map((opt) {
            final months = opt['months'] as int;
            final isSelected = selectedInstallments == months;
            final perMonth = (totalAmount / months).toStringAsFixed(2);

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: BouncyTap(
                  onTap: () => onInstallmentsChanged(months),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.sunsetCoral.withValues(alpha: isDark ? 0.2 : 0.08)
                          : (isDark ? AppColors.darkCard : AppColors.lightCard),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.sunsetCoral
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.sunsetCoral
                                : AppColors.warmGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            opt['tag'] as String,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : AppColors.warmGold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$months Months',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$$perMonth/mo',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.sunsetCoral,
                          ),
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

        // Timeline breakdown
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            children: [
              _buildTimelineRow(
                context,
                title: 'Due Today (Order Date)',
                amount: '\$0.00',
                isHighlight: true,
                isDark: isDark,
              ),
              const Divider(height: 16),
              ...List.generate(selectedInstallments, (i) {
                final dateOffset = (i + 1) * 30;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: _buildTimelineRow(
                    context,
                    title: 'Installment ${i + 1} (in $dateOffset days)',
                    amount: '\$${monthlyAmount.toStringAsFixed(2)}',
                    isHighlight: false,
                    isDark: isDark,
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineRow(
    BuildContext context, {
    required String title,
    required String amount,
    required bool isHighlight,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              isHighlight ? Icons.check_circle_rounded : Icons.schedule_rounded,
              size: 16,
              color: isHighlight ? AppColors.primaryTeal : AppColors.darkTextSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isHighlight
                ? AppColors.primaryTeal
                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
        ),
      ],
    );
  }
}
