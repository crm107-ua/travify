class Country {
  final int id;
  String name;
  String code;

  Country({
    required this.id,
    required this.name,
    required this.code,
  });

  /// Convierte el objeto Country a un mapa para la inserción en la base de datos.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }

  /// Crea una instancia de Country a partir de un mapa recuperado de la base de datos.
  factory Country.fromMap(Map<String, dynamic> map) {
    return Country(
      id: map['id'],
      name: map['name'],
      code: map['code'],
    );
  }

  /// Crea una copia de la instancia actual con la posibilidad de sobrescribir algunos campos.
  Country copy({
    int? id,
    String? name,
    String? code,
  }) {
    return Country(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
    );
  }

  @override
  String toString() {
    return 'Country{id: $id, name: $name, code: $code}';
  }
}
