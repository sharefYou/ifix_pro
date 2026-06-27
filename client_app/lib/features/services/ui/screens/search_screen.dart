import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/helpers/extensions.dart';
import '../../data/models/service_model.dart';
import '../../manager/services_cubit.dart';
import '../../manager/services_states.dart';
import 'service_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const Color backgroundColor = Color(0xFFFAF5EE);
  static const Color tertiaryColor = Color(0xFF8C3C3C);
  static const Color borderColor = Color(0xFFD8D0C8);
  static const Color textColor = Color(0xFF3A302A);

  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
          leading: const BackButton(color: textColor),
          title: TextField(
            controller: searchController,
            style: const TextStyle(color: textColor),
            decoration: const InputDecoration(
              hintText: 'ابحث عن خدمة صيانة...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey),
            ),
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                context.read<ServicesCubit>().searchServices(val.trim());
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: tertiaryColor),
              onPressed: () {
                if (searchController.text.trim().isNotEmpty) {
                  context.read<ServicesCubit>().searchServices(searchController.text.trim());
                }
              },
            ),
          ],
        ),
        body: BlocBuilder<ServicesCubit, ServicesStates>(
          builder: (context, state) {
            if (state is SearchLoadingState) {
              return const Center(child: CircularProgressIndicator(color: tertiaryColor));
            } else if (state is SearchErrorState) {
              return Center(child: Text(state.error, style: const TextStyle(color: textColor)));
            } else if (state is SearchLoadedState) {
              if (state.services.isEmpty && state.categories.isEmpty) {
                return const Center(child: Text('لم يتم العثور على نتائج مطابقة', style: TextStyle(color: textColor)));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.services.length,
                separatorBuilder: (context, i) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final srv = state.services[idx];
                  return _buildResultTile(srv);
                },
              );
            }
            return const Center(
              child: Text('ادخل كلمة البحث لظهور الخدمات', style: TextStyle(color: Colors.grey)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultTile(ServiceModel service) {
    return ListTile(
      onTap: () => context.push(ServiceDetailsScreen(service: service)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderColor),
      ),
      tileColor: Colors.white,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: tertiaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: const Icon(Icons.build, color: tertiaryColor),
      ),
      title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold, color: textColor)),
      subtitle: Text(
        '${service.price} ريال',
        style: const TextStyle(color: tertiaryColor, fontWeight: FontWeight.bold),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }
}
