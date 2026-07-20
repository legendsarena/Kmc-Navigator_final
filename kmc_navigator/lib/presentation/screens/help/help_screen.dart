import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/faq_tile.dart';
import '../../../core/widgets/kmc_app_bar.dart';
import '../../mock/mock_data.dart';

/// A simple FAQ page answering the most common "how do I..." questions
/// about using KMC Navigator. Backed by [mockFaqs].
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KmcAppBar(title: AppStrings.helpTitle),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: mockFaqs.length,
        itemBuilder: (context, index) {
          final faq = mockFaqs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: FaqTile(question: faq.question, answer: faq.answer),
          );
        },
      ),
    );
  }
}
