import 'package:sqflite/sqflite.dart';

/// Inserta datos de ejemplo en las tablas creadas.
Future<void> seedDatabaseAll(Database db) async {
  // Insertar en budgets
  await db.insert('budgets', {
    'max_limit': 5000.0,
    'desired_limit': 3000.0,
    'accumulated': 1500.0,
    'limit_increase': 0,
  });
  await db.insert('budgets', {
    'max_limit': 7000.0,
    'desired_limit': 4000.0,
    'accumulated': 2000.0,
    'limit_increase': 1,
  });

  // Insertar en trips
  // Primero, obtener los IDs de countries y budgets
  final List<Map<String, dynamic>> countryUS =
      await db.query('countries', where: 'code = ?', whereArgs: ['US']);
  final List<Map<String, dynamic>> countryCA =
      await db.query('countries', where: 'code = ?', whereArgs: ['CA']);
  final List<Map<String, dynamic>> budget1 = await db.query('budgets',
      limit: 1, where: 'desired_limit = ?', whereArgs: [3000.0]);
  final List<Map<String, dynamic>> budget2 = await db.query('budgets',
      limit: 1, where: 'desired_limit = ?', whereArgs: [4000.0]);

  final int countryUSId = countryUS.first['id'];
  final int countryCAId = countryCA.first['id'];
  final int budget1Id = budget1.first['id'];
  final int budget2Id = budget2.first['id'];

  await db.insert('trips', {
    'title': 'Viaje a Nueva York',
    'description': 'Fin de semana en la Gran Manzana',
    'date_start': DateTime.now().millisecondsSinceEpoch,
    'date_end': DateTime.now().add(Duration(days: 3)).millisecondsSinceEpoch,
    'destination': 'Nueva York',
    'image': 'nyc.png',
    'open': 1,
    'country_id': countryUSId,
    'budget_id': budget1Id,
  });

  await db.insert('trips', {
    'title': 'Vacaciones en Toronto',
    'description': 'Explorando la ciudad',
    'date_start': DateTime.now().add(Duration(days: 20)).millisecondsSinceEpoch,
    'date_end': DateTime.now().add(Duration(days: 30)).millisecondsSinceEpoch,
    'destination': 'Toronto',
    'image': 'toronto.png',
    'open': 1,
    'country_id': countryCAId,
    'budget_id': budget2Id,
  });

  // Insertar en transactions
  // Primero, obtener los IDs de trips
  final List<Map<String, dynamic>> tripNY = await db
      .query('trips', where: 'title = ?', whereArgs: ['Viaje a Nueva York']);
  final List<Map<String, dynamic>> tripToronto = await db
      .query('trips', where: 'title = ?', whereArgs: ['Vacaciones en Toronto']);

  final int tripNYId = tripNY.first['id'];
  final int tripTorontoId = tripToronto.first['id'];

  // Transacciones para el viaje a Nueva York
  final int transaction1Id = await db.insert('transactions', {
    'type': 0, // Supongamos 0: Expense
    'date': DateTime(2024, 5, 10).millisecondsSinceEpoch,
    'description': 'Reserva de hotel',
    'amount': 1200.0,
    'trip_id': tripNYId,
  });

  final int transaction2Id = await db.insert('transactions', {
    'type': 1, // Supongamos 1: Income
    'date': DateTime(2024, 5, 10).millisecondsSinceEpoch,
    'description': 'Reembolso de viaje',
    'amount': 300.0,
    'trip_id': tripNYId,
  });

  // Transacciones para el viaje a Toronto
  final int transaction3Id = await db.insert('transactions', {
    'type': 0, // Expense
    'date': DateTime(2024, 6, 16).millisecondsSinceEpoch,
    'description': 'Alquiler de coche',
    'amount': 500.0,
    'trip_id': tripTorontoId,
  });

  final int transaction4Id = await db.insert('transactions', {
    'type': 1, // Income
    'date': DateTime(2024, 6, 15).millisecondsSinceEpoch,
    'description': 'Patrocinio de viaje',
    'amount': 800.0,
    'trip_id': tripTorontoId,
  });

  // Insertar en expenses
  await db.insert('expenses', {
    'transaction_id': transaction1Id,
    'category': 2, // Por ejemplo, 2: Alojamiento
    'amortization': 0,
    'start_date_amortization': null,
    'next_amortization_date': null,
    'end_date_amortization': null,
  });

  await db.insert('expenses', {
    'transaction_id': transaction3Id,
    'category': 1, // Por ejemplo, 1: Transporte
    'amortization': 1,
    'start_date_amortization': DateTime(2024, 6, 16).millisecondsSinceEpoch,
    'next_amortization_date':
        DateTime(2024, 6, 23).millisecondsSinceEpoch, // Cada semana
    'end_date_amortization': DateTime(2024, 7, 14).millisecondsSinceEpoch,
  });

  // Insertar en incomes
  await db.insert('incomes', {
    'transaction_id': transaction2Id,
    'is_recurrent': 1,
    'recurrent_income_type': 2, // Por ejemplo, 2: Mensual
    'next_recurrent_date': DateTime(2024, 6, 10).millisecondsSinceEpoch,
    'active': 1,
  });

  await db.insert('incomes', {
    'transaction_id': transaction4Id,
    'is_recurrent': 0,
    'recurrent_income_type': null,
    'next_recurrent_date': null,
    'active': 1,
  });

  // Insertar en chenges
  await db.insert('chenges', {
    'transaction_id': transaction1Id,
    'currency_recived_id': 1, // USD
    'currency_spent_id': 1, // USD
    'amount_recived': 0.0,
  });

  await db.insert('chenges', {
    'transaction_id': transaction2Id,
    'currency_recived_id': 1, // USD
    'currency_spent_id': 1, // USD
    'amount_recived': 300.0,
  });

  await db.insert('chenges', {
    'transaction_id': transaction3Id,
    'currency_recived_id': 2, // CAD
    'currency_spent_id': 2, // CAD
    'amount_recived': 0.0,
  });

  await db.insert('chenges', {
    'transaction_id': transaction4Id,
    'currency_recived_id': 2, // CAD
    'currency_spent_id': 2, // CAD
    'amount_recived': 800.0,
  });
}
