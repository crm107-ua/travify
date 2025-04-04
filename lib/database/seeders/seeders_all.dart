import 'package:sqflite/sqflite.dart';
import 'package:travify/enums/expense_category.dart';
import 'package:travify/enums/recurrent_income_type.dart';
import 'package:travify/enums/transaction_type.dart';

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

  await db.insert('budgets', {
    'max_limit': 5000.0,
    'desired_limit': 1000.0,
    'accumulated': 1500.0,
    'limit_increase': 0,
  });

  await db.insert('budgets', {
    'max_limit': 7000.0,
    'desired_limit': 2000.0,
    'accumulated': 2000.0,
    'limit_increase': 1,
  });

  // Insertar en trips
  // Primero, obtener los IDs de countries y budgets
  final List<Map<String, dynamic>> countryUS =
      await db.query('countries', where: 'code = ?', whereArgs: ['US']);
  final List<Map<String, dynamic>> countryCA =
      await db.query('countries', where: 'code = ?', whereArgs: ['CA']);
  final List<Map<String, dynamic>> countryES =
      await db.query('countries', where: 'code = ?', whereArgs: ['ES']);
  final List<Map<String, dynamic>> countryFR =
      await db.query('countries', where: 'code = ?', whereArgs: ['FR']);
  final List<Map<String, dynamic>> budget1 = await db.query('budgets',
      limit: 1, where: 'desired_limit = ?', whereArgs: [3000.0]);
  final List<Map<String, dynamic>> budget2 = await db.query('budgets',
      limit: 1, where: 'desired_limit = ?', whereArgs: [4000.0]);
  final List<Map<String, dynamic>> budget3 = await db.query('budgets',
      limit: 1, where: 'desired_limit = ?', whereArgs: [1000.0]);
  final List<Map<String, dynamic>> budget4 = await db.query('budgets',
      limit: 1, where: 'desired_limit = ?', whereArgs: [2000.0]);

  final int countryUSId = countryUS.first['id'];
  final int countryCAId = countryCA.first['id'];
  final int countryESId = countryES.first['id'];
  final int countryFRId = countryFR.first['id'];
  final int budget1Id = budget1.first['id'];
  final int budget2Id = budget2.first['id'];
  final int budget3Id = budget3.first['id'];
  final int budget4Id = budget4.first['id'];

  // Insertar en trips
  final int tripNYId = await db.insert('trips', {
    'title': 'Viaje a Nueva York',
    'description': 'Fin de semana en la Gran Manzana',
    'date_start': DateTime.now().millisecondsSinceEpoch,
    'date_end': DateTime.now().add(Duration(days: 3)).millisecondsSinceEpoch,
    'destination': 'Nueva York',
    'image':
        'https://wallpapers.com/images/hd/4k-new-york-city-night-79y2vrc0ks0ucwh5.jpg',
    'open': 1,
    'budget_id': budget1Id,
    'currency_id': 1, // USD
  });

  final int tripTorontoId = await db.insert('trips', {
    'title': 'Vacaciones en Toronto',
    'description': 'Explorando la ciudad',
    'date_start': DateTime.now().add(Duration(days: 20)).millisecondsSinceEpoch,
    'date_end': DateTime.now().add(Duration(days: 30)).millisecondsSinceEpoch,
    'destination': 'Toronto',
    'image':
        'https://images.pexels.com/photos/1519088/pexels-photo-1519088.jpeg',
    'open': 1,
    'budget_id': budget2Id,
    'currency_id': 1, // USD
  });

  final int tripSpainId = await db.insert('trips', {
    'title': 'Viaje a España',
    'description': 'Recorriendo la península ibérica',
    'date_start': DateTime.now().add(Duration(days: 40)).millisecondsSinceEpoch,
    'date_end': DateTime.now().add(Duration(days: 50)).millisecondsSinceEpoch,
    'destination': 'Alicante',
    'image':
        'https://images.pexels.com/photos/1862308/pexels-photo-1862308.jpeg?cs=srgb&dl=pexels-alex-saquisilli-780432-1862308.jpg&fm=jpg',
    'open': 1,
    'budget_id': budget3Id,
    'currency_id': 3, // EUR
  });

  final int tripFranceId = await db.insert('trips', {
    'title': 'Vacaciones en Francia',
    'description': 'Descubriendo la Riviera Francesa',
    'date_start': DateTime.now().add(Duration(days: 60)).millisecondsSinceEpoch,
    'date_end': DateTime.now().add(Duration(days: 70)).millisecondsSinceEpoch,
    'destination': 'Niza',
    'image':
        'https://media.istockphoto.com/id/1145618475/es/foto/villefranche-sur-mer-en-la-noche.jpg?s=612x612&w=0&k=20&c=yHaZtUg-Uo5aqgT-eOMKuNxd9HWOYX7TUUod7ml-rUg=',
    'open': 1,
    'budget_id': budget4Id,
    'currency_id': 3, // EUR
  });

  // Insertar en trip_country (relación entre trips y countries)
  await db.insert('trip_country', {
    'trip_id': tripNYId,
    'country_id': countryUSId,
  });

  await db.insert('trip_country', {
    'trip_id': tripTorontoId,
    'country_id': countryCAId,
  });

  await db.insert('trip_country', {
    'trip_id': tripSpainId,
    'country_id': countryESId,
  });

  await db.insert('trip_country', {
    'trip_id': tripFranceId,
    'country_id': countryFRId,
  });

  // Transacciones para el viaje a Nueva York
  // hoy + 1 día y hoy + 2 días, para que queden dentro de [hoy, hoy+3]
  final int transaction1Id = await db.insert('transactions', {
    'type': TransactionType.expense.index,
    'date': DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch,
    'description': 'Reserva de hotel',
    'amount': 1200.0,
    'trip_id': tripNYId,
  });

  final int transaction2Id = await db.insert('transactions', {
    'type': TransactionType.income.index,
    'date': DateTime.now().add(Duration(days: 2)).millisecondsSinceEpoch,
    'description': 'Reembolso de viaje',
    'amount': 300.0,
    'trip_id': tripNYId,
  });

  final int transactionChange1Id = await db.insert('transactions', {
    'type': TransactionType.change.index,
    'date': DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch,
    'description': 'Cambio de moneda',
    'amount': 1200.0,
    'trip_id': tripNYId,
  });

  // Transacciones para el viaje a Toronto
  // (hoy + 22) y (hoy + 25) caen dentro de [hoy+20, hoy+30]
  final int transaction3Id = await db.insert('transactions', {
    'type': TransactionType.expense.index,
    'date': DateTime.now().add(Duration(days: 22)).millisecondsSinceEpoch,
    'description': 'Alquiler de coche',
    'amount': 500.0,
    'trip_id': tripTorontoId,
  });

  final int transaction4Id = await db.insert('transactions', {
    'type': TransactionType.income.index,
    'date': DateTime.now().add(Duration(days: 25)).millisecondsSinceEpoch,
    'description': 'Patrocinio de viaje',
    'amount': 800.0,
    'trip_id': tripTorontoId,
  });

  final int transactionChange2Id = await db.insert('transactions', {
    'type': TransactionType.change.index,
    'date': DateTime.now().add(Duration(days: 26)).millisecondsSinceEpoch,
    'description': 'Cambio de moneda',
    'amount': 500.0,
    'trip_id': tripTorontoId,
  });

