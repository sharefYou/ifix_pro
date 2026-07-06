import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/helpers/extensions.dart';
import '../../data/models/service_model.dart';
import '../../manager/services_cubit.dart';
import '../../manager/services_states.dart';
import 'category_services_screen.dart';
import 'search_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  static const Color backgroundColor = Color(0xFF0D1117);
  static const Color tertiaryColor = Color(0xFF2979FF);
  static const Color borderColor = Color(0xFF30363D);
  static const Color textColor = Color(0xFFF0F6FC);

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
            'أقسام الصيانة المنزلية',
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
              final categories = state.categories;
              if (categories.isEmpty) {
                return const Center(child: Text('لا توجد أقسام متاحة حالياً', style: TextStyle(color: textColor)));
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _buildCategoryCard(category);
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(ServiceCategoryModel category) {
    return InkWell(
      onTap: () => context.push(CategoryServicesScreen(category: category)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(color: textColor.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4)),
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
              child: category.icon != null
                  ? Image.network(category.icon!, width: 28, height: 28, errorBuilder: (_, _, _) => const Icon(Icons.category_outlined, color: tertiaryColor, size: 28))
                  : const Icon(Icons.category_outlined, color: tertiaryColor, size: 28),
            ),
            const Spacer(),
            Text(
              category.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${category.services.length} خدمة صيانة',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}



