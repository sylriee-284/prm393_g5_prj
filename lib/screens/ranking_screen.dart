import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../providers/comic_provider.dart';
import '../widgets/ranking_row.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ranking = context.watch<ComicProvider>().ranking;

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.navRanking)),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: ranking.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final comic = ranking[index];
          return RankingRow(comic: comic, rankIndex: index + 1);
        },
      ),
    );
  }
}
