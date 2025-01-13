// lib/database/database_helper.dart

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  // Singleton Pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Inicializar la base de datos
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializar la base de datos
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'travify.db');

    return await openDatabase(
      path,
      version: 2, // Incrementa la versión debido a los cambios en la estructura
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Define el método de actualización
    );
  }

  // Crear las tablas al crear la base de datos
  Future _onCreate(Database db, int version) async {
    // Tabla Viajes
    await db.execute('''
      CREATE TABLE viajes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        destino TEXT NOT NULL,
        fechaInicio INTEGER NOT NULL,
        fechaFin INTEGER,
        image TEXT,
        open INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // Manejar actualizaciones de la base de datos
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migración de la tabla 'viajes' para agregar 'fechaFin', 'image' y 'active'
      await db.execute('''
        ALTER TABLE viajes ADD COLUMN fechaFin INTEGER
      ''');
      await db.execute('''
        ALTER TABLE viajes ADD COLUMN image TEXT
      ''');
      await db.execute('''
        ALTER TABLE viajes ADD COLUMN active INTEGER NOT NULL DEFAULT 0
      ''');
    }
    // Agrega más migraciones según sea necesario
  }

  // Cerrar la base de datos
  Future close() async {
    Database db = await database;
    db.close();
  }
}
