import '../../domain/entities/user_entity.dart';
import '../../domain/failures/auth_failures.dart';

abstract class AuthRemoteDataSource {
  Future<void> requestOtp(String phone);
  Future<UserEntity> verifyOtp(String phone, String otp);
  Future<UserEntity> updateProfile(UserEntity user);
}

class MockAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<void> requestOtp(String phone) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Simulate validation
    if (phone.length < 10) {
      throw InvalidPhoneNumber();
    }
  }

  @override
  Future<UserEntity> verifyOtp(String phone, String otp) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    if (otp != '123456') {
      throw OtpInvalid();
    }

    // Return a mock user with only ID and phone
    return UserEntity(
      id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      phone: phone,
    );
  }

  @override
  Future<UserEntity> updateProfile(UserEntity user) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    return user;
  }
}
