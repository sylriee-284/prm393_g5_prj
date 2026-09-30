import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../providers/comic_provider.dart';
import '../widgets/comic_cover.dart';
import 'comic_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = context.watch<ComicProvider>().search(_query);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tìm truyện, tác giả...',
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
      ),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final comic = results[index];
          return ListTile(
            leading: ComicCover(comic: comic, width: 40, height: 54),
            title: Text(comic.title, maxLines: 2),
            subtitle: Text(
              comic.author,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ComicDetailScreen(comicId: comic.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
