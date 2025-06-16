import 'package:flutter_test/flutter_test.dart';
import 'package:travify/models/currency.dart';

void main() {
  group('Currency model', () {
    test('toMap and fromMap', () {
      final currency = Currency(
        id: 1,
        code: 'USD',
        name: 'US Dollar',
        symbol: '\$',
        symbolNative: '\$',
        decimalDigits: 2,
      );

      final map = currency.toMap();
      final fromMap = Currency.fromMap(map);

      expect(fromMap.id, currency.id);
      expect(fromMap.code, currency.code);
      expect(fromMap.name, currency.name);
      expect(fromMap.symbol, currency.symbol);
      expect(fromMap.symbolNative, currency.symbolNative);
      expect(fromMap.decimalDigits, currency.decimalDigits);
    });

    test('copy method', () {
      final currency = Currency(
        id: 1,
        code: 'USD',
        name: 'US Dollar',
        symbol: '\$',
        symbolNative: '\$',
        decimalDigits: 2,
      );

      final copy = currency.copy(name: 'Dollar');
      expect(copy.id, currency.id);
      expect(copy.code, currency.code);
      expect(copy.name, 'Dollar');
      expect(copy.symbol, currency.symbol);
    });
  });
}
