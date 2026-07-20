import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/announcement_card.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/kmc_app_bar.dart';
import '../../providers/data_providers.dart';

/// Lists hospital announcements and notices as a scrollable feed of
/// [AnnouncementCard]s, streamed live from Firestore (newest first, and
/// only announcements the admin has marked active) via
/// [announcementsProvider].
class AnnouncementScreen extends ConsumerWidget {
  const AnnouncementScreen({super.key});

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Formats a date without pulling in the `intl` package — keeps this
  /// screen dependency-free beyond what Prompt 1 already declared.
  static String _formatDate(DateTime? date) {
    if (date == null) return 'Just now';
    final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final period = date.hour < 12 ? 'AM' : 'PM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '${_months[date.month - 1]} ${date.day}, ${date.year} \u2022 $hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsProvider);

    return Scaffold(
      appBar: const KmcAppBar(title: 'Announcements'),
      body: AsyncValueWidget(
        value: announcementsAsync,
        isEmpty: (announcements) => announcements.isEmpty,
        emptyIcon: Icons.campaign_outlined,
        emptyTitle: 'No announcements yet',
        emptyMessage: 'Check back later for hospital updates and notices.',
        loadingMessage: 'Loading announcements...',
        onRetry: () => ref.invalidate(announcementsProvider),
        data: (announcements) => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final a = announcements[index];
            return AnnouncementCard(
              title: a.title,
              description: a.message,
              date: _formatDate(a.createdAt),
              tag: a.isActive ? 'Notice' : 'Archived',
            );
          },
        ),
      ),
    );
  }
}
