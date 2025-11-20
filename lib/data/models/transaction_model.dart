import '../../utils/enums/transaction_type.dart';
import 'category_model.dart';

class TransactionModel {
  final int? id;
  final double amount;
  final TransactionType type;
  final int categoryId;
  final String note;
  final DateTime date;
  final DateTime createdAt;

  // This will be populated when fetching from database with JOIN
  CategoryModel? category;

  TransactionModel({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.note = '',
    required this.date,
    DateTime? createdAt,
    this.category,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert Model to Map (for database insertion)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type.toString(),
      'category_id': categoryId,
      'note': note,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Convert Map to Model (from database)
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: map['amount'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == map['type'],
      ),
      categoryId: map['category_id'],
      note: map['note'] ?? '',
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // Copy with method
  TransactionModel copyWith({
    int? id,
    double? amount,
    TransactionType? type,
    int? categoryId,
    String? note,
    DateTime? date,
    DateTime? createdAt,
    CategoryModel? category,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }

  // Helper method to check if it's income
  bool get isIncome => type == TransactionType.income;

  // Helper method to check if it's expense
  bool get isExpense => type == TransactionType.expense;
}
