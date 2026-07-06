part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final Map<String, dynamic> user;
  AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class OtpSentSuccess extends AuthState {
  final String message;
  final String? devOtp;
  OtpSentSuccess(this.message, [this.devOtp]);

  @override
  List<Object?> get props => [message, devOtp];
}

class OtpVerifiedSuccess extends AuthState {
  final Map<String, dynamic> data;
  OtpVerifiedSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

