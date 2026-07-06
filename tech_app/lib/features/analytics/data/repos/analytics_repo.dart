import '../../../../core/api/dio_factory.dart';
import '../models/analytics_model.dart';

class AnalyticsRepo {
  Future<AnalyticsModel> getAnalytics() async {
    final dio = await DioFactory.getDio();
    final response = await dio.get('analytics');
    return AnalyticsModel.fromJson(response.data as Map<String, dynamic>);
  }
}
