import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final headers = await getHeaders();
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 30));
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = '${ApiConfig.baseUrl}$endpoint';
    debugPrint('POST $url');
    debugPrint('Body: ${body != null ? jsonEncode(body) : 'null'}');

    try {
      final headers = await getHeaders();
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      return _handleResponse(response);
    } on SocketException catch (e) {
      debugPrint('SocketException: $e');
      throw ApiException(
        statusCode: 0,
        message: 'Impossible de se connecter au serveur',
      );
    } on http.ClientException catch (e) {
      debugPrint('ClientException: $e');
      throw ApiException(
        statusCode: 0,
        message: 'Erreur de connexion: $e',
      );
    } catch (e) {
      debugPrint('Unknown error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await getHeaders();
    final response = await http
        .put(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 30));
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final headers = await getHeaders();
    final response = await http
        .delete(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 30));
    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      debugPrint('===================================================');
      debugPrint('API ERROR - Status: ${response.statusCode}');
      debugPrint('Message: ${body['message']}');

      if (response.statusCode == 403) {
        final errorCode = body['error_code'] ?? 'UNKNOWN';
        final permissionRequired = body['permission_required'] ?? 'unknown';
        debugPrint('');
        debugPrint('PERMISSION ERROR');
        debugPrint('Error Code: $errorCode');
        debugPrint('Permission Required: $permissionRequired');
        debugPrint('Message: ${body['message']}');
      }

      if (response.statusCode == 401) {
        debugPrint('AUTH ERROR - User not authenticated or token expired');
      }

      if (body['errors'] != null) {
        debugPrint('Errors: ${body['errors']}');
      }
      debugPrint('===================================================');

      throw ApiException(
        statusCode: response.statusCode,
        message: body['message'] ?? 'Une erreur est survenue',
        errors: body['errors'],
        errorCode: body['error_code'],
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic errors;
  final String? errorCode;

  ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
    this.errorCode,
  });

  @override
  String toString() {
    if (errorCode != null) {
      return '[$errorCode] $message';
    }
    return message;
  }

  bool get isAuthError => statusCode == 401;
  bool get isPermissionError => statusCode == 403;
}
