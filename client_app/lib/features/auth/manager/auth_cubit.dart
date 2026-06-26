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
      print(e.toString());
      final error = ErrorHandler.handleGeneralError(e);
      emit(LoginErrorState(error: error));
    }
  }
}
