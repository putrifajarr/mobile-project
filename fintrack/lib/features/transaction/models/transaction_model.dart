import 'category_model.dart';

class TransactionModel {
  final String id;
  final String userId;
  final int categoryId;
  final double amount;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  // Optional: Populated when fetching with join
  final CategoryModel? category;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdAt,
    this.category,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    CategoryModel? cat;
    if (json['master_categories'] != null) {
      cat = CategoryModel.fromJson(json['master_categories']);
    }

    return TransactionModel(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['created_at']),
      category: cat,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
