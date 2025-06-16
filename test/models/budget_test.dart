import 'package:flutter_test/flutter_test.dart';
import 'package:travify/models/budget.dart';

void main() {
  group('Budget model', () {
    test('toMap and fromMap', () {
      final budget = Budget(
        id: 1,
        maxLimit: 1000.0,
        desiredLimit: 800.0,
        accumulated: 200.0,
        limitIncrease: true,
      );

      final map = budget.toMap();
      final fromMap = Budget.fromMap({
        'id': map['id'],
        'max_limit': map['maxLimit'],
        'desired_limit': map['desiredLimit'],
        'accumulated': map['accumulated'],
        'limit_increase': map['limitIncrease'],
      });

      expect(fromMap.id, budget.id);
      expect(fromMap.maxLimit, budget.maxLimit);
      expect(fromMap.desiredLimit, budget.desiredLimit);
      expect(fromMap.accumulated, budget.accumulated);
      expect(fromMap.limitIncrease, budget.limitIncrease);
    });

    test('copy method', () {
      final budget = Budget(
        id: 1,
        maxLimit: 1000.0,
        desiredLimit: 800.0,
        accumulated: 200.0,
        limitIncrease: false,
      );

      final copy = budget.copy(maxLimit: 1200.0, limitIncrease: true);
      expect(copy.id, budget.id);
      expect(copy.maxLimit, 1200.0);
      expect(copy.desiredLimit, budget.desiredLimit);
      expect(copy.accumulated, budget.accumulated);
      expect(copy.limitIncrease, true);
    });

    test('toString contains values', () {
      final budget = Budget(
        id: 5,
        maxLimit: 500,
        desiredLimit: 400,
        accumulated: 100,
      );

      final str = budget.toString();
      expect(str.contains('maxLimit: 500'), isTrue);
      expect(str.contains('desiredLimit: 400'), isTrue);
    });
  });
}
