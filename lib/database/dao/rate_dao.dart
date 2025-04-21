import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite.dart' as sdb;
import 'package:travify/database/dao/currency_dao.dart';
import 'package:travify/database/helpers/database_helper.dart';
import 'package:travify/models/currency.dart';
import 'package:travify/models/rate.dart';

class RateDao {
  static final RateDao _instance = RateDao._internal();
  factory RateDao() => _instance;
  RateDao._internal();

  CurrencyDao currencyDao = CurrencyDao();

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Rate>> getRatesFromCurrency(String currencyCode) async {
    final db = await _databaseHelper.database;

    final currency = await currencyDao.getCurrencyByCode(currencyCode);

    final List<Map<String, dynamic>> maps = await db.query(
      'official_rates',
      where: 'currency_spent_id = ?',
      whereArgs: [currency.id],
    );

    final List<Rate> rates = [];
    for (final map in maps) {
      final from = await currencyDao.getCurrencyById(map['currency_spent_id']);
      final to = await currencyDao.getCurrencyById(map['currency_recived_id']);
      rates.add(Rate(
        id: map['id'],
        currencyFrom: from,
        currencyTo: to,
        rate: map['rate'],
      ));
    }

    return rates;
  }

  Future<List<Rate>> getAllRates() async {
    sdb.Database db = await _databaseHelper.database;

    List<Map<String, dynamic>> maps = await db.query(
      'official_rates',
      orderBy: 'id DESC',
    );
    List<Rate> rates = [];
    for (var map in maps) {
      Currency currencyFrom =
          await currencyDao.getCurrencyById(map['currency_spent_id']);
      Currency currencyTo =
          await currencyDao.getCurrencyById(map['currency_recived_id']);

      Rate rate = Rate(
        id: map['id'],
        currencyFrom: currencyFrom,
        currencyTo: currencyTo,
        rate: map['rate'],
      );
      rates.add(rate);
    }
    return rates;
  }

  Future<void> upsertRate(Rate rate) async {
    sdb.Database db = await _databaseHelper.database;

    await db.insert(
      'official_rates',
      {
        'currency_spent_id': rate.currencyFrom.id,
        'currency_recived_id': rate.currencyTo.id,
        'rate': rate.rate,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertMultipleRates(List<Rate> rates) async {
    sdb.Database db = await _databaseHelper.database;

    for (var rate in rates) {
      db.insert(
        'official_rates',
        {
          'currency_spent_id': rate.currencyFrom.id,
          'currency_recived_id': rate.currencyTo.id,
          'rate': rate.rate,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
