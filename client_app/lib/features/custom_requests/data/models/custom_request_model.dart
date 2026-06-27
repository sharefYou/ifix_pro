class CustomRequestModel {
  final int id;
  final String description;
  final String? visitDate;
  final String status; // pending, accepted, cancelled
  final String? createdAt;

  CustomRequestModel({
    required this.id,
    required this.description,
    this.visitDate,
    required this.status,
    this.createdAt,
  });

  factory CustomRequestModel.fromJson(Map<String, dynamic> json) {
    return CustomRequestModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      description: json['description']?.toString() ?? '',
      visitDate: json['visit_date']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString(),
    );
  }

  String get statusArabic {
    switch (status) {
      case 'pending':
        return 'بانتظار العروض';
      case 'accepted':
        return 'تم قبول عرض';
      case 'cancelled':
      case 'rejected':
        return 'ملغي';
      default:
        return status;
    }
  }
}

class BidModel {
  final int id;
  final int technicianId;
  final String? technicianName;
  final double price;
  final String status;
  final String? createdAt;

  BidModel({
    required this.id,
    required this.technicianId,
    this.technicianName,
    required this.price,
    required this.status,
    this.createdAt,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      technicianId: json['technician_id'] is int
          ? json['technician_id']
          : int.tryParse(json['technician_id'].toString()) ?? 0,
      technicianName: json['technician_name']?.toString(),
      price: json['price'] is num ? (json['price'] as num).toDouble() : double.tryParse(json['price'].toString()) ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString(),
    );
  }
}
