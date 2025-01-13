import 'package:travify/enums/transaction_type.dart';
import 'package:travify/models/trip.dart';

class Transaction {
  final int id;
  TransactionType type;
  DateTime date;
  String? description;
  double amount;
  Trip trip;

  Transaction({
    required this.id,
    required this.type,
    required this.date,
    this.description,
    required this.amount,
    required this.trip,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'modeId': type.index,
      'date': date.millisecondsSinceEpoch,
      'description': description,
      'amount': amount,
      'trip': trip.toMap(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: TransactionType.values[map['type']],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'],
      amount: map['amount'],
      trip: Trip.fromMap(map['trip']),
    );
  }

  Transaction copy({
    int? id,
    int? modeId,
    DateTime? date,
    String? description,
    double? amount,
    Trip? trip,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: modeId != null ? TransactionType.values[modeId] : type,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      trip: trip ?? this.trip,
    );
  }

  @override
  String toString() {
    return 'Transaction{id: $id, type: $type, date: $date, description: $description, amount: $amount, trip: $trip}';
  }
}
