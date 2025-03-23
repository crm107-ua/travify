class Currency {
  final int id;
  final String code;
  final String name;
  final String symbol;
  final String symbolNative;
  final int decimalDigits;

  Currency(
      {required this.id,
      required this.code,
      required this.name,
      required this.symbol,
      required this.symbolNative,
      required this.decimalDigits});

  /// Convierte la instancia de [Currency] a un [Map].
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'symbol': symbol,
      'symbol_native': symbolNative,
      'decimal_digits': decimalDigits
    };
  }

  /// Crea una instancia de [Currency] a partir de un [Map].
  factory Currency.fromMap(Map<String, dynamic> map) {
    return Currency(
        id: map['id'],
        code: map['code'],
        name: map['name'],
        symbol: map['symbol'],
        symbolNative: map['symbol_native'],
        decimalDigits: map['decimal_digits']);
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
        symbolNative: symbolNative,
        decimalDigits: decimalDigits);
  }

  @override
  String toString() {
    return 'Currency(id: $id, code: $code, name: $name, symbol: $symbol, symbolNative: $symbolNative, decimalDigits: $decimalDigits)';
  }
}
