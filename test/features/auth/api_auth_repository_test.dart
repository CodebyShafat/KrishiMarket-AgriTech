import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:krishimarket/core/network/api_client.dart';
import 'package:krishimarket/features/auth/data/repositories/api_auth_repository.dart';
import 'package:krishimarket/features/auth/domain/failures/auth_failures.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MockHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.Request request) handler;
  MockHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request as http.Request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

void main() {
  group('ApiAuthRepository & ApiClient', () {
    late ApiAuthRepository repository;
    late FlutterSecureStorage secureStorage;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      secureStorage = const FlutterSecureStorage();
    });

    test('signInWithPhone successful', () async {
      final mockClient = MockHttpClient((req) async {
        return http.Response('{"message": "OTP sent"}', 200);
      });
      final apiClient = ApiClient(client: mockClient);
      repository = ApiAuthRepository(apiClient: apiClient);

      await expectLater(repository.signInWithPhone('+919876543210'), completes);
    });

    test('signInWithPhone invalid phone throws AuthFailure', () async {
      final apiClient = ApiClient(
        client: MockHttpClient((req) async => http.Response('', 200)),
      );
      repository = ApiAuthRepository(apiClient: apiClient);

      expect(
        () => repository.signInWithPhone('123'),
        throwsA(isA<InvalidPhoneNumber>()),
      );
    });

    test('verifyOtp success stores tokens and fetches user', () async {
      final mockClient = MockHttpClient((req) async {
        if (req.url.path.endsWith('/verify-otp')) {
          return http.Response(
            jsonEncode({
              'access_token': 'fake_access',
              'refresh_token': 'fake_refresh',
            }),
            200,
          );
        } else if (req.url.path.endsWith('/me')) {
          return http.Response(
            jsonEncode({
              'id': 1,
              'phone_number': '+919876543210',
              'name': 'Test User',
              'role': 'FARMER',
            }),
            200,
          );
        }
        return http.Response('', 404);
      });

      final apiClient = ApiClient(client: mockClient);
      repository = ApiAuthRepository(apiClient: apiClient);

      final user = await repository.verifyOtp('+919876543210', '123456');

      expect(user.id, '1');
      expect(user.phone, '+919876543210');

      final savedAccess = await secureStorage.read(key: 'access_token');
      expect(savedAccess, 'fake_access');
    });

    test('verifyOtp throws OtpInvalid on 401', () async {
      final mockClient = MockHttpClient((req) async {
        return http.Response('{"detail": "Invalid OTP"}', 401);
      });
      final apiClient = ApiClient(client: mockClient);
      repository = ApiAuthRepository(apiClient: apiClient);

      expect(
        repository.verifyOtp('+919876543210', '000000'),
        throwsA(isA<OtpInvalid>()),
      );
    });

    test('restoreSession success', () async {
      await secureStorage.write(key: 'access_token', value: 'valid_access');

      final mockClient = MockHttpClient((req) async {
        if (req.url.path.endsWith('/me') &&
            req.headers['Authorization'] == 'Bearer valid_access') {
          return http.Response(
            jsonEncode({
              'id': 2,
              'phone_number': '+910000000000',
              'name': 'Session User',
              'role': 'BUYER',
            }),
            200,
          );
        }
        return http.Response('', 401);
      });

      final apiClient = ApiClient(client: mockClient);
      repository = ApiAuthRepository(apiClient: apiClient);

      final user = await repository.restoreSession();
      expect(user, isNotNull);
      expect(user!.id, '2');
    });

    test('restoreSession token expired, automatic refresh success', () async {
      await secureStorage.write(key: 'access_token', value: 'expired_access');
      await secureStorage.write(key: 'refresh_token', value: 'valid_refresh');

      int meCalls = 0;
      final mockClient = MockHttpClient((req) async {
        if (req.url.path.endsWith('/me')) {
          meCalls++;
          if (meCalls == 1) return http.Response('', 401); // First call fails
          // Second call uses new token
          if (req.headers['Authorization'] == 'Bearer new_access') {
            return http.Response(
              jsonEncode({
                'id': 3,
                'phone_number': '+911111111111',
                'name': 'Refreshed User',
                'role': 'FARMER',
              }),
              200,
            );
          }
        }
        if (req.url.path.endsWith('/refresh')) {
          return http.Response(
            jsonEncode({
              'access_token': 'new_access',
              'refresh_token': 'new_refresh',
            }),
            200,
          );
        }
        return http.Response('', 400);
      });

      final apiClient = ApiClient(client: mockClient);
      repository = ApiAuthRepository(apiClient: apiClient);

      final user = await repository.restoreSession();
      expect(user, isNotNull);
      expect(user!.id, '3');

      expect(await secureStorage.read(key: 'access_token'), 'new_access');
    });

    test(
      'restoreSession refresh fails, returns null and clears tokens',
      () async {
        await secureStorage.write(key: 'access_token', value: 'expired_access');
        await secureStorage.write(
          key: 'refresh_token',
          value: 'expired_refresh',
        );

        final mockClient = MockHttpClient((req) async {
          return http.Response('', 401); // Fails everything
        });

        final apiClient = ApiClient(client: mockClient);
        repository = ApiAuthRepository(apiClient: apiClient);

        final user = await repository.restoreSession();
        expect(user, isNull);
        expect(await secureStorage.read(key: 'access_token'), isNull);
      },
    );

    test('signOut clears tokens and calls logout API', () async {
      await secureStorage.write(key: 'access_token', value: 'acc');
      await secureStorage.write(key: 'refresh_token', value: 'ref');

      bool logoutCalled = false;
      final mockClient = MockHttpClient((req) async {
        if (req.url.path.endsWith('/logout')) {
          logoutCalled = true;
          return http.Response('', 200);
        }
        return http.Response('', 404);
      });

      final apiClient = ApiClient(client: mockClient);
      repository = ApiAuthRepository(apiClient: apiClient);

      await repository.signOut();
      expect(logoutCalled, isTrue);
      expect(await secureStorage.read(key: 'access_token'), isNull);
    });

    test('NetworkError mapping', () async {
      final mockClient = MockHttpClient((req) async {
        throw http.ClientException('Connection reset');
      });

      final apiClient = ApiClient(client: mockClient);
      repository = ApiAuthRepository(apiClient: apiClient);

      expect(
        repository.signInWithPhone('+919876543210'),
        throwsA(isA<NetworkError>()),
      );
    });
  });
}
