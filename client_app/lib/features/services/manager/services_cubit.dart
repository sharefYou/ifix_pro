import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/api/api_constants.dart';
import 'package:ifix_client/core/api/dio_helper.dart';
import 'package:ifix_client/core/helpers/error_handler.dart';
import '../data/models/service_model.dart';
import 'services_states.dart';

class ServicesCubit extends Cubit<ServicesStates> {
  ServicesCubit() : super(ServicesInitialState());

  List<ServiceCategoryModel> categories = [];

  Future<void> fetchServices() async {
    emit(ServicesLoadingState());
    try {
      final response = await DioHelper.getData(endPoint: ApiConstants.services);
      final data = response.data['data'];
      categories = [];
      if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            categories.add(ServiceCategoryModel.fromJson(item));
          }
        }
      }
      emit(ServicesLoadedState(categories));
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(ServicesErrorState(error));
    }
  }

  Future<void> searchServices(String query) async {
    emit(SearchLoadingState());
    try {
      final response = await DioHelper.getData(
        endPoint: ApiConstants.searchServices,
        query: {'q': query},
      );
      final catsList = <ServiceCategoryModel>[];
      if (response.data['categories'] is List) {
        for (final item in response.data['categories']) {
          if (item is Map<String, dynamic>) {
            catsList.add(ServiceCategoryModel.fromJson(item));
          }
        }
      }
      final srvsList = <ServiceModel>[];
      if (response.data['services'] is List) {
        for (final item in response.data['services']) {
          if (item is Map<String, dynamic>) {
            srvsList.add(ServiceModel.fromJson(item));
          }
        }
      }
      emit(SearchLoadedState(categories: catsList, services: srvsList));
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(SearchErrorState(error));
    }
  }
}



