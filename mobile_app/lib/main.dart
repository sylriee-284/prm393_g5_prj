import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/comic_provider.dart';
import 'providers/library_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/reader_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/comic_repository.dart';
import 'screens/main_shell.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.instance.init();
  runApp(const NovelApp());
}

class NovelApp extends StatelessWidget {
  const NovelApp({super.key, this.comicRepository});

  final ComicRepository? comicRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        Provider(create: (_) => comicRepository ?? ComicRepository()),
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
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            navigatorKey: rootNavigatorKey,
            title: 'Tủ Truyện',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.themeMode,
            scrollBehavior: const ScrollBehavior().copyWith(
              overscroll: false,
              physics: const ClampingScrollPhysics(),
            ),
            home: const MainShell(),
          );
        },
      ),
    );
  }
}
