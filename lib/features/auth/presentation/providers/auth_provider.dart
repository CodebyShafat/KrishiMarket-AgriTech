import 'package:flutter/material.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/failures/auth_failures.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthState {
  initializing,
  unauthenticated,
  awaitingOtp,
  authenticating,
  profileIncomplete,
  authenticated,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthState _state = AuthState.initializing;
  UserEntity? _currentUser;
  String? _currentPhone;
  AuthFailure? _error;

  AuthProvider(this._repository);

  AuthState get state => _state;
  UserEntity? get currentUser => _currentUser;
  String? get currentPhone => _currentPhone;
  AuthFailure? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> restoreSession() async {
    _state = AuthState.initializing;
    notifyListeners();

    try {
      final user = await _repository.restoreSession();
      if (user != null) {
        _currentUser = user;
        _currentPhone = user.phone;
        if (user.isProfileComplete) {
          _state = AuthState.authenticated;
        } else {
          _state = AuthState.profileIncomplete;
        }
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> signInWithPhone(String phone) async {
    _state = AuthState.authenticating;
    _error = null;
    notifyListeners();

    try {
      await _repository.signInWithPhone(phone);
      _currentPhone = phone;
      _state = AuthState.awaitingOtp;
    } on AuthFailure catch (e) {
      _error = e;
      _state = AuthState.unauthenticated;
    } catch (e) {
      _error = UnknownAuthError();
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> verifyOtp(String otp) async {
    if (_currentPhone == null) return;

    final previousState = _state;
    _state = AuthState.authenticating;
    _error = null;
    notifyListeners();

    try {
      final user = await _repository.verifyOtp(_currentPhone!, otp);
      _currentUser = user;
      if (user.isProfileComplete) {
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.profileIncomplete;
      }
    } on AuthFailure catch (e) {
      _error = e;
      _state = previousState; // Revert to awaitingOtp
    } catch (e) {
      _error = UnknownAuthError();
      _state = previousState;
    }
    notifyListeners();
  }

  Future<void> completeProfile({
    String? role,
    String? fullName,
    String? location,
    String? businessName,
    String? businessType,
  }) async {
    if (_currentUser == null) return;

    final previousState = _state;
    _state = AuthState.authenticating;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = _currentUser!.copyWith(
        role: role,
        fullName: fullName,
        location: location,
        businessName: businessName,
        businessType: businessType,
      );

      _currentUser = await _repository.completeProfile(updatedUser);
      _state = AuthState.authenticated;
    } on AuthFailure catch (e) {
      _error = e;
      _state = previousState;
    } catch (e) {
      _error = UnknownAuthError();
      _state = previousState;
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _currentUser = null;
    _currentPhone = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}
