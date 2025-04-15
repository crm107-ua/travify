import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:travify/database/dao/currency_dao.dart';
import 'package:travify/database/dao/rate_dao.dart';
import 'package:travify/models/rate.dart';
import 'package:travify/models/currency.dart';

const String apiKey = '6fb6769c6b0e9cb6931256ee';
const String baseCurrency = 'EUR';

class OfficialRatesService {
  final rateDao = RateDao();
  final Map<List<String>, double> ratesMap = {};

  Future<void> updateOfficialRates() async {
    const Map<String, Map<String, dynamic>> currencyMapWithIds = {
      "USD": {"id": 1},
      "EUR": {"id": 2},
      "JPY": {"id": 3},
      "GBP": {"id": 4},
      "AUD": {"id": 5},
      "CAD": {"id": 6},
      "CHF": {"id": 7},
      "CNY": {"id": 8},
      "HKD": {"id": 9},
      "SGD": {"id": 10},
      "NZD": {"id": 11},
      "KRW": {"id": 12},
      "INR": {"id": 13},
      "BRL": {"id": 14},
      "MXN": {"id": 15},
      "ZAR": {"id": 16},
      "SEK": {"id": 17},
      "NOK": {"id": 18},
      "DKK": {"id": 19},
      "THB": {"id": 20},
      "AED": {"id": 21},
      "TRY": {"id": 22},
      "RUB": {"id": 23},
      "PLN": {"id": 24},
      "IDR": {"id": 25},
      "TWD": {"id": 26},
      "MYR": {"id": 27},
      "PHP": {"id": 28},
      "VND": {"id": 29},
      "ILS": {"id": 30},
      "SAR": {"id": 31},
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
}
