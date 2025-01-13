import 'package:travify/enums/expense_category.dart';
import 'package:travify/enums/transaction_type.dart';
import 'package:travify/models/transaction.dart';
import 'package:travify/models/trip.dart';

class Expense extends Transaction {
  ExpenseCategory category;
  double amortization;
  DateTime startDateAmortization;
  DateTime endDateAmortization;

  Expense({
    required super.id,
    required super.type,
    required super.date,
    super.description,
    required super.amount,
    required super.trip,
    required this.category,
    required this.amortization,
    required this.startDateAmortization,
    required this.endDateAmortization,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'category': category.index,
      'amortization': amortization,
      'startDateAmortization': startDateAmortization.millisecondsSinceEpoch,
      'endDateAmortization': endDateAmortization.millisecondsSinceEpoch,
    };
  }

  @override
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      type: TransactionType.values[map['type']],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'],
      amount: map['amount'],
      trip: Trip.fromMap(map['trip']),
      category: ExpenseCategory.values[map['category']],
      amortization: map['amortization'],
      startDateAmortization:
          DateTime.fromMillisecondsSinceEpoch(map['startDateAmortization']),
      endDateAmortization:
          DateTime.fromMillisecondsSinceEpoch(map['endDateAmortization']),
    );
  }

  @override
  Expense copy({
    int? id,
    int? modeId,
    DateTime? date,
    String? description,
    double? amount,
    Trip? trip,
    ExpenseCategory? category,
    double? amortization,
    DateTime? startDateAmortization,
    DateTime? endDateAmortization,
  }) {
    return Expense(
      id: id ?? this.id,
      type: modeId != null ? TransactionType.values[modeId] : type,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      trip: trip ?? this.trip,
      category: category ?? this.category,
      amortization: amortization ?? this.amortization,
      startDateAmortization:
          startDateAmortization ?? this.startDateAmortization,
      endDateAmortization: endDateAmortization ?? this.endDateAmortization,
    );
  }

  @override
  String toString() {
    return 'Expense{id: $id, type: $type, date: $date, description: $description, amount: $amount, trip: $trip, category: $category, amortization: $amortization, startDateAmortization: $startDateAmortization, endDateAmortization: $endDateAmortization}';
  }
}
