import 'package:travify/models/trip.dart';

class Budget {
  final int id;
  double maxLimit;
  double desiredLimit;
  double accumulated;
  bool limitIncrease;
  Trip trip;

  Budget(
      {required this.id,
      required this.maxLimit,
      required this.desiredLimit,
      required this.accumulated,
      this.limitIncrease = false,
      required this.trip});

  /// Convierte el objeto Budget a un mapa para la inserción en la base de datos.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'maxLimit': maxLimit,
      'desiredLimit': desiredLimit,
      'accumulated': accumulated,
      'limitIncrease': limitIncrease ? 1 : 0,
      'trip': trip.toMap(),
    };
  }

  /// Crea una instancia de Budget a partir de un mapa recuperado de la base de datos.
  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      maxLimit: map['maxLimit'],
      desiredLimit: map['desiredLimit'],
      accumulated: map['accumulated'],
      limitIncrease: map['limitIncrease'] == 1,
      trip: Trip.fromMap(map['trip']),
    );
  }

  /// Crea una copia de la instancia actual con la posibilidad de sobrescribir algunos campos.
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
      limitIncrease: limitIncrease ?? this.limitIncrease,
      trip: trip ?? this.trip,
    );
  }

  @override
  String toString() {
    return 'Budget{id: $id, maxLimit: $maxLimit, desiredLimit: $desiredLimit, accumulated: $accumulated, limitIncrease: $limitIncrease, trip: $trip}';
  }
}
