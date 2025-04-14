import 'package:sqflite/sqflite.dart' as sdb;
import 'package:travify/database/dao/budget_dao.dart';
import 'package:travify/database/dao/country_dao.dart';
import 'package:travify/database/dao/currency_dao.dart';
import 'package:travify/database/helpers/database_helper.dart';
import 'package:travify/enums/transaction_type.dart';
import 'package:travify/models/change.dart';
import 'package:travify/models/currency.dart';
import 'package:travify/models/expense.dart';
import 'package:travify/models/income.dart';
import 'package:travify/models/transaction.dart';

class TransactionDao {
  static final TransactionDao _instance = TransactionDao._internal();
  factory TransactionDao() => _instance;
  TransactionDao._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final CurrencyDao _currencyDao = CurrencyDao();

  Future<List<Transaction>> getTransactions(int tripId) async {
    sdb.Database db = await _databaseHelper.database;

    // Obtener todas las transacciones de la tabla `transactions`
    List<Map<String, dynamic>> transactionMaps = await db.query(
      'transactions',
      where: 'trip_id = ?',
      orderBy: 'date DESC',
      whereArgs: [tripId],
    );

    List<Transaction> transactions = [];

    for (var map in transactionMaps) {
      transactions.add(await _buildTransactionFromMap(map));
    }

    return transactions;
  }

  /// Convierte un mapa en un objeto `Transaction`, resolviendo claves foráneas
  Future<Transaction> _buildTransactionFromMap(Map<String, dynamic> map) async {
    final type = TransactionType.values[map['type']];

    switch (type) {
      case TransactionType.expense:
        return await _getExpense(map) as Transaction;
      case TransactionType.income:
        return await _getIncome(map) as Transaction;
      case TransactionType.change:
        return await _getChange(map) as Transaction;
    }
  }

  /// Obtiene un `Expense` con todos sus datos
  Future<Expense> _getExpense(Map<String, dynamic> transactionMap) async {
    sdb.Database db = await _databaseHelper.database;

    // Buscar datos en la tabla `expenses`
    List<Map<String, dynamic>> expenseMap = await db.query(
      'expenses',
      where: 'transaction_id = ?',
      whereArgs: [transactionMap['id']],
    );

    if (expenseMap.isEmpty) {
      throw Exception(
          "Expense no encontrado para Transaction ID ${transactionMap['id']}");
    }

    return Expense.fromMap({...transactionMap, ...expenseMap.first});
  }

  /// Obtiene un `Income` con todos sus datos
  Future<Income> _getIncome(Map<String, dynamic> transactionMap) async {
    sdb.Database db = await _databaseHelper.database;

    // Buscar datos en la tabla `incomes`
    List<Map<String, dynamic>> incomeMap = await db.query(
      'incomes',
      where: 'transaction_id = ?',
      whereArgs: [transactionMap['id']],
    );

    if (incomeMap.isEmpty) {
      throw Exception(
          "Income no encontrado para Transaction ID ${transactionMap['id']}");
    }

    return Income.fromMap({...transactionMap, ...incomeMap.first});
  }

  Future<Change> _getChange(Map<String, dynamic> transactionMap) async {
    sdb.Database db = await _databaseHelper.database;

    List<Map<String, dynamic>> changeMap = await db.query(
      'changes',
      where: 'transaction_id = ?',
      whereArgs: [transactionMap['id']],
    );

    if (changeMap.isEmpty) {
      throw Exception(
          "Change no encontrado para Transaction ID ${transactionMap['id']}");
    }

    // Obtener monedas
    Currency currencyRecived = await _currencyDao
        .getCurrencyById(changeMap.first['currency_recived_id']);
    Currency currencySpent = await _currencyDao
        .getCurrencyById(changeMap.first['currency_spent_id']);

    return Change.fromMap({
      ...transactionMap,
      ...changeMap.first,
      'currencyRecived': currencyRecived.toMap(),
      'currencySpent': currencySpent.toMap(),
    });
  }

  /// Inserta una transacción
  Future<int> createTransaction(Transaction transaction) async {
    final db = await _databaseHelper.database;

    // Solo inserta los campos válidos para `transactions`
    final transactionMap = transaction.toTransactionMap();
    int transactionId = await db.insert('transactions', transactionMap);

    // Luego inserta los datos específicos
    switch (transaction.type) {
      case TransactionType.expense:
        final expense = transaction as Expense;
        await db.insert('expenses', {
          'transaction_id': transactionId,
          'category': expense.category.index,
          'isAmortization': expense.isAmortization ? 1 : 0,
          'amortization': expense.amortization ?? 0,
          'start_date_amortization':
              expense.startDateAmortization?.millisecondsSinceEpoch,
          'end_date_amortization':
              expense.endDateAmortization?.millisecondsSinceEpoch,
          'next_amortization_date':
              expense.nextAmortizationDate?.millisecondsSinceEpoch,
        });
        break;

      case TransactionType.income:
        final income = transaction as Income;
        await db.insert('incomes', {
          'transaction_id': transactionId,
          'is_recurrent': income.isRecurrent == true ? 1 : 0,
          'recurrent_income_type': income.recurrentIncomeType?.index,
          'next_recurrent_date':
              income.nextRecurrentDate?.millisecondsSinceEpoch,
          'active': income.active == true ? 1 : 0,
        });
        break;

      case TransactionType.change:
        final change = transaction as Change;
        await db.insert('changes', {
          'transaction_id': transactionId,
          'currency_recived_id': change.currencyRecived.id,
          'currency_spent_id': change.currencySpent.id,
          'commission': change.commission,
          'amount_recived': change.amountRecived,
        });
        break;
    }

    return transactionId;
  }

  // Devlver todos los changes de todos los viajes
  Future<List<Change>> getAllChanges() async {
    final db = await _databaseHelper.database;

    // Join entre transactions y changes para obtener todos los campos en una sola consulta
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT t.*, c.currency_recived_id, c.currency_spent_id, c.commission, c.amount_recived
    FROM transactions t
    JOIN changes c ON t.id = c.transaction_id
    ORDER BY t.date DESC
  ''');

    final List<Change> changes = [];

    for (final map in maps) {
      final currencyRecived =
          await _currencyDao.getCurrencyById(map['currency_recived_id']);
      final currencySpent =
          await _currencyDao.getCurrencyById(map['currency_spent_id']);

      final change = Change(
        id: map['id'],
        tripId: map['trip_id'],
        date: DateTime.fromMillisecondsSinceEpoch(map['date']),
        description: map['description'],
        amount: (map['amount'] as num).toDouble(),
        currencyRecived: currencyRecived,
        currencySpent: currencySpent,
        commission: (map['commission'] as num).toDouble(),
        amountRecived: (map['amount_recived'] as num).toDouble(),
      );

      changes.add(change);
    }

    return changes;
  }
}
