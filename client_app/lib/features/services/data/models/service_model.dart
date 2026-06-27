class ServiceModel {
  final int id;
  final int categoryId;
  final String name;
  final String description;
  final double price;

  ServiceModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      categoryId: json['category_id'] is int ? json['category_id'] : int.tryParse(json['category_id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price'] is num ? (json['price'] as num).toDouble() : double.tryParse(json['price'].toString()) ?? 0.0,
    );
  }
}

class ServiceCategoryModel {
  final int id;
  final String name;
  final String description;
  final List<ServiceModel> services;

  ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.services,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    final servicesList = <ServiceModel>[];
    if (json['services'] is List) {
      for (final item in json['services']) {
        if (item is Map<String, dynamic>) {
          servicesList.add(ServiceModel.fromJson(item));
        }
      }
    }
    return ServiceCategoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      services: servicesList,
    );
  }
}
