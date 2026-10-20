import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../bouncy_tap.dart';

/// Reusable Net Banking selection widget with popular banks and complete bank selector
class NetBankingWidget extends StatelessWidget {
  final String? selectedBank;
  final ValueChanged<String> onBankSelected;

  const NetBankingWidget({
    super.key,
    required this.selectedBank,
    required this.onBankSelected,
  });

  static const List<Map<String, String>> popularBanks = [
    {'name': 'HDFC Bank', 'code': 'HDFC'},
    {'name': 'ICICI Bank', 'code': 'ICICI'},
    {'name': 'State Bank of India', 'code': 'SBI'},
    {'name': 'Axis Bank', 'code': 'AXIS'},
    {'name': 'Kotak Mahindra', 'code': 'KOTAK'},
    {'name': 'Punjab National', 'code': 'PNB'},
  ];

  static const List<String> allBanks = [
    'HDFC Bank',
    'ICICI Bank',
    'State Bank of India',
    'Axis Bank',
    'Kotak Mahindra Bank',
    'Punjab National Bank',
    'Bank of Baroda',
    'Canara Bank',
    'Union Bank of India',
    'IndusInd Bank',
    'IDFC FIRST Bank',
    'Federal Bank',
    'Yes Bank',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'POPULAR BANKS',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
          ),
          itemCount: popularBanks.length,
          itemBuilder: (context, index) {
            final bank = popularBanks[index];
            final isSelected = selectedBank == bank['name'];

            return BouncyTap(
              onTap: () => onBankSelected(bank['name']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryTeal.withValues(alpha: isDark ? 0.2 : 0.1)
                      : (isDark ? AppColors.darkCard : AppColors.lightCard),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryTeal
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      bank['code']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? AppColors.primaryTeal
                            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bank['name']!,
                      style: TextStyle(
                        fontSize: 9,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Dropdown for other banks
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: allBanks.contains(selectedBank) ? selectedBank : null,
              hint: Text(
                'Select another bank...',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              isExpanded: true,
              dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: allBanks.map((b) {
                return DropdownMenuItem<String>(
                  value: b,
                  child: Text(
                    b,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onBankSelected(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}
