class Currency {
  final int id;
  final String code;
  final String name;
  final String? symbol;

  Currency({
    required this.id,
    required this.code,
    required this.name,
    this.symbol,
  });

  /// Convierte la instancia de [Currency] a un [Map].
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'symbol': symbol,
    };
  }

  /// Crea una instancia de [Currency] a partir de un [Map].
  factory Currency.fromMap(Map<String, dynamic> map) {
    return Currency(
      id: map['id'],
      code: map['code'],
      name: map['name'],
      symbol: map['symbol'],
    );
  }

  /// Crea una copia de la instancia actual con la posibilidad de sobrescribir algunos campos.
  Currency copy({
    int? id,
    String? code,
    String? name,
    String? symbol,
  }) {
    return Currency(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
    );
  }

  @override
  String toString() {
    return 'Currency(id: $id, code: $code, name: $name, symbol: $symbol)';
  }
}
