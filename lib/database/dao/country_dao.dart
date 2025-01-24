import 'package:sqflite/sqflite.dart';
import '../helpers/database_helper.dart';
import '../../models/country.dart';

class CountryDao {
  static final CountryDao _instance = CountryDao._internal();
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

  Future<List<Country>> getCountries() async {
    Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      'countries',
      orderBy: 'id DESC',
    );
    return maps.map((map) => Country.fromMap(map)).toList();
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

  Future<void> close() async {
    await _databaseHelper.close();
  }
}
