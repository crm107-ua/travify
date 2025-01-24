import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:travify/database/seeders/seeders_currencies.dart';
import '../migrations/migrations_init.dart';
import '../seeders/seeders_countries.dart';
import '../seeders/seeders_all.dart';

class DatabaseHelper {
  // Singleton Pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Versión actual de la base de datos
  static const int _dbVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'travify.db');

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      print('Creando todas las tablas');
      await createAllTables(db);
      print('Tablas creadas');

      print('Iniciando seed de countries');
      await seedDatabaseCountries(db);
      print('Seed de countries completado');

      print('Iniciando seed de currencies');
      await seedDatabaseCurrencies(db);
      print('Seed de currencies completado');

      print('Iniciando seed general');
      await seedDatabaseAll(db);
      print('Seed general completado');
    } catch (e) {
      print('Error en 5onCreate: $e');
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      print('Actualizando base de datos de versión $oldVersion a $newVersion');
      await createAllTables(db);
      await seedDatabaseCountries(db);
      await seedDatabaseCurrencies(db);
      await seedDatabaseAll(db);
      print('Seeders ejecutados durante la actualización');
    } catch (e) {
      print('Error en _onUpgrade: $e');
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
