enum TransactionType {
  income,
  expense,
  change,
}

extension TransactionTypeExtension on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.income:
        return 'income';
      case TransactionType.expense:
        return 'expense';
      case TransactionType.change:
        return 'change';
    }
  }
}
