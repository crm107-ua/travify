import 'package:travify/models/country.dart';

class Trip {
  final int id;
  String title;
  String? description;
  DateTime dateStart;
  DateTime? dateEnd;
  String destination;
  String? image;
  bool open;
  Country country;

  Trip({
    required this.id,
    required this.title,
    this.description,
    required this.dateStart,
    this.dateEnd,
    required this.destination,
    this.image,
    this.open = true,
    required this.country,
  });

  /// Convierte el objeto Trip a un mapa para la inserción en la base de datos.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateStart': dateStart.millisecondsSinceEpoch,
      'dateEnd': dateEnd?.millisecondsSinceEpoch,
      'destination': destination,
      'image': image,
      'open': open ? 1 : 0,
      'country': country.toMap(),
    };
  }

  /// Crea una instancia de Trip a partir de un mapa recuperado de la base de datos.
  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      dateStart: DateTime.fromMillisecondsSinceEpoch(map['fechaInicio']),
      dateEnd: map['fechaFin'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['fechaFin'])
          : null,
      destination: map['destino'],
      image: map['image'] ?? '',
      open: map['open'] == 1,
      country: Country.fromMap(map['country']),
    );
  }

  /// Crea una copia de la instancia actual con la posibilidad de sobrescribir algunos campos.
  Trip copy({
    int? id,
    String? title,
    String? description,
    DateTime? dateStart,
    DateTime? dateEnd,
    String? destination,
    String? image,
    bool? open,
    Country? country,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateStart: dateStart ?? this.dateStart,
      dateEnd: dateEnd ?? this.dateEnd,
      destination: destination ?? this.destination,
      image: image ?? this.image,
      open: open ?? this.open,
      country: country ?? this.country,
    );
  }

  @override
  String toString() {
    return 'Trip{id: $id, title: $title, description: $description, dateStart: $dateStart, dateEnd: $dateEnd, destination: $destination, image: $image, open: $open, country: $country}';
  }
}
