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
  final BudgetDao _budgetDao = BudgetDao();
  final CountryDao _countryDao = CountryDao();
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

  /// Obtiene un `Change` con todos sus datos y resuelve claves foráneas de `currencies`
  Future<Change> _getChange(Map<String, dynamic> transactionMap) async {
    sdb.Database db = await _databaseHelper.database;

    // Buscar datos en la tabla `chenges`
    List<Map<String, dynamic>> changeMap = await db.query(
      'chenges',
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
}
