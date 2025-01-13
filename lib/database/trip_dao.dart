import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/trip.dart';

class TripDao {
  // Singleton Pattern
  static final TripDao _instance = TripDao._internal();
  factory TripDao() => _instance;
  TripDao._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// Inserta un nuevo viaje en la base de datos.
  Future<int> insertViaje(Trip viaje) async {
    Database db = await _databaseHelper.database;
    return await db.insert(
      'viajes',
      viaje.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Recupera todos los viajes de la base de datos, ordenados por ID descendente.
  Future<List<Trip>> getViajes() async {
    Database db = await _databaseHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      'viajes',
      orderBy: 'id DESC',
    );
    return maps.map((map) => Trip.fromMap(map)).toList();
  }

  /// Actualiza un viaje existente en la base de datos.
  Future<int> updateViaje(Trip viaje) async {
    Database db = await _databaseHelper.database;
    return await db.update(
      'viajes',
      viaje.toMap(),
      where: 'id = ?',
      whereArgs: [viaje.id],
    );
  }

  /// Elimina un viaje de la base de datos basado en su ID.
  Future<int> deleteViaje(int id) async {
    Database db = await _databaseHelper.database;
    return await db.delete(
      'viajes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Cierra la conexión de la base de datos.
  Future<void> close() async {
    await _databaseHelper.close();
  }
}
