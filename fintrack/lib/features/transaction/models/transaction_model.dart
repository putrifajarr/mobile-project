class TransactionModel {
  String id;
  String type; // income / expense
  DateTime date;
  double amount;
  String description;
  String category;

  TransactionModel({
    required this.id,
    required this.type,
    required this.date,
    required this.amount,
    required this.description,
    required this.category,
  });

  // JSON → Model (untuk Supabase fetch)
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      type: json['type'],
      date: DateTime.parse(json['date']),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] ?? "",
      category: json['category'] ?? "",
    );
  }

  // Model → JSON (kalau mau kirim ke Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'date': date.toIso8601String(),
      'amount': amount,
      'description': description,
      'category': category,
    };
  }
}
