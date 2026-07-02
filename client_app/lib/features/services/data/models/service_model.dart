String? _fixEmulatorUrl(String? url) {
  if (url == null || url.trim().isEmpty) return null;
  var fixed = url.trim();
  const baseUrl = 'https://sharef.alwaysdata.net';
  if (fixed.contains('127.0.0.1') || fixed.contains('localhost') || fixed.contains('10.0.2.2')) {
    final uri = Uri.tryParse(fixed);
    if (uri != null && uri.path.isNotEmpty) {
      return '$baseUrl${uri.path}';
    }
  }
  if (!fixed.startsWith('http')) {
    if (fixed.startsWith('/')) {
      return '$baseUrl$fixed';
    }
    return '$baseUrl/$fixed';
  }
  return fixed;
}

class ServiceModel {
  final int id;
  final int categoryId;
  final String name;
  final String description;
  final double price;
  final String? image;

  ServiceModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    this.image,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      categoryId: json['category_id'] is int ? json['category_id'] : int.tryParse(json['category_id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price'] is num ? (json['price'] as num).toDouble() : double.tryParse(json['price'].toString()) ?? 0.0,
      image: _fixEmulatorUrl(json['image']?.toString()),
    );
  }
}

class ServiceCategoryModel {
  final int id;
  final String name;
  final String description;
  final String? icon;
  final List<ServiceModel> services;

  ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
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
      icon: _fixEmulatorUrl(json['icon']?.toString()),
      services: servicesList,
    );
  }
}
