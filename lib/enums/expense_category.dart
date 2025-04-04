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
        return 'Alojamiento';
      case ExpenseCategory.food:
        return 'Comida';
      case ExpenseCategory.transport:
        return 'Transporte';
      case ExpenseCategory.tourism:
        return 'Turismo';
      case ExpenseCategory.others:
        return 'Otros';
    }
  }
}
