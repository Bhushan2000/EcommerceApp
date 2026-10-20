import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'bouncy_tap.dart';

/// Highly reusable, adaptive top AppBar featuring luxury glassmorphism,
/// back navigation, badge support, and tactile micro-interactions.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final Color? backgroundColor;
  final bool isTransparent;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.showBackButton = true,
    this.onBack,
    this.actions,
    this.bottom,
    this.centerTitle = false,
    this.backgroundColor,
    this.isTransparent = false,
    this.leading,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    Widget? leadingWidget = leading;
    if (leadingWidget == null && showBackButton && canPop) {
      leadingWidget = Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Center(
          child: BouncyTap(
            onTap: onBack ?? () => Navigator.maybePop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.card(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border(context)),
                boxShadow: AppStyles.softShadow(context),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary(context),
                size: 19,
              ),
            ),
          ),
        ),
      );
    }

    return AppBar(
      backgroundColor: isTransparent
          ? Colors.transparent
          : (backgroundColor ?? AppColors.surface(context)),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle,
      leading: leadingWidget,
      leadingWidth: leadingWidget != null ? 52 : null,
      title: titleWidget ??
          (title != null
              ? Column(
                  crossAxisAlignment:
                      centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ],
                )
              : null),
      actions: actions
          ?.map((action) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: action,
              ))
          .toList(),
      bottom: bottom,
    );
  }
}
