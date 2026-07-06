import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/repos/auth_repo.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;

  AuthCubit(this._repo) : super(AuthInitial());

  Future<void> login(String phone, String password) async {
    emit(AuthLoading());
    try {
      final response = await _repo.login(phone, password);
      emit(AuthSuccess(response));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register({
    required String name,
    required String phone,
    required String password,
    required String city,
    required double lat,
    required double lng,
    required String idDocumentPath,
    required List<int> serviceIds,
  }) async {
    emit(AuthLoading());
    try {
      final response = await _repo.register(
        name: name,
        phone: phone,
        password: password,
        city: city,
        lat: lat,
        lng: lng,
        idDocumentPath: idDocumentPath,
        serviceIds: serviceIds,
      );
      emit(OtpSentSuccess(
        response['message']?.toString() ?? 'OTP Sent',
        response['otp']?.toString(),
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> verifyOtp(String phone, String otpCode) async {
    emit(AuthLoading());
    try {
      final response = await _repo.verifyOtp(phone, otpCode);
      emit(OtpVerifiedSuccess(response));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> resendOtp(String phone) async {
    emit(AuthLoading());
    try {
      final response = await _repo.resendOtp(phone);
      emit(OtpSentSuccess(
        response['message']?.toString() ?? 'OTP Sent',
        response['otp']?.toString(),
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(AuthInitial());
  }
}
