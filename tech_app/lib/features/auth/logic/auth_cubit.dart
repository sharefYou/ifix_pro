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
      emit(AuthSuccess(response['data']['user']));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required int cityId,
    required String specialty,
    required String idPhoto,
    required String avatar,
  }) async {
    emit(AuthLoading());
    try {
      final response = await _repo.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        cityId: cityId,
        specialty: specialty,
        idPhoto: idPhoto,
        avatar: avatar,
      );
      emit(AuthSuccess(response['data']['user']));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(AuthInitial());
  }
}
