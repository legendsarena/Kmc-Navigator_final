import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_failure.dart';
import 'empty_state_widget.dart';
import 'error_state_widget.dart';
import 'loading_indicator.dart';

/// Renders a Riverpod [AsyncValue] using the app's shared loading /
/// error / empty widgets, so every screen backed by a Firestore stream
/// handles those three states the same way instead of re-implementing
/// `.when(...)` boilerplate each time.
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loadingMessage,
    this.isEmpty,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage = 'Check back later.',
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final String? loadingMessage;

  /// Optional predicate to treat a successfully-loaded-but-empty result
  /// (e.g. an empty list) as the empty state rather than rendering [data].
  final bool Function(T data)? isEmpty;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;

  /// Called when the person taps "Try again" on the error state. Usually
  /// `ref.invalidate(someProvider)`.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (result) {
        if (isEmpty != null && isEmpty!(result)) {
          return EmptyStateWidget(icon: emptyIcon, title: emptyTitle, message: emptyMessage);
        }
        return data(result);
      },
      loading: () => LoadingIndicator(message: loadingMessage),
      error: (error, stackTrace) {
        final failure = AppFailure.from(error);
        return ErrorStateWidget(
          title: failure.title,
          message: failure.message,
          onRetry: onRetry,
        );
      },
    );
  }
}
