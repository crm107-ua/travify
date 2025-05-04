enum RecurrentIncomeType {
  daily,
  weekly,
  monthly,
  yearly,
}

extension RecurrentIncomeTypeExtension on RecurrentIncomeType {
  String get key {
    switch (this) {
      case RecurrentIncomeType.daily:
        return 'daily';
      case RecurrentIncomeType.weekly:
        return 'weekly';
      case RecurrentIncomeType.monthly:
        return 'monthly';
      case RecurrentIncomeType.yearly:
        return 'yearly';
    }
  }
}
