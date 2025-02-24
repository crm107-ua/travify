import 'package:travify/enums/expense_category.dart';
import 'package:travify/models/transaction.dart';
import 'package:travify/models/trip.dart';

class Expense extends Transaction {
  @override
  int get type => 0;

  ExpenseCategory category;
  bool isAmortization;
  double amortization;
  DateTime startDateAmortization;
  DateTime endDateAmortization;
  DateTime lastAmortizationDate;

  Expense(
      {required super.id,
      required super.date,
      super.description,
      required super.amount,
      required this.category,
      required this.isAmortization,
      required this.amortization,
      required this.startDateAmortization,
      required this.endDateAmortization,
      required this.lastAmortizationDate,
      required});

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'date': date.millisecondsSinceEpoch,
      'description': description,
      'amount': amount,
      'category': category.index,
      'isAmortization': isAmortization ? 1 : 0,
      'amortization': amortization,
      'startDateAmortization': startDateAmortization.millisecondsSinceEpoch,
      'endDateAmortization': endDateAmortization.millisecondsSinceEpoch,
      'lastAmortizationDate': lastAmortizationDate.millisecondsSinceEpoch,
    };
  }

  @override
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'],
      amount: map['amount'],
      category: ExpenseCategory.values[map['category']],
      isAmortization: map['isAmortization'] == 1,
      amortization: map['amortization'],
      startDateAmortization:
          DateTime.fromMillisecondsSinceEpoch(map['startDateAmortization']),
      endDateAmortization:
          DateTime.fromMillisecondsSinceEpoch(map['endDateAmortization']),
      lastAmortizationDate:
          DateTime.fromMillisecondsSinceEpoch(map['lastAmortizationDate']),
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
    DateTime? lastAmortizationDate,
  }) {
    return Expense(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      isAmortization: isAmortization,
      amortization: amortization ?? this.amortization,
      startDateAmortization:
          startDateAmortization ?? this.startDateAmortization,
      endDateAmortization: endDateAmortization ?? this.endDateAmortization,
      lastAmortizationDate: lastAmortizationDate ?? this.lastAmortizationDate,
    );
  }

  @override
  String toString() {
    return 'Expense{id: $id,  date: $date, description: $description, amount: $amount, category: $category, amortization: $amortization, startDateAmortization: $startDateAmortization, endDateAmortization: $endDateAmortization, lastAmortizationDate: $lastAmortizationDate}';
  }
}
