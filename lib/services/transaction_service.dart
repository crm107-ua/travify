import 'package:travify/enums/transaction_type.dart';
import 'package:travify/models/expense.dart';
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

  /// Elimina una transacción por su ID.
  Future<int> deleteTransaction(int id) async {
    throw UnimplementedError("deleteTransaction aún no implementado en el DAO");
  }

  /// Actualiza una transacción existente.
  Future<void> updateTransaction(Expense transaction) async {
    await _transactionDao.updateExpenseNextAmortizationDate(transaction);
  }

  /// Obtiene todos los gastos amortizables con `nextAmortizationDate` igual a hoy
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

  Future<void> generarAmortizacionesDeHoy(Trip trip) async {
    final transactionDao = TransactionDao();
    final gastosDeHoy = await getAmortizationsForToday(trip);

    for (final expense in gastosDeHoy) {
      final nuevaAmortizacion = Expense(
        id: 0,
        tripId: expense.tripId,
        date: DateTime.now(),
        description: '${expense.description} (Amort.)',
        amount: expense.amortization ?? 0.0,
        category: expense.category,
        isAmortization: false,
      );

      await transactionDao.createTransaction(nuevaAmortizacion);

      final siguiente =
          expense.nextAmortizationDate!.add(const Duration(days: 1));
      if (expense.endDateAmortization != null &&
          siguiente.isAfter(expense.endDateAmortization!)) {
        expense.nextAmortizationDate = null;
      } else {
        expense.nextAmortizationDate = siguiente;
      }

      await _transactionDao.updateExpenseNextAmortizationDate(expense);
    }
  }
}
