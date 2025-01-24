import 'package:sqflite/sqflite.dart' as sqflite;
import '../helpers/database_helper.dart';
import '../../models/expense.dart';

class ExpenseDao {
  static final ExpenseDao _instance = ExpenseDao._internal();
  factory ExpenseDao() => _instance;
  ExpenseDao._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertExpense(Expense expense) async {
    sqflite.Database db = await _databaseHelper.database;
    return await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  Future<List<Expense>> getExpenses() async {
    sqflite.Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      orderBy: 'id DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  Future<int> updateExpense(Expense expense) async {
    sqflite.Database db = await _databaseHelper.database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    sqflite.Database db = await _databaseHelper.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    await _databaseHelper.close();
  }
}
