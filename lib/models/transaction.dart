import 'package:travify/models/change.dart';
import 'package:travify/models/expense.dart';
import 'package:travify/models/income.dart';

abstract class Transaction {
  final int id;
  DateTime date;
  String? description;
  double amount;

  int get type;

  Transaction({
    required this.id,
    required this.date,
    this.description,
    required this.amount,
  });

  Map<String, dynamic> toMap();

  Transaction copy({
    int? id,
    DateTime? date,
    String? description,
    double? amount,
  });

  static Transaction fromMap(Map<String, dynamic> map) {
    switch (map['type']) {
      case 0:
        return Expense.fromMap(map);
      case 1:
        return Income.fromMap(map);
      case 2:
        return Change.fromMap(map);
      default:
        throw Exception('Invalid transaction type');
    }
  }

  @override
  String toString();
}
