import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await ApiService.post(
      ApiConfig.login,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      if (data['token'] != null) {
        await ApiService.setToken(data['token']);
      }
      return {
        'success': true,
        'user': data['user'],
        'token': data['token'],
      };
    }

    return response;
  }

  static Future<void> logout() async {
    try {
      await ApiService.post(ApiConfig.logout);
    } finally {
      await ApiService.removeToken();
    }
  }

  static Future<User?> getCurrentUser() async {
    try {
      final token = await ApiService.getToken();
      debugPrint('Token exists: ${token != null}');

      if (token == null) {
        debugPrint('No token, returning null');
        return null;
      }

      debugPrint('Calling API: ${ApiConfig.baseUrl}${ApiConfig.me}');
      final response = await ApiService.get(ApiConfig.me);
      debugPrint('API response: $response');

      if (response['success'] == true && response['data'] != null) {
        final user = response['data']['user'];
        if (user != null) {
          return User.fromJson(user);
        }
      }
    } catch (e) {
      debugPrint('getCurrentUser error: $e');
      await ApiService.removeToken();
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    if (token == null) return false;

    final user = await getCurrentUser();
    return user != null;
  }
}
