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

      int dayNumber = 1;

      while (!nextDate.isAfter(todayDate)) {
        final description =
            '${expense.description ?? 'Amortización'} (Día $dayNumber)';

        final nuevaAmortizacion = Expense(
          id: 0,
          tripId: expense.tripId,
          date: nextDate,
          description: description,
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
          expense.nextAmortizationDate = siguiente;
          nextDate = siguiente;
          dayNumber++;
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

    for (final originalIncome in recurrentIncomes) {
      DateTime nextDate = DateTime(
        originalIncome.nextRecurrentDate!.year,
        originalIncome.nextRecurrentDate!.month,
        originalIncome.nextRecurrentDate!.day,
      );

      final List<Income> generated = [];

      while (!nextDate.isAfter(todayDate)) {
        final newIncome = Income(
          id: 0,
          tripId: originalIncome.tripId,
          description: originalIncome.description,
          amount: originalIncome.amount,
          date: nextDate,
          isRecurrent: true,
          recurrentIncomeType: originalIncome.recurrentIncomeType,
          active: false, // por defecto inactivo
          nextRecurrentDate: null,
        );

        int id = await _transactionDao.createTransaction(newIncome);
        newIncome.id = id;
        generated.add(newIncome);

        // Calcular siguiente fecha
        switch (originalIncome.recurrentIncomeType) {
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

      // Desactivar el original
      originalIncome.active = false;
      originalIncome.nextRecurrentDate = null;
      await _transactionDao.updateIncomeActive(originalIncome);
      await _transactionDao.updateIncomeNextRecurrentDate(originalIncome);

      if (generated.isNotEmpty) {
        for (int i = 0; i < generated.length; i++) {
          final inc = generated[i];
          if (i == generated.length - 1) {
            inc.active = true;
            inc.nextRecurrentDate = nextDate;
          } else {
            inc.active = false;
            inc.nextRecurrentDate = null;
          }
          await _transactionDao.updateIncomeActive(inc);
          await _transactionDao.updateIncomeNextRecurrentDate(inc);
        }
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
