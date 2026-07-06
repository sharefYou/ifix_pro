import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/api/api_constants.dart';
import 'package:ifix_client/core/api/dio_helper.dart';
import 'package:ifix_client/core/helpers/cache_helper.dart';
import 'package:ifix_client/core/helpers/error_handler.dart';
import 'package:ifix_client/features/auth/manager/auth_states.dart';

class AuthCubit extends Cubit<AuthStates> {
  AuthCubit() : super(AuthInitState());

  Future<void> login({required String phone, required String password}) async {
    emit(LoginLoadingState());
    try {
      final response = await DioHelper.postData(
        endPoint: ApiConstants.login,
        data: {'phone': phone, 'password': password},
      );
      await CacheHelper.saveData(key: 'token', value: response.data['token']);
      emit(LoginSuccessState());
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(LoginErrorState(error: error));
    }
  }

  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    emit(RegisterLoadingState());
    try {
      await DioHelper.postData(
        endPoint: ApiConstants.register,
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );
      emit(RegisterSuccessState(phone: phone));
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(RegisterErrorState(error: error));
    }
  }

  Future<void> verifyOtp({
    required String phone,
    required String otpCode,
  }) async {
    emit(VerifyOtpLoadingState());
    try {
      final response = await DioHelper.postData(
        endPoint: ApiConstants.verifyOtp,
        data: {'phone': phone, 'otp_code': otpCode},
      );
      await CacheHelper.saveData(key: 'token', value: response.data['token']);
      emit(VerifyOtpSuccessState());
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(VerifyOtpErrorState(error: error));
    }
  }

  Future<void> resendOtp({required String phone}) async {
    emit(ResendOtpLoadingState());
    try {
      await DioHelper.postData(
        endPoint: ApiConstants.resendOtp,
        data: {'phone': phone},
      );
      emit(ResendOtpSuccessState());
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(ResendOtpErrorState(error: error));
    }
  }

  Future<void> forgotPassword({required String phone}) async {
    emit(ForgotPasswordLoadingState());
    try {
      await DioHelper.postData(
        endPoint: ApiConstants.forgotPassword,
        data: {'phone': phone},
      );
      emit(ForgotPasswordSuccessState(phone: phone));
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(ForgotPasswordErrorState(error: error));
    }
  }

  Future<void> verifyResetCode({
    required String phone,
    required String otpCode,
  }) async {
    emit(VerifyResetCodeLoadingState());
    try {
      await DioHelper.postData(
        endPoint: ApiConstants.verifyResetPasswordOTPCode,
        data: {'phone': phone, 'otp_code': otpCode},
      );
      emit(VerifyResetCodeSuccessState());
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(VerifyResetCodeErrorState(error: error));
    }
  }

  Future<void> resetPassword({
    required String phone,
    required String otpCode,
    required String password,
  }) async {
    emit(ResetPasswordLoadingState());
    try {
      await DioHelper.postData(
        endPoint: ApiConstants.resetPassword,
        data: {
          'phone': phone,
          'otp_code': otpCode,
          'password': password,
          'password_confirmation': password,
        },
      );
      emit(ResetPasswordSuccessState());
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(ResetPasswordErrorState(error: error));
    }
  }
}



