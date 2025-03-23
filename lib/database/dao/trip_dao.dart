import 'package:sqflite/sqflite.dart' as sdb;
import 'package:travify/database/dao/budget_dao.dart';
import 'package:travify/database/dao/country_dao.dart';
import 'package:travify/database/dao/transaction_dao.dart';
import 'package:travify/database/dao/currency_dao.dart';
import 'package:travify/models/budget.dart';
import 'package:travify/models/country.dart';
import 'package:travify/models/currency.dart';
import 'package:travify/models/transaction.dart';
import '../helpers/database_helper.dart';
import '../../models/trip.dart';

class TripDao {
  // Singleton Pattern
  static final TripDao _instance = TripDao._internal();
  static final BudgetDao _budgetDao = BudgetDao();
  static final CountryDao _countryDao = CountryDao();
  static final CurrencyDao _currencyDao = CurrencyDao();
  static final TransactionDao _transactionDao = TransactionDao();
  factory TripDao() => _instance;
  TripDao._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// Inserta un nuevo viaje en la base de datos.
  Future<int> insertViaje(Trip viaje) async {
    sdb.Database db = await _databaseHelper.database;

    int budgetId = await _budgetDao.insertBudget(viaje.budget);

    int tripId = await db.insert(
      'trips',
      {
        'title': viaje.title,
        'description': viaje.description,
        'date_start': viaje.dateStart.millisecondsSinceEpoch,
        'date_end': viaje.dateEnd?.millisecondsSinceEpoch,
        'destination': viaje.destination,
        'image': viaje.image,
        'open': viaje.open ? 1 : 0,
        'budget_id': budgetId,
        'currency_id': viaje.currency.id,
      },
      conflictAlgorithm: sdb.ConflictAlgorithm.replace,
    );

    for (var country in viaje.countries) {
      await db.insert(
        'trip_country',
        {
          'trip_id': tripId,
          'country_id': country.id,
        },
        conflictAlgorithm: sdb.ConflictAlgorithm.replace,
      );
    }

    return tripId;
  }

  // Funcion para obtener el viaje actual o el siguiente viaje
  Future<Trip?> getCurrentTripOrNextTrip() async {
    Trip? actualTrip = await getActualTrip();
    if (actualTrip != null) return actualTrip;

    return await getNextTrip();
  }

  // Comprobar que no exista un viaje entre esas fechas
  Future<bool> checkTripExist(DateTime dateStart, DateTime dateEnd) async {
    sdb.Database db = await _databaseHelper.database;

    List<Map<String, dynamic>> tripMaps = await db.query(
      'trips',
      where: 'date_start <= ? AND date_end >= ?',
      whereArgs: [
        dateEnd.millisecondsSinceEpoch,
        dateStart.millisecondsSinceEpoch
      ],
    );

    return tripMaps.isNotEmpty;
  }

  // Comprobar que no se puede agregar un viaje con una fecha de inicio anterior a alguna ya existente y sin fecha de fin
  Future<bool> checkTripExistWithDate(DateTime dateStart) async {
    sdb.Database db = await _databaseHelper.database;

    List<Map<String, dynamic>> tripMaps = await db.query(
      'trips',
      where: 'date_start >= ?',
      whereArgs: [dateStart.millisecondsSinceEpoch],
    );

    return tripMaps.isNotEmpty;
  }

