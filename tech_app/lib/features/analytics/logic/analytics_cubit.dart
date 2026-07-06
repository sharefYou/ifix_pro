import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/analytics_model.dart';
import '../data/repos/analytics_repo.dart';

abstract class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}
class AnalyticsLoading extends AnalyticsState {}
class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsModel data;
  AnalyticsLoaded(this.data);
}
class AnalyticsError extends AnalyticsState {
  final String error;
  AnalyticsError(this.error);
}

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final AnalyticsRepo _repo;

  AnalyticsCubit(this._repo) : super(AnalyticsInitial());

  Future<void> loadAnalytics() async {
    emit(AnalyticsLoading());
    try {
      final res = await _repo.getAnalytics();
      emit(AnalyticsLoaded(res));
    } catch (e) {
      emit(AnalyticsError('حدث خطأ أثناء تحميل البيانات المالية'));
    }
  }
}
