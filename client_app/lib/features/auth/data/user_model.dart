class UserModel {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String city;
  final double lat;
  final double lng;
  final String image;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.city,
    required this.lat,
    required this.lng,
    required this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    email: json["email"],
    city: json["city"],
    lat: json["lat"].toDouble(),
    lng: json["lng"].toDouble(),
    image: json["image"],
  );

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