  // Funcion para obtener el proximo viaje
  Future<Trip?> getNextTrip() async {
    sdb.Database db = await _databaseHelper.database;

    int currentTime = DateTime.now().millisecondsSinceEpoch;

    List<Map<String, dynamic>> tripMaps = await db.query(
      'trips',
      where: 'date_start > ?',
      whereArgs: [currentTime],
      orderBy: 'date_start ASC',
      limit: 1,
    );

    if (tripMaps.isEmpty) return null;

    Map<String, dynamic> tripMap = tripMaps.first;

    // 🔹 Obtener el presupuesto asociado (Budget)
    int budgetId = tripMap['budget_id'];
    Budget? budget = await _budgetDao.getBudgetById(budgetId);
    Currency currency =
        await _currencyDao.getCurrencyById(tripMap['currency_id']);

    // Obtener los países asociados
    List<Country> countryMaps =
        await _countryDao.getTripCountries(tripMap['id']);

    // Obtener las transacciones asociadas
    List<Transaction> transactions =
        await _transactionDao.getTransactions(tripMap['id']);

    Trip test = Trip.fromMap(tripMap,
        budget: budget,
        currency: currency,
        countries: countryMaps,
        transactions: transactions);
    // 🔹 Construir el objeto Trip con el Budget recuperado
    return Trip.fromMap(tripMap,
        budget: budget,
        currency: currency,
        countries: countryMaps,
        transactions: transactions);
  }

  // Funcion para obtener el viaje que se esta realizando ahora
  Future<Trip?> getActualTrip() async {
    sdb.Database db = await _databaseHelper.database;

    int currentTime = DateTime.now().millisecondsSinceEpoch;

    List<Map<String, dynamic>> tripMaps = await db.query(
      'trips',
      where: 'date_start <= ? AND date_end >= ?',
      whereArgs: [currentTime, currentTime],
    );

    if (tripMaps.isEmpty) return null;

    Map<String, dynamic> tripMap = tripMaps.first;

    // 🔹 Obtener el presupuesto asociado (Budget)
    int budgetId = tripMap['budget_id'];
    Budget? budget = await _budgetDao.getBudgetById(budgetId);
    Currency currency =
        await _currencyDao.getCurrencyById(tripMap['currency_id']);

    // Obtener los países asociados
    List<Country> countryMaps =
        await _countryDao.getTripCountries(tripMap['id']);

    // Obtener las transacciones asociadas
    List<Transaction> transactions =
        await _transactionDao.getTransactions(tripMap['id']);

    Trip test = Trip.fromMap(tripMap,
        budget: budget,
        currency: currency,
        countries: countryMaps,
        transactions: transactions);
    // 🔹 Construir el objeto Trip con el Budget recuperado
    return Trip.fromMap(tripMap,
        budget: budget,
        currency: currency,
        countries: countryMaps,
        transactions: transactions);
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
      // Obtener el presupuesto asociado
      int budgetId = tripMap['budget_id'];
      Budget? budget = await _budgetDao.getBudgetById(budgetId);
      Currency currency =
          await _currencyDao.getCurrencyById(tripMap['currency_id']);

      // Obtener los países asociados
      List<Country> countryMaps =
          await _countryDao.getTripCountries(tripMap['id']);

      // Obtener las transacciones asociadas
      List<Transaction> transactions =
          await _transactionDao.getTransactions(tripMap['id']);

      trips.add(Trip.fromMap(tripMap,
          budget: budget,
          currency: currency,
          countries: countryMaps,
          transactions: transactions));
    }

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

  /// Obtiene los 6 viajes más próximos ordenados por fecha de inicio.
  Future<List<Trip>> getUpcomingTrips() async {
    sdb.Database db = await _databaseHelper.database;

    int currentTime = DateTime.now().millisecondsSinceEpoch;

    // Consulta para obtener los 6 viajes más próximos
    List<Map<String, dynamic>> tripMaps = await db.query('trips',
        where: 'date_start >= ?',
        whereArgs: [currentTime],
        orderBy: 'date_start ASC');

    if (tripMaps.isEmpty) return [];

    List<Trip> trips = [];

    for (Map<String, dynamic> tripMap in tripMaps) {
      int budgetId = tripMap['budget_id'];
      Budget? budget = await _budgetDao.getBudgetById(budgetId);

      Currency currency =
          await _currencyDao.getCurrencyById(tripMap['currency_id']);

      List<Country> countryMaps =
          await _countryDao.getTripCountries(tripMap['id']);
      List<Transaction> transactions =
          await _transactionDao.getTransactions(tripMap['id']);

      trips.add(Trip.fromMap(tripMap,
          budget: budget,
          currency: currency,
          countries: countryMaps,
          transactions: transactions));
    }

    return trips;
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
