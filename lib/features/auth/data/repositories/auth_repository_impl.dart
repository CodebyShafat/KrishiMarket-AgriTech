import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<void> signInWithPhone(String phone) async {
    await remoteDataSource.requestOtp(phone);
  }

  @override
  Future<UserEntity> verifyOtp(String phone, String otp) async {
    final user = await remoteDataSource.verifyOtp(phone, otp);
    // After OTP, save the session initially
    await localDataSource.saveSession('mock_session_${user.id}', user);
    return user;
  }

  @override
  Future<UserEntity> completeProfile(UserEntity user) async {
    final updatedUser = await remoteDataSource.updateProfile(user);
    // Update local session with new profile details
    await localDataSource.saveSession('mock_session_${user.id}', updatedUser);
    return updatedUser;
  }

  @override
  Future<UserEntity?> restoreSession() async {
    return await localDataSource.getUserSession();
  }

  @override
  Future<void> signOut() async {
    await localDataSource.clearSession();
  }
}
