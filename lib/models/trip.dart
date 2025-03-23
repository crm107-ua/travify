import 'package:travify/models/budget.dart';
import 'package:travify/models/country.dart';
import 'package:travify/models/currency.dart';
import 'package:travify/models/transaction.dart';

class Trip {
  final int id;
  String title;
  String? description;
  DateTime dateStart;
  DateTime? dateEnd;
  String destination;
  String? image;
  bool open;
  Budget budget;
  Currency currency;
  List<Country> countries;
  List<Transaction> transactions;

  Trip({
    required this.id,
    required this.title,
    this.description,
    required this.dateStart,
    this.dateEnd,
    required this.destination,
    this.image,
    this.open = true,
    required this.budget,
    required this.currency,
    required this.countries,
    List<Transaction>? transactions,
  }) : transactions = transactions ?? [];

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
      'budget': budget.toMap(),
      'currency': currency.toMap(),
      'countries': countries.map((country) => country.toMap()).toList(),
      'transactions':
          transactions.map((transaction) => transaction.toMap()).toList(),
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map,
      {Budget? budget,
      Currency? currency,
      List<Country>? countries,
      List<Transaction>? transactions}) {
    return Trip(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      dateStart: DateTime.fromMillisecondsSinceEpoch(map['date_start']),
      dateEnd: map['date_end'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date_end'])
          : null,
      destination: map['destination'],
      image: map['image'] ?? '',
      open: map['open'] == 1,
      budget: budget ?? Budget.fromMap(map['budget']),
      currency: currency ?? Currency.fromMap(map['currency']),
      countries: countries ?? [],
      transactions: transactions ?? [],
    );
  }

  Trip copy({
    int? id,
    String? title,
    String? description,
    DateTime? dateStart,
    DateTime? dateEnd,
    String? destination,
    String? image,
    bool? open,
    Budget? budget,
    List<Country>? countries,
    List<Transaction>? transactions,
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
      budget: budget ?? this.budget,
      currency: currency,
      countries: countries ?? this.countries,
      transactions: transactions ?? this.transactions,
    );
  }

  void addCountry(Country country) {
    countries.add(country);
  }

  void removeCountry(Country country) {
    countries.remove(country);
  }

  void updateCountry(Country country) {
    final index = countries.indexWhere((element) => element.id == country.id);
    if (index != -1) {
      countries[index] = country;
    }
  }

  void addTransaction(Transaction transaction) {
    transactions.add(transaction);
  }

  void removeTransaction(Transaction transaction) {
    transactions.remove(transaction);
  }

  void updateTransaction(Transaction transaction) {
    final index =
        transactions.indexWhere((element) => element.id == transaction.id);
    if (index != -1) {
      transactions[index] = transaction;
    }
  }

  @override
  String toString() {
    return 'Trip{id: $id, title: $title, description: $description, dateStart: $dateStart, dateEnd: $dateEnd, destination: $destination, image: $image, open: $open, budget: $budget, currency: $currency, countries: $countries, transactions: $transactions}';
  }
}
