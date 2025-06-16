import 'package:flutter_test/flutter_test.dart';
import 'package:travify/models/rate.dart';
import 'package:travify/models/currency.dart';

void main() {
  group('Rate model', () {
    final usd = Currency(
      id: 1,
      code: 'USD',
      name: 'Dollar',
      symbol: '\$',
      symbolNative: '\$',
      decimalDigits: 2,
    );

    final eur = Currency(
      id: 2,
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      symbolNative: '€',
      decimalDigits: 2,
    );

    test('toMap and fromMap', () {
      final rate = Rate(id: 1, currencyFrom: usd, currencyTo: eur, rate: 0.9);
      final map = rate.toMap();
      final fromMap = Rate.fromMap(map);
      expect(fromMap.id, rate.id);
      expect(fromMap.currencyFrom.code, usd.code);
      expect(fromMap.currencyTo.code, eur.code);
      expect(fromMap.rate, rate.rate);
    });

    test('copy method', () {
      final rate = Rate(id: 1, currencyFrom: usd, currencyTo: eur, rate: 0.9);
      final copy = rate.copy(rate: 1.1);
      expect(copy.id, rate.id);
      expect(copy.rate, 1.1);
      expect(copy.currencyFrom.code, usd.code);
    });
  });
}
