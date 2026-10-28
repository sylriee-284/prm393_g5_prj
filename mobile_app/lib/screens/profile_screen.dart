import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/comic_provider.dart';
import '../providers/library_provider.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const List<String> presetAvatars = [
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=150&auto=format&fit=crop&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final user = auth.user;
    final isDark = theme.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.navAccount),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Cài đặt',
            onPressed: () => _showSettingsSheet(context, auth, theme),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. AVATAR & TÊN NGƯỜI DÙNG
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: isDark
                      ? AppTheme.darkSurface
                      : AppTheme.accent,
                  child: ClipOval(
                    child: (user != null &&
                            user.avatarUrl.trim().startsWith('http'))
                        ? Image.network(
                            user.avatarUrl.trim(),
                            width: 84,
                            height: 84,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.person,
                              size: 42,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 42,
                            color: Colors.white,
                          ),
                  ),
                ),
                if (auth.isAuthenticated)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => _showEditProfileDialog(context, auth),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  auth.isAuthenticated ? user!.fullName : 'Khách',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (auth.isAuthenticated)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    tooltip: 'Đổi tên & Avatar',
                    onPressed: () => _showEditProfileDialog(context, auth),
                  ),
              ],
            ),
          ),
          Center(
            child: Text(
              auth.isAuthenticated
                  ? user!.email
                  : 'Đăng nhập để đồng bộ tủ truyện',
              style: TextStyle(
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.textSecondary,
              ),
            ),
          ),
          if (auth.isAuthenticated) ...[
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: user!.isAdmin
                      ? (isDark
                            ? Colors.orange.shade900.withValues(alpha: 0.3)
                            : Colors.orange.shade100)
                      : (isDark
                            ? Colors.blue.shade900.withValues(alpha: 0.3)
                            : Colors.blue.shade100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.isAdmin ? 'Quản trị viên' : 'Thành viên',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: user.isAdmin
                        ? (isDark
                              ? Colors.orange.shade300
                              : Colors.orange.shade900)
                        : (isDark
                              ? Colors.blue.shade300
                              : Colors.blue.shade900),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // 2. NÚT ĐĂNG NHẬP / ĐĂNG KÝ (NẾU CHƯA ĐĂNG NHẬP)
          if (!auth.isAuthenticated) ...[
            FilledButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              icon: const Icon(Icons.login),
              label: const Text('Đăng nhập / Đăng ký'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 3. THỐNG KÊ TỦ TRUYỆN
          _StatTile(label: 'Đang đọc', value: '${library.history.length}'),
          _StatTile(label: 'Đã đánh dấu', value: '${library.bookmarks.length}'),
          _StatTile(
            label: 'Thông báo',
            value: library.notificationSetting.label,
          ),
          const SizedBox(height: 24),

          // 4. CÁC TÍNH NĂNG ĐỒNG BỘ & ĐĂNG XUẤT
          if (auth.isAuthenticated) ...[
            OutlinedButton.icon(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Đang đồng bộ với thiết bị...'),
                      ],
                    ),
                    duration: Duration(seconds: 1),
                  ),
                );

                final success = await library.mergeLocalWithAccount();
                if (!context.mounted) return;
                await context.read<ComicProvider>().refresh();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Đã đồng bộ thành công tủ truyện với thiết bị!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Không thể đồng bộ với thiết bị. Vui lòng kiểm tra lại kết nối mạng!',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.sync),
              label: const Text('Đồng bộ với thiết bị'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                await auth.logout();
                if (!context.mounted) return;
                await library.switchToLocal();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã đăng xuất khỏi tài khoản')),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.shade300),
              ),
            ),

          ],
        ],
      ),
    );
  }

  // ====================================================================
  // MODAL SHEET: CÀI ĐẶT & TÙY CHỌN (BÁNH RĂNG)
  // ====================================================================
  void _showSettingsSheet(
    BuildContext context,
    AuthProvider auth,
    ThemeProvider theme,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.isDarkMode ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Consumer<ThemeProvider>(
          builder: (context, currentTheme, _) {
            final isDark = currentTheme.isDarkMode;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        'Cài đặt & Tùy chọn',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Lựa chọn 1: Chỉnh sửa hồ sơ
                    ListTile(
                      leading: Icon(
                        Icons.person_outline,
                        color: isDark
                            ? AppTheme.darkTextPrimary
                            : AppTheme.textPrimary,
                      ),
                      title: const Text('Chỉnh sửa hồ sơ'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        if (auth.isAuthenticated) {
                          _showEditProfileDialog(context, auth);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Vui lòng đăng nhập để chỉnh sửa hồ sơ!',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const Divider(height: 1),
                    // Lựa chọn 2: Đổi mật khẩu
                    ListTile(
                      leading: Icon(
                        Icons.lock_outline,
                        color: isDark
                            ? AppTheme.darkTextPrimary
                            : AppTheme.textPrimary,
                      ),
                      title: const Text('Đổi mật khẩu'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        if (auth.isAuthenticated) {
                          _showChangePasswordDialog(context, auth);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Vui lòng đăng nhập để đổi mật khẩu!',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const Divider(height: 1),
                    // Lựa chọn 3: Chuyển đổi Dark/Light mode
                    SwitchListTile(
                      secondary: Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: isDark ? Colors.amber : Colors.orange,
                      ),
                      title: const Text('Chế độ ban đêm (Dark Mode)'),
                      subtitle: Text(
                        isDark ? 'Giao diện tối' : 'Giao diện sáng',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.textSecondary,
                        ),
                      ),
                      value: isDark,
                      onChanged: (val) {
                        currentTheme.setDarkMode(val);
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ====================================================================
  // DIALOG ĐỔI TÊN & ĐỔI AVATAR
  // ====================================================================
  void _showEditProfileDialog(BuildContext context, AuthProvider auth) {
    final user = auth.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để chỉnh sửa hồ sơ!'),
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.fullName);
    final avatarController = TextEditingController(text: user.avatarUrl);
    String selectedAvatar = user.avatarUrl.isNotEmpty
        ? user.avatarUrl
        : presetAvatars[0];
    bool isSubmitting = false;
    String? dialogError;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final trimmedAvatar = selectedAvatar.trim();
            final hasValidAvatarUrl = trimmedAvatar.startsWith('http://') ||
                trimmedAvatar.startsWith('https://');

            return AlertDialog(
              title: const Text('Chỉnh sửa hồ sơ'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Preview Avatar
                        Center(
                          child: CircleAvatar(
                            radius: 36,
                            child: ClipOval(
                              child: hasValidAvatarUrl
                                  ? Image.network(
                                      trimmedAvatar,
                                      width: 72,
                                      height: 72,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          const Icon(Icons.person, size: 36),
                                    )
                                  : const Icon(Icons.person, size: 36),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Chọn ảnh đại diện mẫu:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Preset avatars list with bounded horizontal scroll
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (int index = 0;
                                  index < presetAvatars.length;
                                  index++) ...[
                                if (index > 0) const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: isSubmitting
                                      ? null
                                      : () {
                                          setDialogState(() {
                                            selectedAvatar =
                                                presetAvatars[index];
                                            avatarController.text =
                                                presetAvatars[index];
                                          });
                                        },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: selectedAvatar ==
                                                presetAvatars[index]
                                            ? Colors.blue
                                            : Colors.transparent,
                                        width: 2.5,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.grey.shade200,
                                      child: ClipOval(
                                        child: Image.network(
                                          presetAvatars[index],
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              const Icon(Icons.person,
                                                  size: 24),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Tên hiển thị
                        TextFormField(
                          controller: nameController,
                          enabled: !isSubmitting,
                          decoration: const InputDecoration(
                            labelText: 'Họ và tên *',
                            prefixIcon: Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().length < 2) {
                              return 'Vui lòng nhập tên (ít nhất 2 ký tự)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // URL Avatar tùy chỉnh
                        TextFormField(
                          controller: avatarController,
                          enabled: !isSubmitting,
                          decoration: const InputDecoration(
                            labelText: 'Hoặc dán URL ảnh đại diện',
                            prefixIcon: Icon(Icons.link),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) {
                            setDialogState(() {
                              selectedAvatar = val.trim().isNotEmpty
                                  ? val.trim()
                                  : presetAvatars[0];
                            });
                          },
                        ),
                        if (dialogError != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    dialogError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSubmitting ? null : () => Navigator.of(ctx).pop(),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() {
                            isSubmitting = true;
                            dialogError = null;
                          });

                          final finalAvatar =
                              avatarController.text.trim().isNotEmpty
                                  ? avatarController.text.trim()
                                  : selectedAvatar;

                          final success = await auth.updateProfile(
                            fullName: nameController.text.trim(),
                            avatarUrl: finalAvatar,
                          );

                          if (!dialogCtx.mounted) return;

                          if (success) {
                            Navigator.of(dialogCtx).pop();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cập nhật hồ sơ thành công!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            setDialogState(() {
                              isSubmitting = false;
                              dialogError = auth.errorMessage ??
                                  'Cập nhật thông tin thất bại. Vui lòng thử lại!';
                            });
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Lưu thay đổi'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ====================================================================
  // DIALOG ĐỔI MẬT KHẨU
  // ====================================================================
  void _showChangePasswordDialog(BuildContext context, AuthProvider auth) {
    final formKey = GlobalKey<FormState>();
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool hideOld = true;
    bool hideNew = true;
    bool hideConfirm = true;
    bool isSubmitting = false;
    String? dialogError;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: const Text('Đổi mật khẩu'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Mật khẩu hiện tại
                        TextFormField(
                          controller: oldPasswordController,
                          obscureText: hideOld,
                          enabled: !isSubmitting,
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu hiện tại *',
                            prefixIcon: const Icon(Icons.lock_clock_outlined),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                hideOld ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () =>
                                  setDialogState(() => hideOld = !hideOld),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu hiện tại';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // Mật khẩu mới
                        TextFormField(
                          controller: newPasswordController,
                          obscureText: hideNew,
                          enabled: !isSubmitting,
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu mới *',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                hideNew ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () =>
                                  setDialogState(() => hideNew = !hideNew),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Mật khẩu phải từ 6 ký tự trở lên';
                            }
                            if (!RegExp(r'^(?=.*[A-Z])(?=.*\d).*$')
                                .hasMatch(value)) {
                              return 'Cần ít nhất 1 chữ hoa và 1 chữ số';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // Xác nhận mật khẩu mới
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: hideConfirm,
                          enabled: !isSubmitting,
                          decoration: InputDecoration(
                            labelText: 'Xác nhận mật khẩu mới *',
                            prefixIcon: const Icon(Icons.lock_reset),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                hideConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => setDialogState(
                                () => hideConfirm = !hideConfirm,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value != newPasswordController.text) {
                              return 'Mật khẩu xác nhận không khớp';
                            }
                            return null;
                          },
                        ),
                        if (dialogError != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    dialogError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSubmitting ? null : () => Navigator.of(ctx).pop(),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() {
                            isSubmitting = true;
                            dialogError = null;
                          });

                          final success = await auth.changePassword(
                            oldPassword: oldPasswordController.text,
                            newPassword: newPasswordController.text,
                          );

                          if (!dialogCtx.mounted) return;

                          if (success) {
                            Navigator.of(dialogCtx).pop();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đổi mật khẩu thành công!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            setDialogState(() {
                              isSubmitting = false;
                              dialogError = auth.errorMessage ??
                                  'Đổi mật khẩu thất bại. Vui lòng thử lại!';
                            });
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Cập nhật'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    );
  }
}
