import 'package:travify/enums/transaction_type.dart';
import 'package:travify/models/currency.dart';
import 'package:travify/models/transaction.dart';
import 'package:travify/models/trip.dart';

class Change extends Transaction {
  @override
  TransactionType get type => TransactionType.change;

  Currency currencyRecived;
  Currency currencySpent;
  double commission;
  double amountRecived;

  Change({
    required super.id,
    required super.tripId,
    required super.date,
    super.description,
    required super.amount,
    required this.currencyRecived,
    required this.currencySpent,
    required this.commission,
    required this.amountRecived,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'type': type.index,
      'date': date.millisecondsSinceEpoch,
      'description': description,
      'amount': amount,
      'currencyRecived': currencyRecived.toMap(),
      'currencySpent': currencySpent.toMap(),
      'commission': commission,
      'amountRecived': amountRecived,
    };
  }

  @override
  factory Change.fromMap(Map<String, dynamic> map) {
    return Change(
      id: map['id'],
      tripId: map['trip_id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'],
      amount: map['amount'],
      currencyRecived: Currency.fromMap(map['currencyRecived']),
      currencySpent: Currency.fromMap(map['currencySpent']),
      commission: map['commission'],
      amountRecived: map['amount_recived'],
    );
  }

  @override
  Change copy({
    int? id,
    int? tripId,
    int? modeId,
    DateTime? date,
    String? description,
    double? amount,
    Trip? trip,
    Currency? currencyRecived,
    Currency? currencySpent,
    double? commission,
    double? amountRecived,
  }) {
    return Change(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currencyRecived: currencyRecived ?? this.currencyRecived,
      currencySpent: currencySpent ?? this.currencySpent,
      commission: commission ?? this.commission,
      amountRecived: amountRecived ?? this.amountRecived,
    );
  }

  @override
  String toString() {
    return 'Change{id: $id, tripId: $tripId, date: $date, description: $description, amount: $amount, currencyRecived: $currencyRecived, currencySpent: $currencySpent, commission: $commission, amountRecived: $amountRecived}';
  }
}
