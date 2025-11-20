enum TransactionType {
  income,
  expense;

  String get name {
    switch (this) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
    }
  }
}
