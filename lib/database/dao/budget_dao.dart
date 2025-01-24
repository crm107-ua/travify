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
  Future<int> insertPresupuesto(Budget presupuesto) async {
    Database db = await _databaseHelper.database;
    return await db.insert(
      'budgets',
      presupuesto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Recupera todos los presupuestos de la base de datos, ordenados por ID descendente.
  Future<List<Budget>> getPresupuestos() async {
    Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      orderBy: 'id DESC',
    );
    return maps.map((map) => Budget.fromMap(map)).toList();
  }

  /// Actualiza un presupuesto existente en la base de datos.
  Future<int> updatePresupuesto(Budget presupuesto) async {
    Database db = await _databaseHelper.database;
    return await db.update(
      'budgets',
      presupuesto.toMap(),
      where: 'id = ?',
      whereArgs: [presupuesto.id],
    );
  }

  /// Elimina un presupuesto de la base de datos basado en su ID.
  Future<int> deletePresupuesto(int id) async {
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
