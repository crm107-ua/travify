import 'package:flutter_test/flutter_test.dart';
import 'package:travify/enums/recurrent_income_type.dart';
import 'package:travify/models/income.dart';

void main() {
  group('Income model', () {
    test('toMap and fromMap', () {
      final income = Income(
        id: 1,
        tripId: 1,
        date: DateTime(2024, 1, 1),
        description: 'Salary',
        amount: 500.0,
        isRecurrent: true,
        recurrentIncomeType: RecurrentIncomeType.monthly,
        nextRecurrentDate: DateTime(2024, 2, 1),
        active: true,
      );

      final map = income.toMap();
      final fromMap = Income.fromMap({
        'id': map['id'],
        'trip_id': map['trip_id'],
        'type': map['type'],
        'date': map['date'],
        'description': map['description'],
        'amount': map['amount'],
        'is_recurrent': map['isRecurrent'],
        'recurrent_income_type': map['recurrentIncomeType'],
        'next_recurrent_date': map['nextRecurrentDate'],
        'active': map['active'],
      });

      expect(fromMap.id, income.id);
      expect(fromMap.tripId, income.tripId);
      expect(fromMap.amount, income.amount);
      expect(fromMap.isRecurrent, income.isRecurrent);
      expect(fromMap.recurrentIncomeType, income.recurrentIncomeType);
    });

    test('copy method', () {
      final income = Income(
        id: 1,
        tripId: 1,
        date: DateTime(2024, 1, 1),
        description: 'Salary',
        amount: 500.0,
      );

      final copy = income.copy(amount: 1000.0, isRecurrent: true);
      expect(copy.id, income.id);
      expect(copy.amount, 1000.0);
      expect(copy.isRecurrent, true);
    });

    test('toString shows amount', () {
      final income = Income(
        id: 2,
        tripId: 1,
        date: DateTime(2024, 1, 1),
        amount: 200.0,
      );

      expect(income.toString().contains('200.0'), isTrue);
    });
  });
}
