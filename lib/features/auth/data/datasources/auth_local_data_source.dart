import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/user_entity.dart';

abstract class AuthLocalDataSource {
  Future<void> saveSession(String mockSessionId, UserEntity user);
  Future<UserEntity?> getUserSession();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _storage;
  static const _sessionIdKey = 'mock_session_id';
  static const _userDataKey = 'mock_user_data';

  AuthLocalDataSourceImpl({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveSession(String mockSessionId, UserEntity user) async {
    await _storage.write(key: _sessionIdKey, value: mockSessionId);
    await _storage.write(key: _userDataKey, value: jsonEncode(user.toJson()));
  }

  @override
  Future<UserEntity?> getUserSession() async {
    final sessionId = await _storage.read(key: _sessionIdKey);
    final userData = await _storage.read(key: _userDataKey);

    if (sessionId != null && userData != null) {
      return UserEntity.fromJson(jsonDecode(userData));
    }
    return null;
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: _sessionIdKey);
    await _storage.delete(key: _userDataKey);
  }
}
