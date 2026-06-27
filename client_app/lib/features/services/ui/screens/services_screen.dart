import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/helpers/extensions.dart';
import '../../data/models/service_model.dart';
import '../../manager/services_cubit.dart';
import '../../manager/services_states.dart';
import 'search_screen.dart';
import 'service_details_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  static const Color backgroundColor = Color(0xFFFAF5EE);
  static const Color tertiaryColor = Color(0xFF8C3C3C);
  static const Color borderColor = Color(0xFFD8D0C8);
  static const Color textColor = Color(0xFF3A302A);

  @override
  void initState() {
    super.initState();
    context.read<ServicesCubit>().fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          title: const Text(
            'خدمات الصيانة المنزلية',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: textColor),
              onPressed: () => context.push(const SearchScreen()),
            ),
          ],
        ),
        body: BlocBuilder<ServicesCubit, ServicesStates>(
          builder: (context, state) {
            if (state is ServicesLoadingState) {
              return const Center(
                child: CircularProgressIndicator(color: tertiaryColor),
              );
            } else if (state is ServicesErrorState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: tertiaryColor),
                    const SizedBox(height: 16),
                    Text(state.error, style: const TextStyle(color: textColor)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: tertiaryColor),
                      onPressed: () => context.read<ServicesCubit>().fetchServices(),
                      child: const Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            } else if (state is ServicesLoadedState) {
              if (state.categories.isEmpty) {
                return const Center(child: Text('لا توجد خدمات متاحة حالياً', style: TextStyle(color: textColor)));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  return _buildCategorySection(category);
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildCategorySection(ServiceCategoryModel category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
        ),
        if (category.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(category.description, style: TextStyle(fontSize: 14, color: textColor.withValues(alpha: 0.6))),
        ],
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: category.services.length,
          itemBuilder: (context, sIdx) {
            final service = category.services[sIdx];
            return _buildServiceCard(service);
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return InkWell(
      onTap: () => context.push(ServiceDetailsScreen(service: service)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(color: textColor.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tertiaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.home_repair_service, color: tertiaryColor, size: 30),
            ),
            const Spacer(),
            Text(
              service.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${service.price} ريال',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: tertiaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
