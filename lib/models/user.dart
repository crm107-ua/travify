import 'package:travify/models/country.dart';
import 'package:travify/models/trip.dart';

class User {
  String name;
  int age;
  String email;
  String image;
  Country country;
  List<Trip> trips;

  User({
    required this.name,
    required this.age,
    required this.email,
    required this.image,
    required this.country,
    List<Trip>? trips,
  }) : trips = trips ?? [];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'email': email,
      'image': image,
      'country': country.toMap(),
      'trips': trips.map((trip) => trip.toMap()).toList(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'],
      age: map['age'],
      email: map['email'],
      image: map['image'],
      country: Country.fromMap(map['country']),
      trips: List<Trip>.from(map['trips'].map((trip) => Trip.fromMap(trip))),
    );
  }

  User copy({
    String? name,
    int? age,
    String? email,
    String? image,
  }) {
    return User(
      name: name ?? this.name,
      age: age ?? this.age,
      email: email ?? this.email,
      image: image ?? this.image,
      country: country,
      trips: trips,
    );
  }

  void addTrip(Trip trip) {
    trips.add(trip);
  }

  void removeTrip(Trip trip) {
    trips.remove(trip);
  }

  void updateTrip(Trip trip) {
    final index = trips.indexWhere((element) => element.id == trip.id);
    if (index != -1) {
      trips[index] = trip;
    }
  }

  @override
  String toString() {
    return 'User{name: $name, age: $age, email: $email, image: $image, country: $country}, trips: $trips';
  }
}
