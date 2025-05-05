import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:travify/constants/env.dart';
import 'package:travify/database/migrations/migrations_init.dart';
import 'package:travify/database/seeders/seeders_all.dart';
import 'package:travify/database/seeders/seeders_countries.dart';
import 'package:travify/database/seeders/seeders_currencies.dart';
import 'package:travify/database/seeders/seeders_rates.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

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
      await createAllTables(db);
      await seedDatabaseCountries(db);
      await seedDatabaseCurrencies(db);
      await seedDatabaseRates(db);
      if (!AppEnv.production) {
        await seedDatabaseAll(db);
      }
    } catch (e) {
      debugPrint('Error en _onCreate: $e');
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      await createAllTables(db);
      await seedDatabaseCountries(db);
      await seedDatabaseCurrencies(db);
      await seedDatabaseRates(db);
      if (!AppEnv.production) {
        await seedDatabaseAll(db);
      }
    } catch (e) {
      debugPrint('Error en _onUpgrade: $e');
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
