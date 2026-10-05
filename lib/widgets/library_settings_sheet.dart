import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/comic_enums.dart';
import '../providers/library_provider.dart';

class LibrarySettingsSheet extends StatelessWidget {
  const LibrarySettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Cài đặt thông báo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            RadioGroup<NotificationSetting>(
              groupValue: library.notificationSetting,
              onChanged: (value) {
                if (value != null) {
                  library.setNotificationSetting(value);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final setting in NotificationSetting.values)
                    RadioListTile<NotificationSetting>(
                      value: setting,
                      title: Text(setting.label),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
