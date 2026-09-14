import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/domain/failures/auth_failures.dart';

class ApiClient {
  final String baseUrl;
  final FlutterSecureStorage secureStorage;
  final http.Client httpClient;

  ApiClient({
    String? baseUrl,
    this.secureStorage = const FlutterSecureStorage(),
    http.Client? client,
  })  : baseUrl = baseUrl ?? _getDefaultBaseUrl(),
        httpClient = client ?? http.Client();

  static String _getDefaultBaseUrl() {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }
    return kIsWeb ? 'http://127.0.0.1:8000/api/v1' : 'http://10.177.80.11:8000/api/v1';
  }

  Future<void> saveTokens(String access, String refresh) async {
    await secureStorage.write(key: 'access_token', value: access);
    await secureStorage.write(key: 'refresh_token', value: refresh);
  }

  Future<void> clearTokens() async {
    await secureStorage.delete(key: 'access_token');
    await secureStorage.delete(key: 'refresh_token');
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    return _request('POST', path, body: body, requiresAuth: requiresAuth);
  }

  Future<dynamic> get(String path, {bool requiresAuth = false}) async {
    return _request('GET', path, requiresAuth: requiresAuth);
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    return _request('PUT', path, body: body, requiresAuth: requiresAuth);
  }

  Future<dynamic> delete(String path, {bool requiresAuth = false}) async {
    return _request('DELETE', path, requiresAuth: requiresAuth);
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = {'Content-Type': 'application/json'};

      if (requiresAuth) {
        final token = await secureStorage.read(key: 'access_token');
        if (token != null) headers['Authorization'] = 'Bearer $token';
      }

      http.Response response;
      if (method == 'POST') {
        response = await httpClient.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? {}),
        );
      } else if (method == 'PUT') {
        response = await httpClient.put(
          uri,
          headers: headers,
          body: jsonEncode(body ?? {}),
        );
      } else if (method == 'DELETE') {
        response = await httpClient.delete(uri, headers: headers);
      } else {
        response = await httpClient.get(uri, headers: headers);
      }

      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          return await _request(
            method,
            path,
            body: body,
            requiresAuth: requiresAuth,
          );
        } else {
          throw SessionExpired();
        }
      }

      return _handleResponse(response);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw NetworkError();
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final uri = Uri.parse('$baseUrl/auth/refresh');
      final response = await httpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveTokens(data['access_token'], data['refresh_token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) throw OtpInvalid();
    if (response.statusCode == 409) throw UnknownAuthError(); // E.g. conflict

    throw UnknownAuthError();
  }
}
