import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../providers/comic_provider.dart';
import '../widgets/explore_card.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final comics = context.watch<ComicProvider>().comics;

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.navExplore)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.55,
        ),
        itemCount: comics.length,
        itemBuilder: (context, index) {
          return ExploreCard(comic: comics[index]);
        },
      ),
    );
  }
}
