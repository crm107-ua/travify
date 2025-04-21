import 'package:intl/intl.dart';
import 'package:travify/enums/recurrent_income_type.dart';
import 'package:travify/enums/transaction_type.dart';
import 'package:travify/models/expense.dart';
import 'package:travify/models/income.dart';
import 'package:travify/models/transaction.dart';
import 'package:travify/database/dao/transaction_dao.dart';
import 'package:travify/models/trip.dart';

class TransactionService {
  final TransactionDao _transactionDao = TransactionDao();

  /// Crea una transacción (puede ser Expense, Income o Change).
  Future<int> createTransaction(Transaction transaction) async {
    return await _transactionDao.createTransaction(transaction);
  }

  /// Obtiene todas las transacciones de un viaje por su ID.
  Future<List<Transaction>> getTransactionsByTripId(int tripId) async {
    return await _transactionDao.getTransactions(tripId);
  }

  /// Puedes añadir aquí lógica adicional si deseas filtrar por tipo, fecha, etc.
  Future<List<Transaction>> getIncomesFromTrip(int tripId) async {
    final all = await _transactionDao.getTransactions(tripId);
    return all.where((t) => t.type == TransactionType.income).toList();
  }

  Future<List<Expense>> getAmortizationsForToday(Trip trip) async {
    final dao = TransactionDao();
    final List transactions = await dao.getTransactions(trip.id);

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return transactions.whereType<Expense>().where((expense) {
      if (expense.isAmortization != true ||
          expense.nextAmortizationDate == null) {
        return false;
      }

      final nextDate = DateTime(
        expense.nextAmortizationDate!.year,
        expense.nextAmortizationDate!.month,
        expense.nextAmortizationDate!.day,
      );

      return nextDate == todayDate;
    }).toList();
  }

  Future<void> generateAmortizations(Trip trip) async {
    final List transactions = await _transactionDao.getTransactions(trip.id);

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final expenses = transactions.whereType<Expense>().where((expense) {
      return expense.isAmortization == true &&
          expense.nextAmortizationDate != null;
    }).toList();

    for (final expense in expenses) {
      DateTime nextDate = DateTime(
        expense.nextAmortizationDate!.year,
        expense.nextAmortizationDate!.month,
        expense.nextAmortizationDate!.day,
      );

      while (!nextDate.isAfter(todayDate)) {
        final nuevaAmortizacion = Expense(
          id: 0,
          tripId: expense.tripId,
          date: nextDate,
          description:
              '${expense.description} Recurr. Próxima fecha: (${DateFormat('dd/MM').format(nextDate)})',
          amount: expense.amortization ?? 0.0,
          category: expense.category,
          isAmortization: false,
        );

        await _transactionDao.createTransaction(nuevaAmortizacion);

        final siguiente = nextDate.add(const Duration(days: 1));
        if (expense.endDateAmortization != null &&
            siguiente.isAfter(expense.endDateAmortization!)) {
          expense.nextAmortizationDate = null;
          break;
        } else {
          nextDate = siguiente;
          expense.nextAmortizationDate = siguiente;
        }
      }

      await _transactionDao.updateExpenseNextAmortizationDate(expense);
    }
  }

  Future<void> generateRecurrentIncomes(Trip trip) async {
    final allTransactions = await _transactionDao.getTransactions(trip.id);

    final recurrentIncomes = allTransactions
        .whereType<Income>()
        .where((income) =>
            income.isRecurrent == true &&
            income.active == true &&
            income.nextRecurrentDate != null)
        .toList();

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    for (final income in recurrentIncomes) {
      DateTime? next = income.nextRecurrentDate;
      DateTime nextDate = DateTime(next!.year, next.month, next.day);

      // Desactiva el income original
      income.active = false;
      await _transactionDao.updateIncomeNextRecurrentDate(income);

      while (!nextDate.isAfter(todayDate)) {
        final newIncome = Income(
          id: 0,
          tripId: income.tripId,
          description:
              "${income.description} (Recur. ${DateFormat('dd/MM').format(nextDate)})",
          amount: income.amount,
          date: nextDate,
          isRecurrent: true,
          recurrentIncomeType: income.recurrentIncomeType,
          active: true,
          nextRecurrentDate: null,
        );

        await _transactionDao.createTransaction(newIncome);

        // Calcular la siguiente fecha
        switch (income.recurrentIncomeType) {
          case RecurrentIncomeType.daily:
            nextDate = nextDate.add(const Duration(days: 1));
            break;
          case RecurrentIncomeType.weekly:
            nextDate = nextDate.add(const Duration(days: 7));
            break;
          case RecurrentIncomeType.monthly:
            nextDate =
                DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
            break;
          case RecurrentIncomeType.yearly:
            nextDate =
                DateTime(nextDate.year + 1, nextDate.month, nextDate.day);
            break;
          default:
            nextDate = todayDate.add(const Duration(days: 1));
        }
      }

      // No se guarda en base de datos, solo si va a usarse otra vez.
      if (nextDate.isAfter(todayDate)) {
        income.nextRecurrentDate = nextDate;
        income.active = true;
        await _transactionDao.updateIncomeNextRecurrentDate(income);
      }
    }
  }

  Future<void> updateIncomeActive(Income income) async {
    await _transactionDao.updateIncomeActive(income);
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    await _transactionDao.deleteTransaction(transaction);
  }
}
