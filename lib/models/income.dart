import 'package:travify/enums/recurrent_income_type.dart';
import 'package:travify/models/transaction.dart';
import 'package:travify/models/trip.dart';

class Income extends Transaction {
  @override
  int get type => 1;

  bool isRecurrent;
  RecurrentIncomeType recurrentIncomeType;
  DateTime nextRecurrentDate;
  bool active;

  Income({
    required super.id,
    required super.date,
    super.description,
    required super.amount,
    required this.recurrentIncomeType,
    required this.isRecurrent,
    required this.nextRecurrentDate,
    required this.active,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'date': date.millisecondsSinceEpoch,
      'description': description,
      'amount': amount,
      'isRecurrent': isRecurrent ? 1 : 0,
      'recurrentIncomeType': recurrentIncomeType.index,
      'nextRecurrentDate': nextRecurrentDate.millisecondsSinceEpoch,
      'active': active ? 1 : 0
    };
  }

  @override
  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'],
      amount: map['amount'],
      recurrentIncomeType:
          RecurrentIncomeType.values[map['recurrentIncomeType']],
      isRecurrent: map['isRecurrent'] == 1,
      nextRecurrentDate:
          DateTime.fromMillisecondsSinceEpoch(map['nextRecurrentDate']),
      active: map['active'] == 1,
    );
  }

  @override
  Income copy({
    int? id,
    int? modeId,
    DateTime? date,
    String? description,
    double? amount,
    Trip? trip,
    RecurrentIncomeType? recurrentIncomeType,
    bool? isRecurrent,
    DateTime? nextRecurrentDate,
    bool? active,
  }) {
    return Income(
        id: id ?? this.id,
        date: date ?? this.date,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        recurrentIncomeType: recurrentIncomeType ?? this.recurrentIncomeType,
        isRecurrent: isRecurrent ?? this.isRecurrent,
        nextRecurrentDate: nextRecurrentDate ?? this.nextRecurrentDate,
        active: active ?? this.active);
  }

  @override
  String toString() {
    return 'Income{id: $id, date: $date, description: $description, amount: $amount, recurrentIncomeType: $recurrentIncomeType, isRecurrent: $isRecurrent, nextRecurrentDate: $nextRecurrentDate, active: $active}';
  }
}
