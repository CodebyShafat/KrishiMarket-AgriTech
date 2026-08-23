abstract class AuthFailure implements Exception {
  final String messageKey;
  AuthFailure(this.messageKey);
}

class InvalidPhoneNumber extends AuthFailure {
  InvalidPhoneNumber() : super('invalidPhone');
}

class OtpInvalid extends AuthFailure {
  OtpInvalid() : super('invalidOtp');
}

class OtpExpired extends AuthFailure {
  OtpExpired() : super('otpExpired');
}

class TooManyAttempts extends AuthFailure {
  TooManyAttempts() : super('tooManyAttempts');
}

class NetworkError extends AuthFailure {
  NetworkError() : super('networkError');
}

class UnknownAuthError extends AuthFailure {
  UnknownAuthError() : super('unknownError');
}

class SessionExpired extends AuthFailure {
  SessionExpired() : super('unknownError');
}
