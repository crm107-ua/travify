import 'package:travify/enums/recurrent_income_type.dart';
import 'package:travify/enums/transaction_type.dart';
import 'package:travify/models/transaction.dart';
import 'package:travify/models/trip.dart';

class Income extends Transaction {
  @override
  TransactionType get type => TransactionType.income;

  bool? isRecurrent;
  RecurrentIncomeType? recurrentIncomeType;
  DateTime? nextRecurrentDate;
  bool? active;

  Income({
    required super.id,
    required super.tripId,
    required super.date,
    super.description,
    required super.amount,
    this.recurrentIncomeType,
    this.isRecurrent,
    this.nextRecurrentDate,
    this.active,
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
      'isRecurrent': isRecurrent != null && isRecurrent! ? 1 : 0,
      'recurrentIncomeType': recurrentIncomeType?.index,
      'nextRecurrentDate': nextRecurrentDate?.millisecondsSinceEpoch,
      'active': active != null && active! ? 1 : 0,
    };
  }

  @override
  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      tripId: map['trip_id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'],
      amount: map['amount'],
      recurrentIncomeType: map['recurrent_income_type'] != null
          ? RecurrentIncomeType.values[map['recurrent_income_type']]
          : null, // ✅ Permitir nulo

      isRecurrent: map['is_recurrent'] == 1,

      nextRecurrentDate: map['next_recurrent_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['next_recurrent_date'])
          : null, // ✅ Permitir nulo

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
        tripId: trip?.id ?? this.tripId,
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
    return 'Income{id: $id, tripId: $tripId, date: $date, description: $description, amount: $amount, recurrentIncomeType: $recurrentIncomeType, isRecurrent: $isRecurrent, nextRecurrentDate: $nextRecurrentDate, active: $active}';
  }
}
