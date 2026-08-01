import '../../../../core/api/dio_factory.dart';
import '../../../../core/errors/error_handler.dart';
import '../models/custom_order_model.dart';
import '../models/bid_model.dart';

class CustomOrdersRepository {
  Future<List<CustomOrderModel>> getAvailableRequests() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get('custom-requests/available');
      final list = (response.data as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
      return list.map((e) => CustomOrderModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ErrorHandler.handleGeneralError(e);
    }
  }

  Future<List<BidModel>> getMyBids() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get('custom-requests/my-bids');
      final list = (response.data as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
      return list.map((e) => BidModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ErrorHandler.handleGeneralError(e);
    }
  }

  Future<BidModel> submitBid({
    required int customRequestId,
    required double price,
    double? laborCost,
    double? partsCost,
    String? notes,
  }) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post('custom-requests/$customRequestId/bids', data: {
        'price': price,
        'labor_cost': ?laborCost,
        'parts_cost': ?partsCost,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });
      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      return BidModel.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handleGeneralError(e);
    }
  }

  Future<BidModel> submitCounterOffer({
    required int bidId,
    required double counterPrice,
    String? counterNotes,
  }) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post('custom-requests/bids/$bidId/counter', data: {
        'counter_price': counterPrice,
        if (counterNotes != null && counterNotes.isNotEmpty) 'counter_notes': counterNotes,
      });
      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      return BidModel.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handleGeneralError(e);
    }
  }

  Future<BidModel> acceptCounterOffer(int bidId) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post('custom-requests/bids/$bidId/accept-counter');
      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      return BidModel.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handleGeneralError(e);
    }
  }
}
