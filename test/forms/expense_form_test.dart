import 'package:flutter_test/flutter_test.dart';
import 'package:travify/screens/forms/form_expense.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/models/budget.dart';
import 'package:travify/models/currency.dart';
import 'package:travify/models/country.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExpenseForm logic', () {
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

    final trip = Trip(
      id: 1,
      title: 'Trip',
      dateStart: DateTime(2024, 1, 1),
      destination: 'NY',
      budget: Budget(
        id: 1,
        maxLimit: 1000,
        desiredLimit: 800,
        accumulated: 0,
      ),
      currency: currency,
      countries: [country],
    );

    test('isFutureDate', () {
      final widget = ExpenseForm(onSave: (_) {}, trip: trip);
      final state = widget.createState();
      final dynamic dynamicState = state;

      final today = DateTime.now();
      expect(dynamicState.isFutureDate(today.add(const Duration(days: 1))), isTrue);
      expect(dynamicState.isFutureDate(today.subtract(const Duration(days: 1))), isFalse);
      expect(dynamicState.isFutureDate(today), isFalse);
    });

    test('calcularNextAmortizationDate', () {
      final widget = ExpenseForm(onSave: (_) {}, trip: trip);
      final state = widget.createState();
      final dynamic dynamicState = state;

      final now = DateTime.now();
      final start = now.add(const Duration(days: 1));
      final end = now.add(const Duration(days: 5));
      final result = dynamicState.calcularNextAmortizationDate(startDate: start, endDate: end);
      expect(result, start);

      final pastStart = now.subtract(const Duration(days: 2));
      final pastEnd = now.subtract(const Duration(days: 1));
      final result2 = dynamicState.calcularNextAmortizationDate(startDate: pastStart, endDate: pastEnd);
      expect(result2, isNull);
    });

    test('_calculateDailyAmortization variations', () {
      final tripWithEnd = Trip(
        id: 2,
        title: 'Trip',
        dateStart: DateTime(2024, 1, 1),
        dateEnd: DateTime(2024, 1, 5),
        destination: 'NY',
        budget: trip.budget,
        currency: currency,
        countries: [country],
      );

      final widget = ExpenseForm(onSave: (_) {}, trip: tripWithEnd);
      final state = widget.createState();
      final dynamic s = state;

      s._amountController.text = '100';
      s._startDateAmortization = DateTime(2024, 1, 1);
      s._endDateAmortization = DateTime(2024, 1, 5);
      s._calculateDailyAmortization();
      expect(s._dailyAmortization, 20.0);

      s._startDateAmortization = null;
      s._endDateAmortization = null;
      s._amountController.text = '50';
      s._calculateDailyAmortization();
      expect(s._dailyAmortization, 10.0);
    });
  });
}
