import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

/// Inserta todos los países del mundo en la tabla 'official_rates' desde un archivo JSON.
Future<void> seedDatabaseRates(Database db) async {
  try {
    // Cargar el archivo JSON
    String data =
        await rootBundle.loadString('assets/data/official_rates.json');
    List<dynamic> jsonResult = json.decode(data);

    List<Map<String, dynamic>> official_rates =
        List<Map<String, dynamic>>.from(jsonResult);

    if (official_rates.isEmpty) {
      print('La lista de rates está vacía. Verifica el archivo JSON.');
      return;
    }

    Batch batch = db.batch();

    for (var rate in official_rates) {
      batch.insert(
        'official_rates',
        {
          'currency_recived_id': rate['currency_recived_id'],
          'currency_spent_id': rate['currency_spent_id'],
          'rate': rate['rate'],
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  } catch (e) {
    print('Error al insertar rates desde JSON: $e');
  }
}
