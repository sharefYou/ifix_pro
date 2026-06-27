class UserModel {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? city;
  final double? lat;
  final double? lng;
  final String? avatar;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.city,
    this.lat,
    this.lng,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      city: json['city']?.toString(),
      lat: json['lat'] is num ? (json['lat'] as num).toDouble() : double.tryParse(json['lat']?.toString() ?? ''),
      lng: json['lng'] is num ? (json['lng'] as num).toDouble() : double.tryParse(json['lng']?.toString() ?? ''),
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'city': city,
        'lat': lat,
        'lng': lng,
        'avatar': avatar,
      };
}
