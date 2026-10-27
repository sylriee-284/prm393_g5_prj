import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static const String _keyAccessToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';

  String? _accessToken;
  String? _refreshToken;

  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    } catch (_) {}
    return 'http://localhost:8080';
  }

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get hasToken => _accessToken != null && _accessToken!.isNotEmpty;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_keyAccessToken);
    _refreshToken = prefs.getString(_keyRefreshToken);
  }

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
  }

  Map<String, String> _buildHeaders({bool requiresAuth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (requiresAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Future<http.Response> get(String path, {bool requiresAuth = false}) async {
    final url = Uri.parse('$baseUrl$path');
    var response = await http.get(url, headers: _buildHeaders(requiresAuth: requiresAuth));

    if (requiresAuth && response.statusCode == 401 && _refreshToken != null) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        response = await http.get(url, headers: _buildHeaders(requiresAuth: true));
      }
    }
    return response;
  }

  Future<http.Response> post(String path, {dynamic body, bool requiresAuth = false}) async {
    final url = Uri.parse('$baseUrl$path');
    final payload = body != null ? jsonEncode(body) : null;
    var response = await http.post(url, headers: _buildHeaders(requiresAuth: requiresAuth), body: payload);

    if (requiresAuth && response.statusCode == 401 && _refreshToken != null) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        response = await http.post(url, headers: _buildHeaders(requiresAuth: true), body: payload);
      }
    }
    return response;
  }

  Future<http.Response> put(String path, {dynamic body, bool requiresAuth = false}) async {
    final url = Uri.parse('$baseUrl$path');
    final payload = body != null ? jsonEncode(body) : null;
    var response = await http.put(url, headers: _buildHeaders(requiresAuth: requiresAuth), body: payload);

    if (requiresAuth && response.statusCode == 401 && _refreshToken != null) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        response = await http.put(url, headers: _buildHeaders(requiresAuth: true), body: payload);
      }
    }
    return response;
  }

  Future<http.Response> delete(String path, {bool requiresAuth = false}) async {
    final url = Uri.parse('$baseUrl$path');
    var response = await http.delete(url, headers: _buildHeaders(requiresAuth: requiresAuth));

    if (requiresAuth && response.statusCode == 401 && _refreshToken != null) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        response = await http.delete(url, headers: _buildHeaders(requiresAuth: true));
      }
    }
    return response;
  }

  Future<bool> _tryRefreshToken() async {
    if (_refreshToken == null) return false;
    try {
      final url = Uri.parse('$baseUrl/api/auth/refresh');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          final newAccess = data['data']['accessToken'] as String;
          final newRefresh = (data['data']['refreshToken'] as String?) ?? _refreshToken!;
          await saveTokens(accessToken: newAccess, refreshToken: newRefresh);
          return true;
        }
      }
    } catch (_) {}
    await clearTokens();
    return false;
  }
}
