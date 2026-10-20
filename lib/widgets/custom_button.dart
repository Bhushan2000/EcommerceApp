import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'bouncy_tap.dart';

enum CustomButtonVariant {
  primary,
  secondary,
  outlined,
  tonal,
  ghost,
}

typedef ButtonVariant = CustomButtonVariant;

/// Highly reusable, tactile button component with multiple variants,
/// loading states, icons, and built-in springy bounce micro-interaction.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final CustomButtonVariant variant;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double? width;
  final double borderRadius;
  final bool useGradient;
  final double fontSize;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.variant = CustomButtonVariant.primary,
    this.icon,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.textColor,
    this.height = 52,
    this.width,
    this.borderRadius = AppStyles.radiusMd,
    this.useGradient = true,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveVariant = isOutlined ? CustomButtonVariant.outlined : variant;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = onPressed != null && !isLoading;

    // Determine colors based on variant
    Color bg;
    Color fg;
    BorderSide borderSide = BorderSide.none;
    Gradient? gradient;

    switch (effectiveVariant) {
      case CustomButtonVariant.secondary:
        bg = backgroundColor ?? AppColors.secondary;
        fg = textColor ?? Colors.white;
        if (useGradient && backgroundColor == null) {
          gradient = AppGradients.secondaryGradient;
        }
        break;

      case CustomButtonVariant.outlined:
        bg = Colors.transparent;
        fg = textColor ?? (backgroundColor ?? AppColors.primary);
        borderSide = BorderSide(
          color: backgroundColor ?? AppColors.primary,
          width: 1.5,
        );
        break;

      case CustomButtonVariant.tonal:
        bg = (backgroundColor ?? AppColors.primary).withAlpha(isDark ? 35 : 22);
        fg = textColor ?? AppColors.primary;
        break;

      case CustomButtonVariant.ghost:
        bg = Colors.transparent;
        fg = textColor ?? AppColors.textPrimary(context);
        break;

      case CustomButtonVariant.primary:
        bg = backgroundColor ?? AppColors.primary;
        fg = textColor ?? Colors.white;
        if (useGradient && backgroundColor == null) {
          gradient = AppGradients.primaryGradient;
        }
        break;
    }

    Widget content = Row(
      mainAxisSize: width != null ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (leading != null) ...[
          leading!,
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: 19, color: fg),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: isEnabled ? fg : fg.withAlpha(120),
            letterSpacing: 0.2,
          ),
        ),
        if (!isLoading && trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );

    return BouncyTap(
      onTap: isEnabled ? onPressed : null,
      scaleFactor: isEnabled ? 0.96 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: gradient == null ? (isEnabled ? bg : bg.withAlpha(140)) : null,
          gradient: isEnabled ? gradient : null,
          borderRadius: BorderRadius.circular(borderRadius),
          border: borderSide != BorderSide.none ? Border.fromBorderSide(borderSide) : null,
          boxShadow: isEnabled &&
                  effectiveVariant == CustomButtonVariant.primary &&
                  gradient != null
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(55),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}
