import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../providers/library_provider.dart';
import '../providers/reader_provider.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reader = context.watch<ReaderProvider>();
    final comic = reader.comic;
    final chapter = reader.chapter;

    if (comic == null || chapter == null) {
      return const Scaffold(body: Center(child: Text('Chưa chọn chương')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(chapter.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: () => reader.setFontSize(reader.fontSize + 2),
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () => reader.setFontSize(reader.fontSize - 2),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            comic.title,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            chapter.content,
            style: TextStyle(
              fontSize: reader.fontSize,
              height: 1.7,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: reader.hasPrevious
                      ? () {
                          reader.previous();
                          context.read<LibraryProvider>().updateProgress(
                            comic.id,
                            reader.chapter!.number,
                          );
                        }
                      : null,
                  child: const Text('Chương trước'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: reader.hasNext
                      ? () {
                          reader.next();
                          context.read<LibraryProvider>().updateProgress(
                            comic.id,
                            reader.chapter!.number,
                          );
                        }
                      : null,
                  child: const Text('Chương sau'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
