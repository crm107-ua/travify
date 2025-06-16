import 'package:flutter_test/flutter_test.dart';
import 'package:travify/models/country.dart';
import 'package:travify/models/currency.dart';

void main() {
  group('Country model', () {
    final currency = Currency(
      id: 1,
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      symbolNative: '€',
      decimalDigits: 2,
    );

    test('toMap and fromMap', () {
      final country = Country(
        id: 1,
        name: 'Spain',
        code: 'ES',
        currencies: [currency],
      );

      final map = country.toMap();
      final fromMap = Country.fromMap(map, currencies: [currency]);

      expect(fromMap.id, country.id);
      expect(fromMap.name, country.name);
      expect(fromMap.code, country.code);
      expect(fromMap.currencies.first.code, currency.code);
    });

    test('copy method', () {
      final country = Country(
        id: 1,
        name: 'Spain',
        code: 'ES',
        currencies: [currency],
      );

      final copy = country.copy(name: 'España');
      expect(copy.id, country.id);
      expect(copy.name, 'España');
      expect(copy.code, country.code);
    });
  });
}
