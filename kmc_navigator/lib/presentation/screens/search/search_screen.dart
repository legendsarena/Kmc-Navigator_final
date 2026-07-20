import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/kmc_app_bar.dart';
import '../../../core/widgets/location_card.dart';
import '../../../core/widgets/search_bar_widget.dart';
import '../../providers/data_providers.dart';

/// Lets a visitor search for a department, room, or facility by name.
///
/// Backed live by Firestore's `locations` collection: [locationsProvider]
/// keeps the full list in sync, and [locationSearchProvider] filters it
/// client-side as the person types — see that provider's doc comment for
/// why filtering isn't a fresh Firestore query per keystroke.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(locationSearchProvider(_query));

    return Scaffold(
      appBar: const KmcAppBar(title: 'Search'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: SearchBarWidget(
              controller: _controller,
              hintText: 'Search department or room',
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: AsyncValueWidget(
                key: ValueKey(_query),
                value: resultsAsync,
                isEmpty: (results) => results.isEmpty,
                emptyIcon: Icons.search_off_rounded,
                emptyTitle: _query.trim().isEmpty ? 'No locations yet' : 'No results found',
                emptyMessage: _query.trim().isEmpty
                    ? 'Hospital locations will appear here once they\u2019re added.'
                    : 'Try searching a department name, like "Cardiology" or "Pharmacy".',
                onRetry: () => ref.invalidate(locationsProvider),
                data: (results) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.lg),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSizes.xs),
                  itemBuilder: (context, index) {
                    final location = results[index];
                    return LocationCard(
                      icon: Icons.place_rounded,
                      name: location.name,
                      category: location.category ?? 'Location',
                      floor: location.floorId,
                      onTap: () {
                        // TODO(next-prompt): wire into RoutingService
                        // as the selected destination.
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
