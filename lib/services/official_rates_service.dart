import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:travify/database/dao/currency_dao.dart';
import 'package:travify/database/dao/rate_dao.dart';
import 'package:travify/models/rate.dart';
import 'package:travify/models/currency.dart';

const String apiKey = '6fb6769c6b0e9cb6931256ee';
const String baseCurrency = 'EUR';

Future<void> updateOfficialRates() async {
  const Map<String, Map<String, dynamic>> currencyMapWithIds = {
    "USD": {"id": 1},
    "EUR": {"id": 3},
    "JPY": {"id": 55},
    "GBP": {"id": 38},
    "AUD": {"id": 9},
    "CAD": {"id": 2},
    "CHF": {"id": 23},
    "CNY": {"id": 25},
    "HKD": {"id": 43},
    "SGD": {"id": 98},
    "NZD": {"id": 82},
    "KRW": {"id": 59},
    "INR": {"id": 49},
    "BRL": {"id": 18},
    "MXN": {"id": 74},
    "ZAR": {"id": 117},
    "SEK": {"id": 97},
    "NOK": {"id": 80},
    "DKK": {"id": 31},
    "THB": {"id": 101},
    "AED": {"id": 4},
    "TRY": {"id": 104},
    "RUB": {"id": 93},
    "PLN": {"id": 88},
    "IDR": {"id": 47},
    "TWD": {"id": 106},
    "MYR": {"id": 75},
    "PHP": {"id": 86},
    "VND": {"id": 113},
    "ILS": {"id": 48},
    "SAR": {"id": 95},
  };

  final List<String> majorCurrencies = currencyMapWithIds.keys.toList();

  final url = Uri.parse(
      'https://v6.exchangerate-api.com/v6/$apiKey/latest/$baseCurrency');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final Map<String, dynamic> allRatesRaw = data['conversion_rates'];

      final Map<String, double> majorRates = {};
      for (var currency in majorCurrencies) {
        final rawRate = allRatesRaw[currency];
        if (rawRate != null) {
          majorRates[currency] =
              (rawRate is int) ? rawRate.toDouble() : rawRate;
        }
      }

      final rateDao = RateDao();
      final currencyDao = CurrencyDao();

      for (var from in majorCurrencies) {
        for (var to in majorCurrencies) {
          if (from == to) continue;

          if (majorRates.containsKey(from) && majorRates.containsKey(to)) {
            double rateValue = majorRates[to]! / majorRates[from]!;
            rateValue = double.parse(rateValue.toStringAsFixed(6));

            final idFrom = currencyMapWithIds[from]!['id'];
            final idTo = currencyMapWithIds[to]!['id'];

            Currency currencyFrom = await currencyDao.getCurrencyById(idFrom);

            Currency currencyTo = await currencyDao.getCurrencyById(idTo);

            final rate = Rate(
              id: 0,
              currencyFrom: currencyFrom,
              currencyTo: currencyTo,
              rate: rateValue,
            );

            await rateDao.upsertRate(rate);
          }
        }
      }

      print('✅ Tasas actualizadas correctamente en la base de datos.');
    } else {
      print('❌ Error al obtener tasas desde la API: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Excepción al actualizar tasas oficiales: $e');
  }
}
