class UserModel {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? city;
  final double? lat;
  final double? lng;
  final String? image;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.city,
    this.lat,
    this.lng,
    this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? rawImage = json["image"]?.toString();
    if (rawImage != null && rawImage.isNotEmpty) {
      const baseUrl = 'https://sharef.alwaysdata.net';
      if (rawImage.contains('localhost') || rawImage.contains('127.0.0.1') || rawImage.contains('10.0.2.2')) {
        final uri = Uri.tryParse(rawImage);
        if (uri != null && uri.path.isNotEmpty) rawImage = '$baseUrl${uri.path}';
      } else if (!rawImage.startsWith('http')) {
        rawImage = rawImage.startsWith('/') ? '$baseUrl$rawImage' : '$baseUrl/$rawImage';
      }
    }
    return UserModel(
      id: int.tryParse(json["id"]?.toString() ?? "0") ?? 0,
      name: json["name"]?.toString() ?? "",
      phone: json["phone"]?.toString() ?? "",
      email: json["email"]?.toString(),
      city: json["city"]?.toString(),
      lat: double.tryParse(json["lat"]?.toString() ?? ""),
      lng: double.tryParse(json["lng"]?.toString() ?? ""),
      image: rawImage,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "email": email,
    "city": city,
    "lat": lat,
    "lng": lng,
    "image": image,
  };
}
