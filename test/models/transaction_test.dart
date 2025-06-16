import 'package:flutter_test/flutter_test.dart';
import 'package:travify/models/expense.dart';
import 'package:travify/models/income.dart';
import 'package:travify/models/change.dart';
import 'package:travify/models/transaction.dart';
import 'package:travify/models/currency.dart';
import 'package:travify/enums/expense_category.dart';
import 'package:travify/enums/recurrent_income_type.dart';

void main() {
  group('Transaction fromMap', () {
    final currency = Currency(
      id: 1,
      code: 'USD',
      name: 'Dollar',
      symbol: '\$',
      symbolNative: '\$',
      decimalDigits: 2,
    );

    test('expense', () {
      final expense = Expense(
        id: 1,
        tripId: 1,
        date: DateTime(2024, 1, 1),
        amount: 10,
        category: ExpenseCategory.food,
        isAmortization: false,
      );
      final map = expense.toMap();
      final tx = Transaction.fromMap(map);
      expect(tx is Expense, true);
    });

    test('income', () {
      final income = Income(
        id: 2,
        tripId: 1,
        date: DateTime(2024, 1, 1),
        amount: 10,
        isRecurrent: true,
        recurrentIncomeType: RecurrentIncomeType.daily,
      );
      final map = income.toMap();
      final tx = Transaction.fromMap(map);
      expect(tx is Income, true);
    });

    test('change', () {
      final change = Change(
        id: 3,
        tripId: 1,
        date: DateTime(2024, 1, 1),
        amount: 10,
        currencyRecived: currency,
        currencySpent: currency,
        commission: 0,
        amountRecived: 10,
      );
      final map = change.toMap();
      final tx = Transaction.fromMap(map);
      expect(tx is Change, true);
    });

    test('toTransactionMap base fields', () {
      final expense = Expense(
        id: 4,
        tripId: 7,
        date: DateTime(2024, 3, 3),
        amount: 15,
        category: ExpenseCategory.food,
        isAmortization: false,
      );

      final map = expense.toTransactionMap();
      expect(map['trip_id'], 7);
      expect(map['amount'], 15);
    });
  });
}
