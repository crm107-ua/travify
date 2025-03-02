import 'package:travify/models/trip.dart';

class Budget {
  final int id;
  double maxLimit;
  double desiredLimit;
  double accumulated;
  bool limitIncrease;

  Budget({
    required this.id,
    required this.maxLimit,
    required this.desiredLimit,
    required this.accumulated,
    this.limitIncrease = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'maxLimit': maxLimit,
      'desiredLimit': desiredLimit,
      'accumulated': accumulated,
      'limitIncrease': limitIncrease ? 1 : 0
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
        id: map['id'],
        maxLimit: map['max_limit'],
        desiredLimit: map['desired_limit'],
        accumulated: map['accumulated'],
        limitIncrease: map['limit_increase'] == 1);
  }

  Budget copy({
    int? id,
    double? maxLimit,
    double? desiredLimit,
    double? accumulated,
    bool? limitIncrease,
    Trip? trip,
  }) {
    return Budget(
        id: id ?? this.id,
        maxLimit: maxLimit ?? this.maxLimit,
        desiredLimit: desiredLimit ?? this.desiredLimit,
        accumulated: accumulated ?? this.accumulated,
        limitIncrease: limitIncrease ?? this.limitIncrease);
  }

  @override
  String toString() {
    return 'Budget{id: $id, maxLimit: $maxLimit, desiredLimit: $desiredLimit, accumulated: $accumulated, limitIncrease: $limitIncrease }';
  }
}
