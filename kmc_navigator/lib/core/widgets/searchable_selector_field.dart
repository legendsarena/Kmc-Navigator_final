import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import 'empty_state_widget.dart';
import 'search_bar_widget.dart';

/// A tappable, input-styled field that opens a searchable picker sheet
/// when tapped — the app's "searchable dropdown" pattern, used for the
/// Building / Current Location / Destination selectors on Home.
///
/// Generic over [T] so it can pick from a list of buildings, locations,
/// or any other option type without duplicating this widget per use
/// case (see its usage with `Building` and `Location` on Home).
class SearchableSelectorField<T> extends StatelessWidget {
  const SearchableSelectorField({
    super.key,
    required this.label,
    required this.icon,
    required this.options,
    required this.labelOf,
    this.subtitleOf,
    this.selected,
    required this.onSelected,
    this.sheetTitle,
    this.hintText = 'Tap to select',
  });

  final String label;
  final IconData icon;
  final List<T> options;
  final String Function(T) labelOf;
  final String Function(T)? subtitleOf;
  final T? selected;
  final ValueChanged<T> onSelected;
  final String? sheetTitle;
  final String hintText;

  Future<void> _openPicker(BuildContext context) async {
    final T? result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SelectorSheet<T>(
        title: sheetTitle ?? 'Select $label',
        options: options,
        labelOf: labelOf,
        subtitleOf: subtitleOf,
      ),
    );
    if (result != null) onSelected(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String? displayValue = selected == null ? null : labelOf(selected as T);

    return Material(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        onTap: () => _openPicker(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm + 2),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: AppSizes.iconSizeSm + 2),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 2),
                    Text(
                      displayValue ?? hintText,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: displayValue == null
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        fontWeight: displayValue == null ? FontWeight.normal : FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.unfold_more_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// The modal sheet content: a search field plus a filtered, scrollable
/// list of options rendered as simple selectable rows.
class _SelectorSheet<T> extends StatefulWidget {
  const _SelectorSheet({
    required this.title,
    required this.options,
    required this.labelOf,
    this.subtitleOf,
  });

  final String title;
  final List<T> options;
  final String Function(T) labelOf;
  final String Function(T)? subtitleOf;

  @override
  State<_SelectorSheet<T>> createState() => _SelectorSheetState<T>();
}

class _SelectorSheetState<T> extends State<_SelectorSheet<T>> {
  final TextEditingController _controller = TextEditingController();
  late List<T> _filtered = widget.options;

  void _onChanged(String query) {
    setState(() {
      _filtered = widget.options
          .where((o) => widget.labelOf(o).toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.of(context).size.height * 0.8;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSizes.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.md, AppSizes.lg, AppSizes.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: SearchBarWidget(
                controller: _controller,
                hintText: 'Search',
                autofocus: false,
                onChanged: _onChanged,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Flexible(
              child: _filtered.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSizes.xl),
                      child: EmptyStateWidget(
                        icon: Icons.search_off_rounded,
                        title: 'No matches',
                        message: 'Try a different search term.',
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: AppSizes.lg),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final option = _filtered[index];
                        return ListTile(
                          leading: const Icon(Icons.place_rounded, color: AppColors.primaryBlue),
                          title: Text(widget.labelOf(option)),
                          subtitle: widget.subtitleOf == null
                              ? null
                              : Text(widget.subtitleOf!(option)),
                          onTap: () => Navigator.of(context).pop(option),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
