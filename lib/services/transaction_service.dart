import 'package:travify/enums/transaction_type.dart';
import 'package:travify/models/transaction.dart';
import 'package:travify/database/dao/transaction_dao.dart';

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
  Future<int> updateTransaction(Transaction transaction) async {
    throw UnimplementedError("updateTransaction aún no implementado en el DAO");
  }
}
