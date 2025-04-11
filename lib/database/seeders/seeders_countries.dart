// lib/database/seeders/seeders_countries.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

/// Inserta todos los países del mundo en la tabla 'countries' desde un archivo JSON.
Future<void> seedDatabaseCountries(Database db) async {
  try {
    // Cargar el archivo JSON
    String data = await rootBundle.loadString('assets/data/countries.json');
    List<dynamic> jsonResult = json.decode(data);

    List<Map<String, dynamic>> countries =
        List<Map<String, dynamic>>.from(jsonResult);

    if (countries.isEmpty) {
      print('La lista de países está vacía. Verifica el archivo JSON.');
      return;
    }

    Batch batch = db.batch();

    for (var country in countries) {
      batch.insert(
        'countries',
        {
          'name': country['name'],
          'code': country['code'],
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  } catch (e) {
    print('Error al insertar países desde JSON: $e');
  }
}
