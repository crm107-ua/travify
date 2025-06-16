import 'package:flutter_test/flutter_test.dart';
import 'package:travify/models/change.dart';
import 'package:travify/models/currency.dart';

void main() {
  group('Change model', () {
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
      final change = Change(
        id: 1,
        tripId: 1,
        date: DateTime(2024, 1, 1),
        description: 'Change',
        amount: 100.0,
        currencyRecived: eur,
        currencySpent: usd,
        commission: 2.0,
        amountRecived: 98.0,
      );

      final map = change.toMap();
      final fromMap = Change.fromMap({
        'id': map['id'],
        'trip_id': map['trip_id'],
        'type': map['type'],
        'date': map['date'],
        'description': map['description'],
        'amount': map['amount'],
        'currencyRecived': map['currencyRecived'],
        'currencySpent': map['currencySpent'],
        'commission': map['commission'],
        'amount_recived': map['amountRecived'],
      });

      expect(fromMap.id, change.id);
      expect(fromMap.currencyRecived.code, eur.code);
      expect(fromMap.currencySpent.code, usd.code);
      expect(fromMap.commission, change.commission);
    });

    test('copy method', () {
      final change = Change(
        id: 1,
        tripId: 1,
        date: DateTime(2024, 1, 1),
        description: 'Change',
        amount: 100.0,
        currencyRecived: eur,
        currencySpent: usd,
        commission: 2.0,
        amountRecived: 98.0,
      );

      final copy = change.copy(commission: 1.0);
      expect(copy.id, change.id);
      expect(copy.commission, 1.0);
      expect(copy.currencySpent.code, usd.code);
    });
  });
}
