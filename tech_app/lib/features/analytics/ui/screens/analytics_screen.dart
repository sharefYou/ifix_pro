import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ifix_card.dart';
import '../../logic/analytics_cubit.dart';
import '../../data/models/analytics_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _showMonthly = false;

  @override
  void initState() {
    super.initState();
    context.read<AnalyticsCubit>().loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحليلات المالية والأداء'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded),
        ),
      ),
      body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          } else if (state is AnalyticsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.error, style: const TextStyle(color: Colors.red, fontFamily: 'Cairo')),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<AnalyticsCubit>().loadAnalytics(),
                    child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')),
                  ),
                ],
              ),
            );
          } else if (state is AnalyticsLoaded) {
            final data = state.data;
            final chartPoints = _showMonthly ? data.monthlyEarnings : data.weeklyEarnings;

            return RefreshIndicator(
              onRefresh: () => context.read<AnalyticsCubit>().loadAnalytics(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data.isMock) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.gold),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'تعرض هذه اللوحة أرقاماً توضيحية لنموذج الأداء حتى تقوم بإنجاز أول طلب صيانة في التطبيق.',
                                style: TextStyle(color: AppColors.gold, fontSize: 12, fontFamily: 'Cairo'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Summary Cards Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _StatCard(title: 'إجمالي الأرباح', value: '${data.summary.totalEarnings}', unit: 'ريال', icon: Icons.account_balance_wallet_rounded, color: AppColors.gold),
                        _StatCard(title: 'أرباح الشهر', value: '${data.summary.thisMonthEarnings}', unit: 'ريال', icon: Icons.calendar_today_rounded, color: AppColors.accent),
                        _StatCard(title: 'المهام المنجزة', value: '${data.summary.completedJobs}', unit: 'مهمة', icon: Icons.check_circle_rounded, color: Colors.green),
                        _StatCard(title: 'تقييم العملاء', value: '${data.summary.averageRating}', unit: '⭐', icon: Icons.star_rounded, color: Colors.amber),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Chart Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('معدل الأرباح', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              _TabButton(title: 'أسبوعي', isSelected: !_showMonthly, onTap: () => setState(() => _showMonthly = false)),
                              _TabButton(title: 'شهري', isSelected: _showMonthly, onTap: () => setState(() => _showMonthly = true)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Bar Chart
                    IFixCard(
                      padding: const EdgeInsets.only(top: 24, bottom: 12, left: 12, right: 12),
                      child: SizedBox(
                        height: 220,
                        child: _buildBarChart(chartPoints),
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text('توزيع الإيرادات حسب الخدمة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                    const SizedBox(height: 16),

                    // Pie Chart & Legend
                    IFixCard(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 180,
                            child: _buildPieChart(data.categoryBreakdown),
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 12),
                          _buildCategoryLegend(data.categoryBreakdown),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildBarChart(List<EarningPoint> points) {
    if (points.isEmpty) {
      return const Center(child: Text('لا توجد بيانات كافية للرسم البياني', style: TextStyle(fontFamily: 'Cairo')));
    }

    double maxY = 0;
    for (final p in points) {
      if (p.amount > maxY) maxY = p.amount;
    }
    if (maxY == 0) maxY = 1000;
    maxY = maxY * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.surfaceVariant,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} ريال',
                const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < points.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      points[idx].label,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Cairo'),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: points.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.amount,
                color: AppColors.gold,
                width: 16,
                borderRadius: BorderRadius.circular(6),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart(List<CategoryPoint> categories) {
    if (categories.isEmpty) {
      return const Center(child: Text('لا توجد بيانات تصنيفات', style: TextStyle(fontFamily: 'Cairo')));
    }

    final colors = [AppColors.gold, AppColors.accent, Colors.purpleAccent, Colors.orange, Colors.teal];

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 36,
        sections: categories.asMap().entries.map((e) {
          final col = colors[e.key % colors.length];
          return PieChartSectionData(
            color: col,
            value: e.value.amount > 0 ? e.value.amount : 1,
            title: '${e.value.count}',
            radius: 45,
            titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Cairo'),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryLegend(List<CategoryPoint> categories) {
    final colors = [AppColors.gold, AppColors.accent, Colors.purpleAccent, Colors.orange, Colors.teal];

    return Column(
      children: categories.asMap().entries.map((e) {
        final col = colors[e.key % colors.length];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: col, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(e.value.name, style: const TextStyle(fontSize: 13, fontFamily: 'Cairo')),
                ],
              ),
              Text('${e.value.amount} ريال (${e.value.count} طلب)', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IFixCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.caption.copyWith(fontSize: 12)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color, fontFamily: 'Cairo')),
              const SizedBox(width: 4),
              Text(unit, style: AppTextStyles.caption.copyWith(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({required this.title, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}
