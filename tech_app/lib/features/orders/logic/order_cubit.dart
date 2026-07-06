import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geolocator/geolocator.dart';
import '../data/repos/order_repo.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _repo;

  OrderCubit(this._repo) : super(OrderInitial());

  String _getLocalizedFallback(String key) {
    switch (key) {
      case 'accept':
        return 'accept_order'.tr();
      case 'complete':
        return 'complete_order'.tr();
      default:
        return '';
    }
  }

  Future<void> getAvailableOrders() async {
    emit(OrderLoading());
    try {
      final orders = await _repo.getAvailableOrders();
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> getMyOrders() async {
    emit(OrderLoading());
    try {
      final orders = await _repo.getMyOrders();
      emit(MyOrdersLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> sortOrdersByProximity({double? techLat, double? techLng}) async {
    double lat = techLat ?? 24.7136;
    double lng = techLng ?? 46.6753;
    try {
      final position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium));
      lat = position.latitude;
      lng = position.longitude;
    } catch (_) {
      // Fallback to Riyadh center or provided coordinates
    }

    if (state is OrdersLoaded) {
      final currentOrders = List<dynamic>.from((state as OrdersLoaded).orders);
      currentOrders.sort((a, b) {
        final aLat = double.tryParse(a['user']?['lat']?.toString() ?? '') ?? 24.7136;
        final aLng = double.tryParse(a['user']?['lng']?.toString() ?? '') ?? 46.6753;
        final bLat = double.tryParse(b['user']?['lat']?.toString() ?? '') ?? 24.7136;
        final bLng = double.tryParse(b['user']?['lng']?.toString() ?? '') ?? 46.6753;
        
        final distA = Geolocator.distanceBetween(lat, lng, aLat, aLng);
        final distB = Geolocator.distanceBetween(lat, lng, bLat, bLng);
        return distA.compareTo(distB);
      });
      emit(OrdersLoaded(currentOrders));
    } else if (state is MyOrdersLoaded) {
      final currentOrders = List<dynamic>.from((state as MyOrdersLoaded).orders);
      currentOrders.sort((a, b) {
        final aLat = double.tryParse(a['user']?['lat']?.toString() ?? '') ?? 24.7136;
        final aLng = double.tryParse(a['user']?['lng']?.toString() ?? '') ?? 46.6753;
        final bLat = double.tryParse(b['user']?['lat']?.toString() ?? '') ?? 24.7136;
        final bLng = double.tryParse(b['user']?['lng']?.toString() ?? '') ?? 46.6753;
        
        final distA = Geolocator.distanceBetween(lat, lng, aLat, aLng);
        final distB = Geolocator.distanceBetween(lat, lng, bLat, bLng);
        return distA.compareTo(distB);
      });
      emit(MyOrdersLoaded(currentOrders));
    }
  }

  Future<void> acceptOrder(int orderId) async {
    emit(OrderActionLoading());
    try {
      final message = await _repo.acceptOrder(orderId);
      emit(OrderActionSuccess(message.isNotEmpty ? message : _getLocalizedFallback('accept')));
      await getAvailableOrders();
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> completeOrder(int orderId) async {
    emit(OrderActionLoading());
    try {
      final message = await _repo.completeOrder(orderId);
      emit(OrderActionSuccess(message.isNotEmpty ? message : _getLocalizedFallback('complete')));
      await getMyOrders();
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
