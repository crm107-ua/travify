import 'package:sqflite/sqflite.dart';
import '../helpers/database_helper.dart';
import '../../models/budget.dart';

class BudgetDao {
  // Singleton Pattern
  static final BudgetDao _instance = BudgetDao._internal();
  factory BudgetDao() => _instance;
  BudgetDao._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// Inserta un nuevo presupuesto en la base de datos.
  Future<int> insertBudget(Budget presupuesto) async {
    Database db = await _databaseHelper.database;
    return await db.insert(
      'budgets',
      {
        'max_limit': presupuesto.maxLimit,
        'desired_limit': presupuesto.desiredLimit,
        'accumulated': presupuesto.accumulated,
        'limit_increase': presupuesto.limitIncrease ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Recupera un presupuesto de la base de datos basado en su ID.
  Future<Budget?> getBudgetById(int id) async {
    Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Budget.fromMap(maps.first);
    }
    return null;
  }

  /// Recupera todos los presupuestos de la base de datos, ordenados por ID descendente.
  Future<List<Budget>> getBudgets() async {
    Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      orderBy: 'id DESC',
    );
    return maps.map((map) => Budget.fromMap(map)).toList();
  }

  /// Actualiza un presupuesto existente en la base de datos.
  Future<int> updateBudget(Budget presupuesto) async {
    Database db = await _databaseHelper.database;
    return await db.update(
      'budgets',
      {
        'max_limit': presupuesto.maxLimit,
        'desired_limit': presupuesto.desiredLimit,
        'accumulated': presupuesto.accumulated,
        'limit_increase': presupuesto.limitIncrease ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [presupuesto.id],
    );
  }

  /// Elimina un presupuesto de la base de datos basado en su ID.
  Future<int> deleteBudget(int id) async {
    Database db = await _databaseHelper.database;
    return await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Cierra la conexión de la base de datos.
  Future<void> close() async {
    await _databaseHelper.close();
  }
}
