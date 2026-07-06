import '../data/models/service_model.dart';

abstract class ServicesStates {}

class ServicesInitialState extends ServicesStates {}

class ServicesLoadingState extends ServicesStates {}

class ServicesLoadedState extends ServicesStates {
  final List<ServiceCategoryModel> categories;
  ServicesLoadedState(this.categories);
}

class ServicesErrorState extends ServicesStates {
  final String error;
  ServicesErrorState(this.error);
}

class SearchLoadingState extends ServicesStates {}

class SearchLoadedState extends ServicesStates {
  final List<ServiceCategoryModel> categories;
  final List<ServiceModel> services;
  SearchLoadedState({required this.categories, required this.services});
}

class SearchErrorState extends ServicesStates {
  final String error;
  SearchErrorState(this.error);
}



