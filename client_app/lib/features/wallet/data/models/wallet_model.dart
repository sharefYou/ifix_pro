class WalletModel {
  final int id;
  final double availableBalance;
  final double heldBalance;

  WalletModel({
    required this.id,
    required this.availableBalance,
    required this.heldBalance,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      availableBalance: json['available_balance'] is num
          ? (json['available_balance'] as num).toDouble()
          : double.tryParse(json['available_balance'].toString()) ?? 0.0,
      heldBalance: json['held_balance'] is num
          ? (json['held_balance'] as num).toDouble()
          : double.tryParse(json['held_balance'].toString()) ?? 0.0,
    );
  }
}

class WalletTransactionModel {
  final int id;
  final double amount;
  final String type; // deposit, withdrawal, hold, release
  final String status;
  final String? createdAt;

  WalletTransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount'].toString()) ?? 0.0,
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
    );
  }
}



