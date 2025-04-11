import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite.dart' as sdb;
import 'package:travify/database/helpers/database_helper.dart';
import 'package:travify/models/rate.dart';

class RateDao {
  static final RateDao _instance = RateDao._internal();
  factory RateDao() => _instance;
  RateDao._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();

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
