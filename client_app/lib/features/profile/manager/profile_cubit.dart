import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/api/api_constants.dart';
import 'package:ifix_client/core/api/dio_helper.dart';
import 'package:ifix_client/core/helpers/cache_helper.dart';
import 'package:ifix_client/core/helpers/error_handler.dart';
import '../data/models/user_model.dart';
import 'profile_states.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  ProfileCubit() : super(ProfileInitialState());

  UserModel? currentUser;

  Future<void> fetchProfile() async {
    emit(ProfileLoadingState());
    try {
      final response = await DioHelper.getData(endPoint: ApiConstants.profile);
      currentUser = UserModel.fromJson(response.data['user']);
      await CacheHelper.saveData(
        key: 'user',
        value: jsonEncode(currentUser!.toJson()),
      );
      emit(ProfileLoadedState(currentUser!));
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(ProfileErrorState(error));
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    String? email,
    String? city,
  }) async {
    emit(ProfileUpdateLoadingState());
    try {
      final response = await DioHelper.postData(
        endPoint: ApiConstants.profile,
        data: {
          'name': name,
          'phone': phone,
          if (email != null && email.isNotEmpty) 'email': email,
          if (city != null && city.isNotEmpty) 'city': city,
        },
      );
      currentUser = UserModel.fromJson(response.data['user']);
      await CacheHelper.saveData(
        key: 'user',
        value: jsonEncode(currentUser!.toJson()),
      );
      emit(ProfileUpdateSuccessState(currentUser!));
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(ProfileUpdateErrorState(error));
    }
  }
}
