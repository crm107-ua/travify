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
        return 'Diaria';
      case RecurrentIncomeType.weekly:
        return 'Semanal';
      case RecurrentIncomeType.monthly:
        return 'Mensual';
      case RecurrentIncomeType.yearly:
        return 'Anual';
    }
  }
}
