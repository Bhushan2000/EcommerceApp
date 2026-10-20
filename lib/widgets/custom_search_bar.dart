import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'bouncy_tap.dart';

/// Reusable search bar with clear button, filter action, debounce, focus control,
/// and adaptive theme styling.
class CustomSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final VoidCallback? onClear;
  final bool showFilterButton;
  final bool hasActiveFilters;
  final bool autoFocus;
  final FocusNode? focusNode;
  final Duration debounceDuration;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search luxury products, brands, essentials...',
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.onClear,
    this.showFilterButton = false,
    this.hasActiveFilters = false,
    this.autoFocus = false,
    this.focusNode,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  Timer? _debounceTimer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String query) {
    if (widget.onChanged == null) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onChanged!(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(AppStyles.radiusMd),
              border: Border.all(
                color: AppColors.border(context),
                width: 1,
              ),
              boxShadow: AppStyles.softShadow(context),
            ),
            child: TextField(
              controller: _controller,
              focusNode: widget.focusNode,
              autofocus: widget.autoFocus,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              onChanged: _onChanged,
              onSubmitted: widget.onSubmitted,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 13.5,
                  fontWeight: FontWeight.normal,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 40),
                suffixIcon: _hasText
                    ? BouncyTap(
                        onTap: () {
                          _controller.clear();
                          widget.onChanged?.call('');
                          widget.onClear?.call();
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : null,
                suffixIconConstraints: const BoxConstraints(minWidth: 36),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ),
        if (widget.showFilterButton && widget.onFilterTap != null) ...[
          const SizedBox(width: 10),
          BouncyTap(
            onTap: widget.onFilterTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: widget.hasActiveFilters ? AppGradients.primaryGradient : null,
                color: widget.hasActiveFilters ? null : AppColors.card(context),
                borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                border: Border.all(
                  color: widget.hasActiveFilters
                      ? Colors.transparent
                      : AppColors.border(context),
                ),
                boxShadow: AppStyles.softShadow(context),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: widget.hasActiveFilters
                        ? Colors.white
                        : AppColors.textPrimary(context),
                    size: 20,
                  ),
                  if (widget.hasActiveFilters)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
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
