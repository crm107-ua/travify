import 'package:flutter_test/flutter_test.dart';
import 'package:travify/enums/expense_category.dart';
import 'package:travify/models/expense.dart';

void main() {
  group('Expense model', () {
    test('toMap and fromMap', () {
      final expense = Expense(
        id: 1,
        tripId: 1,
        date: DateTime(2024, 1, 1),
        description: 'Food',
        amount: 10.0,
        category: ExpenseCategory.food,
        isAmortization: false,
      );

      final map = expense.toMap();
      final fromMap = Expense.fromMap({
        'id': map['id'],
        'trip_id': map['trip_id'],
        'type': map['type'],
        'date': map['date'],
        'description': map['description'],
        'amount': map['amount'],
        'category': map['category'],
        'isAmortization': map['isAmortization'],
        'amortization': map['amortization'],
        'start_date_amortization': map['startDateAmortization'],
        'end_date_amortization': map['endDateAmortization'],
        'next_amortization_date': map['nextAmortizationDate'],
      });

      expect(fromMap.id, expense.id);
      expect(fromMap.tripId, expense.tripId);
      expect(fromMap.amount, expense.amount);
      expect(fromMap.category, expense.category);
      expect(fromMap.isAmortization, expense.isAmortization);
    });

    test('copy method', () {
      final expense = Expense(
        id: 1,
        tripId: 1,
        date: DateTime(2024, 1, 1),
        description: 'Food',
        amount: 10.0,
        category: ExpenseCategory.food,
        isAmortization: false,
      );

      final copy = expense.copy(amount: 20.0);
      expect(copy.id, expense.id);
      expect(copy.amount, 20.0);
      expect(copy.category, expense.category);
    });

    test('toString includes category', () {
      final expense = Expense(
        id: 2,
        tripId: 1,
        date: DateTime(2024, 1, 1),
        amount: 5.0,
        category: ExpenseCategory.transport,
        isAmortization: false,
      );

      final str = expense.toString();
      expect(str.contains('transport'), isTrue);
    });
  });
}
