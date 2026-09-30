import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'providers/comic_provider.dart';
import 'providers/library_provider.dart';
import 'providers/reader_provider.dart';
import 'repositories/comic_repository.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(const NovelApp());
}

class NovelApp extends StatelessWidget {
  const NovelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ComicRepository()),
        ChangeNotifierProvider(
          create: (context) => ComicProvider(context.read<ComicRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => LibraryProvider(context.read<ComicRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ReaderProvider(context.read<ComicRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'Tủ Truyện',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const MainShell(),
      ),
    );
  }
}
