class AnalyticsSummary {
  final double totalEarnings;
  final double thisMonthEarnings;
  final int completedJobs;
  final double averageRating;

  AnalyticsSummary({
    required this.totalEarnings,
    required this.thisMonthEarnings,
    required this.completedJobs,
    required this.averageRating,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      thisMonthEarnings: (json['this_month_earnings'] as num?)?.toDouble() ?? 0.0,
      completedJobs: (json['completed_jobs'] as num?)?.toInt() ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 4.8,
    );
  }
}

class EarningPoint {
  final String label;
  final double amount;

  EarningPoint({required this.label, required this.amount});

  factory EarningPoint.fromJson(Map<String, dynamic> json, {bool isMonthly = false}) {
    return EarningPoint(
      label: isMonthly ? (json['month']?.toString() ?? '') : (json['day']?.toString() ?? ''),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CategoryPoint {
  final String name;
  final int count;
  final double amount;

  CategoryPoint({required this.name, required this.count, required this.amount});

  factory CategoryPoint.fromJson(Map<String, dynamic> json) {
    return CategoryPoint(
      name: json['name']?.toString() ?? 'أخرى',
      count: (json['count'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AnalyticsModel {
  final AnalyticsSummary summary;
  final List<EarningPoint> weeklyEarnings;
  final List<EarningPoint> monthlyEarnings;
  final List<CategoryPoint> categoryBreakdown;
  final bool isMock;

  AnalyticsModel({
    required this.summary,
    required this.weeklyEarnings,
    required this.monthlyEarnings,
    required this.categoryBreakdown,
    this.isMock = false,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    final isMockFlag = json['is_mock'] as bool? ?? false;
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final summary = AnalyticsSummary.fromJson(data['summary'] as Map<String, dynamic>? ?? {});

    final weeklyList = (data['weekly_earnings'] as List<dynamic>? ?? [])
        .map((e) => EarningPoint.fromJson(e as Map<String, dynamic>, isMonthly: false))
        .toList();

    final monthlyList = (data['monthly_earnings'] as List<dynamic>? ?? [])
        .map((e) => EarningPoint.fromJson(e as Map<String, dynamic>, isMonthly: true))
        .toList();

    final catList = (data['category_breakdown'] as List<dynamic>? ?? [])
        .map((e) => CategoryPoint.fromJson(e as Map<String, dynamic>))
        .toList();

    return AnalyticsModel(
      summary: summary,
      weeklyEarnings: weeklyList,
      monthlyEarnings: monthlyList,
      categoryBreakdown: catList,
      isMock: isMockFlag,
    );
  }
}
