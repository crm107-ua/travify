import 'package:flutter_test/flutter_test.dart';
import 'package:travify/screens/forms/form_travel.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/models/budget.dart';
import 'package:travify/models/country.dart';
import 'package:travify/models/currency.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CreateOrEditTravelWizard logic', () {
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

    test('_onStepCancel decreases step', () {
      final widget = CreateOrEditTravelWizard(trip: trip);
      final state = widget.createState();
      final dynamic s = state;

      s._currentStep = 1;
      s._onStepCancel();
      expect(s._currentStep, 0);
    });

    test('_onStepCancel at zero stays zero', () {
      final widget = CreateOrEditTravelWizard(trip: trip);
      final state = widget.createState();
      final dynamic s = state;

      s._currentStep = 0;
      s._onStepCancel();
      expect(s._currentStep, 0);
    });
  });
}
