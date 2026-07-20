import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// A large, rounded search field used at the top of the Search screen
/// and inside the [SearchableSelectorSheet].
///
/// Kept as its own widget so the "search" visual language (size, icon,
/// clear button, rounded fill) never drifts between the places it's used.
class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.controller,
    this.hintText = 'Search',
    this.autofocus = false,
    this.onChanged,
    this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return Material(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          child: TextField(
            controller: controller,
            autofocus: autofocus,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryBlue),
              suffixIcon: value.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () {
                        controller.clear();
                        onClear?.call();
                        onChanged?.call('');
                      },
                    ),
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.md),
            ),
          ),
        );
      },
    );
  }
}
