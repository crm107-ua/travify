import 'package:travify/models/currency.dart';

class Country {
  final int id;
  String name;
  String code;
  List<Currency> currencies;

  Country(
      {required this.id,
      required this.name,
      required this.code,
      required this.currencies});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'currencies': currencies.map((currency) => currency.toMap()).toList()
    };
  }

  factory Country.fromMap(Map<String, dynamic> map) {
    return Country(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      currencies: List<Currency>.from(
          map['currencies'].map((currency) => Currency.fromMap(currency))),
    );
  }

  Country copy({
    int? id,
    String? name,
    String? code,
  }) {
    return Country(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      currencies: currencies,
    );
  }

  @override
  String toString() {
    return 'Country{id: $id, name: $name, code: $code}, currencies: $currencies';
  }
}
