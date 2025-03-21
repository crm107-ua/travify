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

    // Convertir a List<Map<String, dynamic>>
    List<Map<String, dynamic>> countries =
        List<Map<String, dynamic>>.from(jsonResult);

    // Verificar que los datos se han cargado correctamente
    // print('Datos cargados desde JSON: ${countries.length} países encontrados.');

    if (countries.isEmpty) {
      print('La lista de países está vacía. Verifica el archivo JSON.');
      return;
    }

    // Utilizar Batch para insertar
    Batch batch = db.batch();

    for (var country in countries) {
      batch.insert(
        'countries',
        {
          'name': country['name'],
          'code': country['code'],
        },
        conflictAlgorithm: ConflictAlgorithm.ignore, // Evita duplicados
      );
    }

    await batch.commit(noResult: true);
    // print('Todos los países han sido insertados exitosamente desde JSON.');
  } catch (e) {
    print('Error al insertar países desde JSON: $e');
  }
}
