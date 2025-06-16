import 'package:flutter_test/flutter_test.dart';
import 'package:travify/models/user.dart';
import 'package:travify/models/trip.dart';
import 'package:travify/models/budget.dart';
import 'package:travify/models/currency.dart';
import 'package:travify/models/country.dart';

void main() {
  group('User model', () {
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
        title: 'Trip',
        dateStart: DateTime(2024, 1, 1),
        destination: 'NY',
        budget: budget,
        currency: currency,
        countries: [country],
      );

      final user = User(
        name: 'John',
        age: 30,
        email: 'j@example.com',
        image: 'img.png',
        country: country,
        trips: [trip],
      );

      final map = user.toMap();
      final fromMap = User.fromMap(map);

      expect(fromMap.name, user.name);
      expect(fromMap.age, user.age);
      expect(fromMap.country.code, country.code);
      expect(fromMap.trips.first.title, trip.title);
    });

    test('copy and trip operations', () {
      final user = User(
        name: 'John',
        age: 30,
        email: 'j@example.com',
        image: 'img.png',
        country: country,
      );

      final trip = Trip(
        id: 1,
        title: 'Trip',
        dateStart: DateTime(2024, 1, 1),
        destination: 'NY',
        budget: budget,
        currency: currency,
        countries: [country],
      );

      user.addTrip(trip);
      expect(user.trips.length, 1);
      user.removeTrip(trip);
      expect(user.trips.isEmpty, true);

      user.addTrip(trip);
      final updated = trip.copy(title: 'Updated');
      user.updateTrip(updated);
      expect(user.trips.first.title, 'Updated');

      final copy = user.copy(name: 'Jane');
      expect(copy.name, 'Jane');
      expect(copy.age, user.age);
    });

    test('toString includes email', () {
      final user = User(
        name: 'Ann',
        age: 25,
        email: 'a@a.com',
        image: 'img.png',
        country: country,
      );

      expect(user.toString().contains('a@a.com'), isTrue);
    });
  });
}
