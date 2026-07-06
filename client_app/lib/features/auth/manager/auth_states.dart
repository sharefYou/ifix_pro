abstract class AuthStates {}

class AuthInitState extends AuthStates {}

class LoginLoadingState extends AuthStates {}

class LoginSuccessState extends AuthStates {}

class LoginErrorState extends AuthStates {
  final String error;
  LoginErrorState({required this.error});
}

class RegisterLoadingState extends AuthStates {}

class RegisterSuccessState extends AuthStates {
  final String phone;
  RegisterSuccessState({required this.phone});
}

class RegisterErrorState extends AuthStates {
  final String error;
  RegisterErrorState({required this.error});
}

class VerifyOtpLoadingState extends AuthStates {}

class VerifyOtpSuccessState extends AuthStates {}

class VerifyOtpErrorState extends AuthStates {
  final String error;
  VerifyOtpErrorState({required this.error});
}

class ResendOtpLoadingState extends AuthStates {}

class ResendOtpSuccessState extends AuthStates {}

class ResendOtpErrorState extends AuthStates {
  final String error;
  ResendOtpErrorState({required this.error});
}

class ForgotPasswordLoadingState extends AuthStates {}

class ForgotPasswordSuccessState extends AuthStates {
  final String phone;
  ForgotPasswordSuccessState({required this.phone});
}

class ForgotPasswordErrorState extends AuthStates {
  final String error;
  ForgotPasswordErrorState({required this.error});
}

class VerifyResetCodeLoadingState extends AuthStates {}

class VerifyResetCodeSuccessState extends AuthStates {}

class VerifyResetCodeErrorState extends AuthStates {
  final String error;
  VerifyResetCodeErrorState({required this.error});
}

class ResetPasswordLoadingState extends AuthStates {}

class ResetPasswordSuccessState extends AuthStates {}

class ResetPasswordErrorState extends AuthStates {
  final String error;
  ResetPasswordErrorState({required this.error});
}



