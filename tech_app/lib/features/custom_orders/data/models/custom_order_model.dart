class CustomOrderModel {
  final int id;
  final String description;
  final String visitDate;
  final String status;
  final String? userName;
  final String? city;
  final String? audioMemoPath;
  final String? videoPath;
  final List<String> images;
  final String? createdAt;

  CustomOrderModel({
    required this.id,
    required this.description,
    required this.visitDate,
    required this.status,
    this.userName,
    this.city,
    this.audioMemoPath,
    this.videoPath,
    required this.images,
    this.createdAt,
  });

  factory CustomOrderModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>?;
    final imagesList = json['images'] as List<dynamic>? ?? [];
    return CustomOrderModel(
      id: json['id'] as int? ?? 0,
      description: json['description']?.toString() ?? '',
      visitDate: json['visit_date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      userName: userJson != null ? userJson['name']?.toString() : json['user_name']?.toString(),
      city: userJson != null ? userJson['city']?.toString() : json['city']?.toString(),
      audioMemoPath: json['audio_memo_path']?.toString(),
      videoPath: json['video_path']?.toString(),
      images: imagesList.map((e) => (e is Map ? e['path']?.toString() : e.toString()) ?? '').where((s) => s.isNotEmpty).toList(),
      createdAt: json['created_at']?.toString(),
    );
  }
}
