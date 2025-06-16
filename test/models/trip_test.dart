import 'package:flutter_test/flutter_test.dart';
import 'package:travify/models/budget.dart';
import 'package:travify/models/country.dart';
import 'package:travify/models/currency.dart';
import 'package:travify/models/expense.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/enums/expense_category.dart';
import 'package:travify/models/income.dart';
import 'package:travify/enums/recurrent_income_type.dart';

void main() {
  group('Trip model', () {
    final currency = Currency(
      id: 1,
      code: 'USD',
      name: 'Dollar',
      symbol: '\$',
      symbolNative: '\$',
      decimalDigits: 2,
    );

    final country = Country(
      id: 1,
      name: 'USA',
      code: 'US',
      currencies: [currency],
    );

    final budget = Budget(
      id: 1,
      maxLimit: 1000,
      desiredLimit: 800,
      accumulated: 0,
      limitIncrease: false,
    );

    test('toMap and fromMap', () {
      final trip = Trip(
        id: 1,
        title: 'Test',
        dateStart: DateTime(2024, 1, 1),
        dateEnd: DateTime(2024, 1, 10),
        destination: 'NY',
        image: 'img.png',
        open: true,
        budget: budget,
        currency: currency,
        countries: [country],
        transactions: [],
      );

      final map = trip.toMap();
      final fromMap = Trip.fromMap(map,
          budget: budget, currency: currency, countries: [country], transactions: []);

      expect(fromMap.id, trip.id);
      expect(fromMap.title, trip.title);
      expect(fromMap.destination, trip.destination);
      expect(fromMap.countries.first.name, country.name);
    });

    test('toMap/fromMap without optionals', () {
      final trip = Trip(
        id: 2,
        title: 'Bare',
        dateStart: DateTime(2024, 2, 2),
        destination: 'LA',
        budget: budget,
        currency: currency,
        countries: [country],
      );

      final map = trip.toMap();
      final fromMap = Trip.fromMap(map,
          budget: budget, currency: currency, countries: [country], transactions: []);

      expect(fromMap.description, '');
      expect(fromMap.dateEnd, isNull);
      expect(fromMap.image, '');
    });

    test('copy method and mutators', () {
      final trip = Trip(
        id: 1,
        title: 'Test',
        dateStart: DateTime(2024, 1, 1),
        destination: 'NY',
        image: 'img.png',
        open: true,
        budget: budget,
        currency: currency,
        countries: [country],
      );

      final copy = trip.copy(title: 'Updated');
      expect(copy.id, trip.id);
      expect(copy.title, 'Updated');

      final expense = Expense(
        id: 1,
        tripId: 1,
        date: DateTime(2024, 1, 2),
        amount: 20,
        category: ExpenseCategory.food,
        isAmortization: false,
      );
      final income = Income(
        id: 2,
        tripId: 1,
        date: DateTime(2024, 1, 3),
        amount: 100,
        isRecurrent: false,
        recurrentIncomeType: RecurrentIncomeType.daily,
      );

      copy.addCountry(country);
      expect(copy.countries.length, 2);
      copy.removeCountry(country);
      expect(copy.countries.length, 1);

      copy.addTransaction(expense);
      copy.addTransaction(income);
      expect(copy.transactions.length, 2);
      copy.removeTransaction(expense);
      expect(copy.transactions.length, 1);
    });

    test('updateCountry and updateTransaction', () {
      final trip = Trip(
        id: 1,
        title: 'Test',
        dateStart: DateTime(2024, 1, 1),
        destination: 'NY',
        budget: budget,
        currency: currency,
        countries: [country],
      );

      final updatedCountry = country.copy(name: 'Canada');
      trip.updateCountry(updatedCountry);
      expect(trip.countries.first.name, 'Canada');

      final expense = Expense(
        id: 1,
        tripId: 1,
        date: DateTime(2024, 1, 2),
        amount: 20,
        category: ExpenseCategory.food,
        isAmortization: false,
      );
      trip.addTransaction(expense);

      final updatedExpense = expense.copy(amount: 50);
      trip.updateTransaction(updatedExpense);
      expect(trip.transactions.first.amount, 50);
    });
  });
}
