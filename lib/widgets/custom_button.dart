import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final bool useGradient;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.height = 52,
    this.borderRadius = 14,
    this.useGradient = true,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isOutlined) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeInOut,
          child: OutlinedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: Size.fromHeight(widget.height),
              side: BorderSide(
                color: widget.backgroundColor ?? AppColors.primary,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon,
                            size: 19,
                            color: widget.textColor ?? AppColors.primary),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: widget.textColor ?? AppColors.primary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
    }

    final effectiveGradient =
        (widget.useGradient && widget.backgroundColor == null)
            ? AppColors.primaryGradient
            : null;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: effectiveGradient,
            color: effectiveGradient == null
                ? (widget.backgroundColor ?? AppColors.primary)
                : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.onPressed != null && !widget.isLoading
                ? [
                    BoxShadow(
                      color: (widget.backgroundColor ?? AppColors.primary)
                          .withAlpha(50),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: widget.textColor ?? Colors.white,
              minimumSize: Size.fromHeight(widget.height),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              elevation: 0,
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 19, color: Colors.white),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
