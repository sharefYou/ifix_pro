import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/api/api_constants.dart';
import 'package:ifix_client/core/api/dio_helper.dart';
import 'package:ifix_client/core/helpers/error_handler.dart';
import '../data/models/custom_request_model.dart';
import 'custom_requests_states.dart';

class CustomRequestsCubit extends Cubit<CustomRequestsStates> {
  CustomRequestsCubit() : super(CustomRequestsInitialState());

  List<CustomRequestModel> myRequests = [];
  List<BidModel> currentBids = [];

  Future<void> fetchMyCustomRequests() async {
    emit(CustomRequestsLoadingState());
    try {
      // If there's an endpoint for listing custom requests
      // Mocking or fetching from general list
      myRequests = [];
      emit(CustomRequestsLoadedState(myRequests));
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(CustomRequestsErrorState(error));
    }
  }

  Future<void> createCustomRequest({
    required String description,
    required String visitDate,
  }) async {
    emit(CreateCustomRequestLoadingState());
    try {
      final response = await DioHelper.postData(
        endPoint: ApiConstants.customRequests,
        data: {
          'description': description,
          'visit_date': visitDate,
        },
      );
      final newReq = CustomRequestModel.fromJson(response.data['data']);
      myRequests.insert(0, newReq);
      emit(CreateCustomRequestSuccessState(newReq));
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(CreateCustomRequestErrorState(error));
    }
  }

  Future<void> fetchBids(int customRequestId) async {
    emit(BidsLoadingState());
    try {
      final response = await DioHelper.getData(
        endPoint: ApiConstants.customRequestBids(customRequestId),
      );
      currentBids = [];
      if (response.data['data'] is List) {
        for (final item in response.data['data']) {
          if (item is Map<String, dynamic>) {
            currentBids.add(BidModel.fromJson(item));
          }
        }
      }
      emit(BidsLoadedState(currentBids));
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(BidsErrorState(error));
    }
  }

  Future<void> acceptBid({
    required int customRequestId,
    required int bidId,
    required int serviceId,
    required String visitType,
    required String paymentMethod,
  }) async {
    emit(AcceptBidLoadingState());
    try {
      await DioHelper.postData(
        endPoint: ApiConstants.acceptBid(customRequestId, bidId),
        data: {
          'service_id': serviceId,
          'visit_type': visitType,
          'payment_method': paymentMethod,
        },
      );
      emit(AcceptBidSuccessState('تم قبول العرض وتحويله إلى طلب صيانة مؤكد'));
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(AcceptBidErrorState(error));
    }
  }
}
