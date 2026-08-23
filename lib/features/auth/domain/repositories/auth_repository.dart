import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> signInWithPhone(String phone);
  Future<UserEntity> verifyOtp(String phone, String otp);
  Future<UserEntity> completeProfile(UserEntity user);
  Future<UserEntity?> restoreSession();
  Future<void> signOut();
}
