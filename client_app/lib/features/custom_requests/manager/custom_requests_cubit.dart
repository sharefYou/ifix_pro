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
      final response = await DioHelper.getData(endPoint: ApiConstants.customRequests);
      myRequests = [];
      if (response.data['data'] is List) {
        for (final item in response.data['data']) {
          if (item is Map<String, dynamic>) {
            myRequests.add(CustomRequestModel.fromJson(item));
          }
        }
      }
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
      await fetchMyCustomRequests();
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(AcceptBidErrorState(error));
    }
  }

  Future<void> counterOffer({
    required int customRequestId,
    required int bidId,
    required double counterPrice,
    String? counterNotes,
  }) async {
    emit(CounterOfferLoadingState());
    try {
      await DioHelper.postData(
        endPoint: ApiConstants.counterOffer(customRequestId, bidId),
        data: {
          'counter_price': counterPrice,
          if (counterNotes != null && counterNotes.isNotEmpty) 'counter_notes': counterNotes,
        },
      );
      emit(CounterOfferSuccessState('تم إرسال العرض المقابل للفني بنجاح'));
      await fetchBids(customRequestId);
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(CounterOfferErrorState(error));
    }
  }
}



