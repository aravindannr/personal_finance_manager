import '../../utils/enums/category_type.dart';
import '../../utils/enums/transaction_type.dart';

class CategoryModel {
  final int? id;
  final String name;
  final CategoryType type;
  final TransactionType transactionType; // income or expense

  CategoryModel({
    this.id,
    required this.name,
    required this.type,
    required this.transactionType,
  });

  // Convert Model to Map (for database insertion)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'transaction_type': transactionType.toString(),
    };
  }

  // Convert Map to Model (from database)
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      type: CategoryType.values.firstWhere((e) => e.toString() == map['type']),
      transactionType: TransactionType.values.firstWhere(
        (e) => e.toString() == map['transaction_type'],
      ),
    );
  }

  // Copy with method (useful for updating)
  CategoryModel copyWith({
    int? id,
    String? name,
    CategoryType? type,
    TransactionType? transactionType,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      transactionType: transactionType ?? this.transactionType,
    );
  }
}
