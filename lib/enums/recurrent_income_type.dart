enum RecurrentIncomeType {
  daily,
  weekly,
  monthly,
  yearly,
}

extension RecurrentIncomeTypeExtension on RecurrentIncomeType {
  String get label {
    switch (this) {
      case RecurrentIncomeType.daily:
        return 'Daily';
      case RecurrentIncomeType.weekly:
        return 'Weekly';
      case RecurrentIncomeType.monthly:
        return 'Monthly';
      case RecurrentIncomeType.yearly:
        return 'Yearly';
    }
  }
}
