class OrderModel {
  final int id;
  final int userId;
  final int? technicianId;
  final int serviceId;
  final String status; // pending_tech, pending_customer, accepted, on_the_way, in_progress, completed, canceled
  final String visitType;
  final String? visitDate;
  final String? notes;
  final String paymentMethod;
  final double totalAmount;
  final String? serviceName;
  final String? technicianName;

  OrderModel({
    required this.id,
    required this.userId,
    this.technicianId,
    required this.serviceId,
    required this.status,
    required this.visitType,
    this.visitDate,
    this.notes,
    required this.paymentMethod,
    required this.totalAmount,
    this.serviceName,
    this.technicianName,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    String? srvName;
    if (json['service'] is Map) {
      srvName = json['service']['name']?.toString();
    }
    String? techName;
    if (json['technician'] is Map) {
      techName = json['technician']['name']?.toString();
    }
    return OrderModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      technicianId: json['technician_id'] != null
          ? (json['technician_id'] is int ? json['technician_id'] : int.tryParse(json['technician_id'].toString()))
          : null,
      serviceId: json['service_id'] is int ? json['service_id'] : int.tryParse(json['service_id'].toString()) ?? 0,
      status: json['status']?.toString() ?? 'pending_tech',
      visitType: json['visit_type']?.toString() ?? 'home',
      visitDate: json['visit_date']?.toString(),
      notes: json['notes']?.toString(),
      paymentMethod: json['payment_method']?.toString() ?? 'cash',
      totalAmount: json['total_amount'] is num
          ? (json['total_amount'] as num).toDouble()
          : double.tryParse(json['total_amount'].toString()) ?? 0.0,
      serviceName: srvName,
      technicianName: techName,
    );
  }

  String get statusArabic {
    switch (status) {
      case 'pending_tech':
      case 'pending_customer':
        return 'بانتظار التأكيد';
      case 'accepted':
        return 'تم القبول';
      case 'on_the_way':
        return 'الفني بالطريق';
      case 'in_progress':
        return 'جاري الصيانة';
      case 'completed':
        return 'مكتمل';
      case 'canceled':
        return 'ملغي';
      default:
        return status;
    }
  }
}



