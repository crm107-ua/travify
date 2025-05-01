import 'package:travify/enums/transaction_type.dart';
import 'package:travify/models/change.dart';
import 'package:travify/models/expense.dart';
import 'package:travify/models/income.dart';

abstract class Transaction {
  int id;
  final int tripId;
  DateTime date;
  String? description;
  double amount;

  TransactionType get type;

  Transaction({
    required this.id,
    required this.tripId,
    required this.date,
    this.description,
    required this.amount,
  });

  Map<String, dynamic> toTransactionMap() {
    return {
      'trip_id': tripId,
      'type': type.index,
      'date': date.millisecondsSinceEpoch,
      'description': description,
      'amount': amount,
    };
  }

  Map<String, dynamic> toMap();

  Transaction copy({
    int? id,
    DateTime? date,
    String? description,
    double? amount,
  });

  static Transaction fromMap(Map<String, dynamic> map) {
    final typeIndex = map['type'];
    final type = TransactionType.values[typeIndex];

    switch (type) {
      case TransactionType.expense:
        return Expense.fromMap(map);
      case TransactionType.income:
        return Income.fromMap(map);
      case TransactionType.change:
        return Change.fromMap(map);
    }
  }

  @override
  String toString();
}
