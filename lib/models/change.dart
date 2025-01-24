import 'package:travify/enums/transaction_type.dart';
import 'package:travify/models/currency.dart';
import 'package:travify/models/transaction.dart';
import 'package:travify/models/trip.dart';

class Change extends Transaction {
  Currency currencyRecived;
  Currency currencySpent;
  double amountRecived;

  Change({
    required super.id,
    required super.type,
    required super.date,
    super.description,
    required super.amount,
    required super.trip,
    required this.currencyRecived,
    required this.currencySpent,
    required this.amountRecived,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'currencyRecived': currencyRecived.toMap(),
      'currencySpent': currencySpent.toMap(),
      'amountRecived': amountRecived,
    };
  }

  @override
  factory Change.fromMap(Map<String, dynamic> map) {
    return Change(
      id: map['id'],
      type: TransactionType.values[map['type']],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'],
      amount: map['amount'],
      trip: Trip.fromMap(map['trip']),
      currencyRecived: Currency.fromMap(map['currencyRecived']),
      currencySpent: Currency.fromMap(map['currencySpent']),
      amountRecived: map['amountRecived'],
    );
  }

  @override
  Change copy({
    int? id,
    int? modeId,
    DateTime? date,
    String? description,
    double? amount,
    Trip? trip,
    Currency? currencyRecived,
    Currency? currencySpent,
    double? amountRecived,
  }) {
    return Change(
      id: id ?? this.id,
      type: modeId != null ? TransactionType.values[modeId] : type,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      trip: trip ?? this.trip,
      currencyRecived: currencyRecived ?? this.currencyRecived,
      currencySpent: currencySpent ?? this.currencySpent,
      amountRecived: amountRecived ?? this.amountRecived,
    );
  }

  @override
  String toString() {
    return 'Change{id: $id, type: $type, date: $date, description: $description, amount: $amount, trip: $trip, currencyRecived: $currencyRecived, currencySpent: $currencySpent, amountRecived: $amountRecived}';
  }
}
