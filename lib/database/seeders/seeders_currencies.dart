import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

/// Inserta todas las monedas en la tabla 'currencies' desde un archivo JSON.
Future<void> seedDatabaseCurrencies(Database db) async {
  try {
    // Cargar el archivo JSON
    String data = await rootBundle.loadString('assets/data/currencies.json');
    Map<String, dynamic> jsonResult = json.decode(data);

    // Verificar que los datos se han cargado correctamente
    // print( 'Datos cargados desde JSON: ${jsonResult.length} monedas encontradas.');

    if (jsonResult.isEmpty) {
      //print('La lista de monedas está vacía. Verifica el archivo JSON.');
      return;
    }

    // Utilizar Batch para insertar
    Batch batch = db.batch();

    jsonResult.forEach((key, value) {
      batch.insert(
        'currencies',
        {
          'code': value['code'],
          'name': value['name'],
          'symbol': value['symbol'],
          'symbol_native': value['symbol_native'],
          'decimal_digits': value['decimal_digits'],
          'rounding': value['rounding'],
          'name_plural': value['name_plural'],
        },
        conflictAlgorithm: ConflictAlgorithm.ignore, // Evita duplicados
      );
    });

    await batch.commit(noResult: true);

    String countryData =
        await rootBundle.loadString('assets/data/countries.json');
    List<dynamic> jsonCountryData = json.decode(countryData);

    for (int i = 1; i <= jsonCountryData.length; i++) {
      await db
          .insert('country_currencies', {'country_id': i, 'currency_id': 1});
      await db
          .insert('country_currencies', {'country_id': i, 'currency_id': 2});
      await db
          .insert('country_currencies', {'country_id': i, 'currency_id': 3});
      await db
          .insert('country_currencies', {'country_id': i, 'currency_id': 4});
    }
  } catch (e) {
    print('Error al insertar monedas desde JSON: $e');
  }
}
