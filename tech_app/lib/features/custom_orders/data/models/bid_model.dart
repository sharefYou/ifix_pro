import 'custom_order_model.dart';

class BidModel {
  final int id;
  final int customRequestId;
  final int technicianId;
  final double price;
  final double? laborCost;
  final double? partsCost;
  final String? notes;
  final double? counterPrice;
  final String? counterNotes;
  final String? counterBy;
  final String? counterStatus;
  final String status;
  final String? createdAt;
  final CustomOrderModel? customRequest;

  BidModel({
    required this.id,
    required this.customRequestId,
    required this.technicianId,
    required this.price,
    this.laborCost,
    this.partsCost,
    this.notes,
    this.counterPrice,
    this.counterNotes,
    this.counterBy,
    this.counterStatus,
    required this.status,
    this.createdAt,
    this.customRequest,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      id: json['id'] as int? ?? 0,
      customRequestId: json['custom_request_id'] as int? ?? 0,
      technicianId: json['technician_id'] as int? ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      laborCost: json['labor_cost'] != null ? double.tryParse(json['labor_cost'].toString()) : null,
      partsCost: json['parts_cost'] != null ? double.tryParse(json['parts_cost'].toString()) : null,
      notes: json['notes']?.toString(),
      counterPrice: json['counter_price'] != null ? double.tryParse(json['counter_price'].toString()) : null,
      counterNotes: json['counter_notes']?.toString(),
      counterBy: json['counter_by']?.toString(),
      counterStatus: json['counter_status']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString(),
      customRequest: json['custom_request'] != null ? CustomOrderModel.fromJson(json['custom_request']) : null,
    );
  }
}
