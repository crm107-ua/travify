enum ExpenseCategory {
  accommodation,
  food,
  transport,
  tourism,
  others,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.accommodation:
        return 'Accommodation';
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.tourism:
        return 'Tourism';
      case ExpenseCategory.others:
        return 'Others';
    }
  }
}
