class TransactionModel {
  String id;
  String type; // "income" atau "expense"
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
}
