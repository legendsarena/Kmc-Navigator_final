import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// A centered loading indicator with an optional message and a gentle
/// pulse animation on the mark — used for splash and any future
/// async (Firestore/Auth) loading states.
///
/// Kept deliberately calm: one soft, looping scale/opacity pulse rather
/// than a busier spinner, so it reads as "working" without feeling
/// frantic to anxious or elderly users.
class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key, this.message, this.compact = false});

  final String? message;

  /// When true, renders a small inline version (e.g. inside a card)
  /// instead of a full centered block.
  final bool compact;

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double markSize = widget.compact ? 36 : 56;

    final mark = ScaleTransition(
      scale: Tween(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: markSize,
        height: markSize,
        decoration: const BoxDecoration(
          color: AppColors.primaryTint,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SizedBox(
            width: markSize * 0.5,
            height: markSize * 0.5,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ),
    );

    if (widget.compact) return mark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          mark,
          if (widget.message != null) ...[
            const SizedBox(height: AppSizes.md),
            Text(
              widget.message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
