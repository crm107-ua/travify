import 'package:travify/enums/expense_category.dart';
import 'package:travify/enums/transaction_type.dart';
import 'package:travify/models/transaction.dart';
import 'package:travify/models/trip.dart';

class Expense extends Transaction {
  @override
  TransactionType get type => TransactionType.expense;

  ExpenseCategory category;
  bool isAmortization;
  double? amortization;
  DateTime? startDateAmortization;
  DateTime? endDateAmortization;
  DateTime? nextAmortizationDate;

  Expense({
    required super.id,
    required super.tripId,
    required super.date,
    super.description,
    required super.amount,
    required this.category,
    required this.isAmortization,
    this.amortization,
    this.startDateAmortization,
    this.endDateAmortization,
    this.nextAmortizationDate,
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
      'category': category.index,
      'isAmortization': isAmortization ? 1 : 0,
      'amortization': amortization ?? 0,
      'startDateAmortization':
          startDateAmortization?.millisecondsSinceEpoch ?? 0,
      'endDateAmortization': endDateAmortization?.millisecondsSinceEpoch ?? 0,
      'nextAmortizationDate': nextAmortizationDate?.millisecondsSinceEpoch ?? 0,
    };
  }

  @override
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      tripId: map['trip_id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'],
      amount: map['amount'],
      category: ExpenseCategory.values[map['category']],
      isAmortization: map['isAmortization'] == 1,
      amortization: map['amortization'],
      startDateAmortization: (map['start_date_amortization'] != null)
          ? DateTime.fromMillisecondsSinceEpoch(map['start_date_amortization'])
          : null,
      endDateAmortization: (map['end_date_amortization'] != null)
          ? DateTime.fromMillisecondsSinceEpoch(map['end_date_amortization'])
          : null,
      nextAmortizationDate: (map['next_amortization_date'] != null)
          ? DateTime.fromMillisecondsSinceEpoch(map['next_amortization_date'])
          : null,
    );
  }

  @override
  Expense copy({
    int? id,
    int? tripId,
    int? modeId,
    DateTime? date,
    String? description,
    double? amount,
    Trip? trip,
    ExpenseCategory? category,
    double? amortization,
    DateTime? startDateAmortization,
    DateTime? endDateAmortization,
    DateTime? nextAmortizationDate,
  }) {
    return Expense(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      isAmortization: isAmortization,
      amortization: amortization ?? this.amortization,
      startDateAmortization:
          startDateAmortization ?? this.startDateAmortization,
      endDateAmortization: endDateAmortization ?? this.endDateAmortization,
      nextAmortizationDate: nextAmortizationDate ?? this.nextAmortizationDate,
    );
  }

  @override
  String toString() {
    return 'Expense{id: $id, tripId: $tripId, date: $date, description: $description, amount: $amount, category: $category, isAmortization: $isAmortization, amortization: $amortization, startDateAmortization: $startDateAmortization, endDateAmortization: $endDateAmortization, nextAmortizationDate: $nextAmortizationDate}';
  }
}
