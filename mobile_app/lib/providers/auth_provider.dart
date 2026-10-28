import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _init();
  }

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _init() async {
    await ApiService.instance.init();
    if (ApiService.instance.hasToken) {
      await fetchCurrentUser();
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      final response = await ApiService.instance.get('/api/auth/me', requiresAuth: true);
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body['success'] == true && body['data'] != null) {
          _user = UserModel.fromJson(body['data']);
          notifyListeners();
        }
      } else if (response.statusCode == 401) {
        await ApiService.instance.clearTokens();
        _user = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Lỗi tải thông tin user: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.instance.post(
        '/api/auth/login',
        body: {'email': email.trim(), 'password': password},
      );

      final body = jsonDecode(utf8.decode(response.bodyBytes));
      _isLoading = false;

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'];
        final accessToken = data['accessToken'] as String;
        final refreshToken = data['refreshToken'] as String;
        await ApiService.instance.saveTokens(accessToken: accessToken, refreshToken: refreshToken);

        if (data['user'] != null) {
          _user = UserModel.fromJson(data['user']);
        }
        notifyListeners();
        return true;
      } else {
        _errorMessage = body['message'] as String? ?? 'Đăng nhập không thành công';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể kết nối đến máy chủ: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.instance.post(
        '/api/auth/register',
        body: {
          'email': email.trim(),
          'password': password,
          'confirmPassword': confirmPassword,
          'fullName': fullName.trim(),
        },
      );

      final body = jsonDecode(utf8.decode(response.bodyBytes));
      _isLoading = false;

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'];
        final accessToken = data['accessToken'] as String;
        final refreshToken = data['refreshToken'] as String;
        await ApiService.instance.saveTokens(accessToken: accessToken, refreshToken: refreshToken);

        if (data['user'] != null) {
          _user = UserModel.fromJson(data['user']);
        }
        notifyListeners();
        return true;
      } else {
        if (body['data'] is Map) {
          final errors = (body['data'] as Map).values.join('\n');
          _errorMessage = errors.isNotEmpty ? errors : body['message'];
        } else {
          _errorMessage = body['message'] as String? ?? 'Đăng ký không thành công';
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể kết nối đến máy chủ: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({required String fullName, String? avatarUrl}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.instance.put(
        '/api/auth/profile',
        body: {'fullName': fullName.trim(), 'avatarUrl': avatarUrl?.trim()},
        requiresAuth: true,
      );

      final body = jsonDecode(utf8.decode(response.bodyBytes));
      _isLoading = false;

      if (response.statusCode == 200 && body['success'] == true) {
        if (body['data'] != null) {
          _user = UserModel.fromJson(body['data']);
        }
        notifyListeners();
        return true;
      } else {
        if (body['data'] is Map) {
          final errors = (body['data'] as Map).values.join('\n');
          _errorMessage = errors.isNotEmpty ? errors : (body['message'] as String? ?? 'Cập nhật thông tin thất bại');
        } else {
          _errorMessage = body['message'] as String? ?? 'Cập nhật thông tin thất bại';
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể kết nối đến máy chủ: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({required String oldPassword, required String newPassword}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.instance.post(
        '/api/auth/change-password',
        body: {'oldPassword': oldPassword, 'newPassword': newPassword},
        requiresAuth: true,
      );

      final body = jsonDecode(utf8.decode(response.bodyBytes));
      _isLoading = false;

      if (response.statusCode == 200 && body['success'] == true) {
        notifyListeners();
        return true;
      } else {
        if (body['data'] is Map) {
          final errors = (body['data'] as Map).values.join('\n');
          _errorMessage = errors.isNotEmpty ? errors : body['message'];
        } else {
          _errorMessage = body['message'] as String? ?? 'Đổi mật khẩu thất bại';
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể kết nối đến máy chủ: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final token = ApiService.instance.refreshToken;
    try {
      if (token != null) {
        await ApiService.instance.post('/api/auth/logout', body: {'refreshToken': token});
      }
    } catch (_) {}

    await ApiService.instance.clearTokens();
    _user = null;
    notifyListeners();
  }
}
