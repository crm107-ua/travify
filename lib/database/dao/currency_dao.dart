import 'package:sqflite/sqflite.dart';
import '../helpers/database_helper.dart';
import '../../models/currency.dart';

class CurrencyDao {
  static final CurrencyDao _instance = CurrencyDao._internal();
  factory CurrencyDao() => _instance;
  CurrencyDao._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertCurrency(Currency currency) async {
    Database db = await _databaseHelper.database;
    return await db.insert(
      'currencies',
      currency.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Currency>> getAllCurrencies() async {
    Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      'currencies',
      orderBy: 'id DESC',
    );
    return maps.map((map) => Currency.fromMap(map)).toList();
  }

  Future<List<Currency>> getCountriesCurrencies(List<int> countryIds) async {
    Database db = await _databaseHelper.database;

    if (countryIds.isEmpty) return [];

    List<Map<String, dynamic>> countryCurrencies = await db.query(
      'country_currencies',
      where: 'country_id IN (${countryIds.map((_) => '?').join(', ')})',
      whereArgs: countryIds,
    );

    if (countryCurrencies.isEmpty) return [];

    List<int> currencyIds = countryCurrencies
        .map((map) => map['currency_id'] as int)
        .toSet()
        .toList();

    List<Map<String, dynamic>> currencyMaps = await db.query(
      'currencies',
      where: 'id IN (${currencyIds.map((_) => '?').join(', ')})',
      whereArgs: currencyIds,
    );

    return currencyMaps.map((map) => Currency.fromMap(map)).toList();
  }

  Future<Currency> getCurrencyById(int id) async {
    Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> currencyMaps = await db.query(
      'currencies',
      where: 'id = ?',
      whereArgs: [id],
    );
    return Currency.fromMap(currencyMaps.first);
  }

  Future<List<Currency>> getCurrencies() async {
    Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      'currencies',
      orderBy: 'id DESC',
    );
    return maps.map((map) => Currency.fromMap(map)).toList();
  }

  Future<int> updateCurrency(Currency currency) async {
    Database db = await _databaseHelper.database;
    return await db.update(
      'currencies',
      currency.toMap(),
      where: 'id = ?',
      whereArgs: [currency.id],
    );
  }

  Future<int> deleteCurrency(int id) async {
    Database db = await _databaseHelper.database;
    return await db.delete(
      'currencies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    await _databaseHelper.close();
  }
}