// Insertar en expenses
  await db.insert('expenses', {
    'transaction_id': transaction1Id,
    'category': ExpenseCategory.accommodation.index,
    'isAmortization': 0,
    'amortization': 0,
    'start_date_amortization': null,
    'next_amortization_date': null,
    'end_date_amortization': null,
  });

  await db.insert('expenses', {
    'transaction_id': transaction3Id,
    'category': ExpenseCategory.transport.index,
    'isAmortization': 1,
    'amortization': 33.33,
    // Ajustamos las fechas a partir de la fecha de la transacción (hoy+22)
    'start_date_amortization':
        DateTime.now().add(Duration(days: 22)).millisecondsSinceEpoch,
    'next_amortization_date':
        DateTime.now().add(Duration(days: 23)).millisecondsSinceEpoch,
    'end_date_amortization':
        DateTime.now().add(Duration(days: 36)).millisecondsSinceEpoch,
  });

// Insertar en incomes
  await db.insert('incomes', {
    'transaction_id': transaction2Id,
    'is_recurrent': 1,
    'recurrent_income_type': RecurrentIncomeType.monthly.index,
    'next_recurrent_date':
        DateTime.now().add(Duration(days: 32)).millisecondsSinceEpoch,
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
    'transaction_id': transactionChange1Id,
    'currency_recived_id': 1, // USD
    'currency_spent_id': 1, // USD
    'amount_recived': 0.0,
  });

  await db.insert('chenges', {
    'transaction_id': transactionChange2Id,
    'currency_recived_id': 1, // USD
    'currency_spent_id': 1, // USD
    'amount_recived': 300.0,
  });
}
