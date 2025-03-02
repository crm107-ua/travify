import 'package:travify/enums/transaction_type.dart';
import 'package:travify/models/currency.dart';
import 'package:travify/models/transaction.dart';
import 'package:travify/models/trip.dart';

class Change extends Transaction {
  @override
  TransactionType get type => TransactionType.change;

  Currency currencyRecived;
  Currency currencySpent;
  double amountRecived;

  Change({
    required super.id,
    required super.date,
    super.description,
    required super.amount,
    required this.currencyRecived,
    required this.currencySpent,
    required this.amountRecived,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'date': date.millisecondsSinceEpoch,
      'description': description,
      'amount': amount,
      'currencyRecived': currencyRecived.toMap(),
      'currencySpent': currencySpent.toMap(),
      'amountRecived': amountRecived,
    };
  }

  @override
  factory Change.fromMap(Map<String, dynamic> map) {
    return Change(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'],
      amount: map['amount'],
      currencyRecived: Currency.fromMap(map['currencyRecived']),
      currencySpent: Currency.fromMap(map['currencySpent']),
      amountRecived: map['amount_recived'],
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
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currencyRecived: currencyRecived ?? this.currencyRecived,
      currencySpent: currencySpent ?? this.currencySpent,
      amountRecived: amountRecived ?? this.amountRecived,
    );
  }

  @override
  String toString() {
    return 'Change{id: $id, date: $date, description: $description, amount: $amount, currencyRecived: $currencyRecived, currencySpent: $currencySpent, amountRecived: $amountRecived}';
  }
}
