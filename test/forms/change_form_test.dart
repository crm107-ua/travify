import 'package:flutter_test/flutter_test.dart';
import 'package:travify/screens/forms/form_change.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/models/budget.dart';
import 'package:travify/models/country.dart';
import 'package:travify/models/currency.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChangeForm logic', () {
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

    test('onFormChanged sets state', () {
      final widget = ChangeForm(onSave: (_) {}, trip: trip);
      final state = widget.createState();
      final dynamic s = state;

      expect(() => s._onFormChanged(), returnsNormally);
    });
  });
}
