enum TransactionType {
  income,
  expense,
  change,
}

extension TransactionTypeExtension on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.change:
        return 'Change';
    }
  }
}
