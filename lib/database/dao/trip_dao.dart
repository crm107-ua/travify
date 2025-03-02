import 'package:sqflite/sqflite.dart' as sdb;
import 'package:travify/database/dao/budget_dao.dart';
import 'package:travify/database/dao/country_dao.dart';
import 'package:travify/database/dao/transaction_dao.dart';
import 'package:travify/models/budget.dart';
import 'package:travify/models/country.dart';
import 'package:travify/models/transaction.dart';
import '../helpers/database_helper.dart';
import '../../models/trip.dart';

class TripDao {
  // Singleton Pattern
  static final TripDao _instance = TripDao._internal();
  static final BudgetDao _budgetDao = BudgetDao();
  static final CountryDao _countryDao = CountryDao();
  static final TransactionDao _transactionDao = TransactionDao();
  factory TripDao() => _instance;
  TripDao._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// Inserta un nuevo viaje en la base de datos.
  Future<int> insertViaje(Trip viaje) async {
    sdb.Database db = await _databaseHelper.database;
    return await db.insert(
      'trips',
      viaje.toMap(),
      conflictAlgorithm: sdb.ConflictAlgorithm.replace,
    );
  }

  /// Recupera un viaje de la base de datos basado en su ID.
  Future<Trip?> getTripById(int id) async {
    sdb.Database db = await _databaseHelper.database;

    // 🔹 Obtener el Trip desde la tabla 'trips'
    List<Map<String, dynamic>> tripMaps = await db.query(
      'trips',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (tripMaps.isEmpty) return null;

    Map<String, dynamic> tripMap = tripMaps.first;

    // 🔹 Obtener el presupuesto asociado (Budget)
    int budgetId = tripMap['budget_id'];
    Budget? budget = await _budgetDao.getBudgetById(budgetId);

    // Obtener los países asociados
    List<Country> countryMaps = await _countryDao.getTripCountries(id);

    // Obtener las transacciones asociadas
    List<Transaction> transactions = await _transactionDao.getTransactions(id);

    Trip test = Trip.fromMap(tripMap,
        budget: budget, countries: countryMaps, transactions: transactions);
    // 🔹 Construir el objeto Trip con el Budget recuperado
    return Trip.fromMap(tripMap,
        budget: budget, countries: countryMaps, transactions: transactions);
  }

  /// Recupera todos los trips de la base de datos, ordenados por ID descendente.
  Future<List<Trip>> gettrips() async {
    sdb.Database db = await _databaseHelper.database;

    // 🔹 Obtener el Trip desde la tabla 'trips'
    List<Map<String, dynamic>> tripMaps = await db.query(
      'trips',
    );

    if (tripMaps.isEmpty) return [];

    List<Trip> trips = [];

    for (Map<String, dynamic> tripMap in tripMaps) {
      // Obtener los países asociados
      int budgetId = tripMap['budget_id'];
      Budget? budget = await _budgetDao.getBudgetById(budgetId);

      // Obtener los países asociados
      List<Country> countryMaps =
          await _countryDao.getTripCountries(tripMap['id']);

      // Obtener las transacciones asociadas
      List<Transaction> transactions =
          await _transactionDao.getTransactions(tripMap['id']);

      Trip test = Trip.fromMap(tripMap,
          budget: budget, countries: countryMaps, transactions: transactions);

      trips.add(Trip.fromMap(tripMap,
          budget: budget, countries: countryMaps, transactions: transactions));
    }

    print(trips);
    return trips;
  }

  /// Actualiza un viaje existente en la base de datos.
  Future<int> updateViaje(Trip viaje) async {
    sdb.Database db = await _databaseHelper.database;
    return await db.update(
      'trips',
      viaje.toMap(),
      where: 'id = ?',
      whereArgs: [viaje.id],
    );
  }

  /// Elimina un viaje de la base de datos basado en su ID.
  Future<int> deleteViaje(int id) async {
    sdb.Database db = await _databaseHelper.database;
    return await db.delete(
      'trips',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Cierra la conexión de la base de datos.
  Future<void> close() async {
    await _databaseHelper.close();
  }
}
