enum ExpenseCategory {
  accommodation,
  food,
  transport,
  tourism,
  others,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get key {
    switch (this) {
      case ExpenseCategory.accommodation:
        return 'accommodation';
      case ExpenseCategory.food:
        return 'food';
      case ExpenseCategory.transport:
        return 'transport';
      case ExpenseCategory.tourism:
        return 'tourism';
      case ExpenseCategory.others:
        return 'others';
    }
  }
}
