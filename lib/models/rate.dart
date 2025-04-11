import 'package:travify/models/currency.dart';

class Rate {
  final int id;
  Currency currencyFrom;
  Currency currencyTo;
  double rate;

  Rate({
    required this.id,
    required this.currencyFrom,
    required this.currencyTo,
    required this.rate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'currencyFrom': currencyFrom.toMap(),
      'currencyTo': currencyTo.toMap(),
      'rate': rate,
    };
  }

  factory Rate.fromMap(Map<String, dynamic> map) {
    return Rate(
      id: map['id'],
      currencyFrom: Currency.fromMap(map['currencyFrom']),
      currencyTo: Currency.fromMap(map['currencyTo']),
      rate: map['rate'],
    );
  }

  Rate copy({
    int? id,
    Currency? currencyFrom,
    Currency? currencyTo,
    double? rate,
  }) {
    return Rate(
      id: id ?? this.id,
      currencyFrom: currencyFrom ?? this.currencyFrom,
      currencyTo: currencyTo ?? this.currencyTo,
      rate: rate ?? this.rate,
    );
  }

  @override
  String toString() {
    return 'Rate{id: $id, currencyFrom: $currencyFrom, currencyTo: $currencyTo, rate: $rate}';
  }
}
