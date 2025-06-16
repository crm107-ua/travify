import 'package:flutter_test/flutter_test.dart';
import 'package:travify/screens/forms/form_income.dart';
import 'package:travify/enums/recurrent_income_type.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/models/budget.dart';
import 'package:travify/models/currency.dart';
import 'package:travify/models/country.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IncomeForm logic', () {
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

    test('_calculateNextDate', () {
      final widget = IncomeForm(onSave: (_) {}, trip: trip);
      final state = widget.createState();
      final dynamic s = state;

      s._selectedDate = DateTime(2024, 1, 1);
      s._recurrentType = RecurrentIncomeType.daily;
      s._calculateNextDate();
      expect(s._nextDate, DateTime(2024, 1, 2));

      s._recurrentType = RecurrentIncomeType.weekly;
      s._calculateNextDate();
      expect(s._nextDate, DateTime(2024, 1, 8));

      s._recurrentType = RecurrentIncomeType.monthly;
      s._calculateNextDate();
      expect(s._nextDate, DateTime(2024, 2, 1));

      s._recurrentType = RecurrentIncomeType.yearly;
      s._calculateNextDate();
      expect(s._nextDate, DateTime(2025, 1, 1));

      s._recurrentType = null;
      s._calculateNextDate();
      expect(s._nextDate, isNull);

      s._selectedDate = DateTime(2024, 1, 31);
      s._recurrentType = RecurrentIncomeType.monthly;
      s._calculateNextDate();
      expect(s._nextDate!.month, 3); // overflow to March
    });
  });
}
