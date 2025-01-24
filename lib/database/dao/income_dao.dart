import 'package:sqflite/sqflite.dart' as sqflite;
import '../helpers/database_helper.dart';
import '../../models/income.dart';

class IncomeDao {
  static final IncomeDao _instance = IncomeDao._internal();
  factory IncomeDao() => _instance;
  IncomeDao._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertIncome(Income income) async {
    sqflite.Database db = await _databaseHelper.database;
    return await db.insert(
      'incomes',
      income.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  Future<List<Income>> getIncomes() async {
    sqflite.Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      'incomes',
      orderBy: 'id DESC',
    );
    return maps.map((map) => Income.fromMap(map)).toList();
  }

  Future<int> updateIncome(Income income) async {
    sqflite.Database db = await _databaseHelper.database;
    return await db.update(
      'incomes',
      income.toMap(),
      where: 'id = ?',
      whereArgs: [income.id],
    );
  }

  Future<int> deleteIncome(int id) async {
    sqflite.Database db = await _databaseHelper.database;
    return await db.delete(
      'incomes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    await _databaseHelper.close();
  }
}
