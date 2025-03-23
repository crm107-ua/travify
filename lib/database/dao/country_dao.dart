import 'package:sqflite/sqflite.dart';
import 'package:travify/database/dao/currency_dao.dart';
import 'package:travify/models/currency.dart';
import '../helpers/database_helper.dart';
import '../../models/country.dart';

class CountryDao {
  static final CountryDao _instance = CountryDao._internal();
  static final CurrencyDao _currencyDao = CurrencyDao();
  factory CountryDao() => _instance;
  CountryDao._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertCountry(Country country) async {
    Database db = await _databaseHelper.database;
    return await db.insert(
      'countries',
      country.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Country>> getCountryById(int id) async {
    Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      'countries',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.map((map) => Country.fromMap(map)).toList();
  }

  Future<List<Country>> getTripCountries(int tripId) async {
    Database db = await _databaseHelper.database;

    // 1️⃣ Obtener los IDs de los países desde la tabla `trip_country`
    List<Map<String, dynamic>> tripCountries = await db.query(
      'trip_country',
      where: 'trip_id = ?',
      whereArgs: [tripId],
    );

    if (tripCountries.isEmpty) {
      return [];
    }

    // 2️⃣ Extraer los IDs de los países
    List<int> countryIds =
        tripCountries.map((map) => map['country_id'] as int).toList();

    // 3️⃣ Obtener los países reales desde la tabla `countries`
    List<Map<String, dynamic>> countryMaps = await db.query(
      'countries',
      where: 'id IN (${countryIds.map((_) => '?').join(', ')})',
      whereArgs: countryIds,
    );

    // 4️⃣ Obtener las monedas para cada país
    List<Country> countries = [];
    for (var map in countryMaps) {
      int countryId = map['id'];
      List<Currency> currencies =
          await _currencyDao.getCountriesCurrencies([countryId]);

      // Crear el objeto `Country` con su lista de `Currency`
      Country country = Country.fromMap(map, currencies: currencies);
      country.currencies = currencies;

      countries.add(country);
    }

    return countries;
  }

  Future<List<Country>> getCountries() async {
    Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      'countries',
      orderBy: 'id DESC',
    );

    List<Country> countries = [];

    for (var map in maps) {
      int countryId = map['id'];
      List<Currency> currencies =
          await _currencyDao.getCountriesCurrencies([countryId]);

      countries.add(Country.fromMap(map, currencies: currencies));
    }

    return countries;
  }

  Future<int> updateCountry(Country country) async {
    Database db = await _databaseHelper.database;
    return await db.update(
      'countries',
      country.toMap(),
      where: 'id = ?',
      whereArgs: [country.id],
    );
  }

  Future<int> deleteCountry(int id) async {
    Database db = await _databaseHelper.database;
    return await db.delete(
      'countries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
