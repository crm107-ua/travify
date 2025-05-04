import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:travify/database/dao/currency_dao.dart';
import 'package:travify/database/dao/rate_dao.dart';
import 'package:travify/models/rate.dart';

const String apiKey = '6fb6769c6b0e9cb6931256ee';
const String baseCurrency = 'EUR';

class OfficialRatesService {
  final rateDao = RateDao();
  final Map<List<String>, double> ratesMap = {};

  Future<void> updateOfficialRates() async {
    const Map<String, int> currencyIds = {
      "USD": 1,
      "EUR": 2,
      "JPY": 3,
      "GBP": 4,
      "AUD": 5,
      "CAD": 6,
      "CHF": 7,
      "CNY": 8,
      "HKD": 9,
      "SGD": 10,
      "NZD": 11,
      "KRW": 12,
      "INR": 13,
      "BRL": 14,
      "MXN": 15,
      "ZAR": 16,
      "SEK": 17,
      "NOK": 18,
      "DKK": 19,
      "THB": 20,
      "AED": 21,
      "TRY": 22,
      "RUB": 23,
      "PLN": 24,
      "IDR": 25,
      "TWD": 26,
      "MYR": 27,
      "PHP": 28,
      "VND": 29,
      "ILS": 30,
      "SAR": 31,
    };

    final url = Uri.parse(
        'https://v6.exchangerate-api.com/v6/$apiKey/latest/$baseCurrency');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Map<String, dynamic> allRates = data['conversion_rates'];

        final currencyDao = CurrencyDao();

        for (var entry in currencyIds.entries) {
          final code = entry.key;
          final id = entry.value;

          if (code == baseCurrency) continue;

          final rawRate = allRates[code];
          if (rawRate == null) continue;

          final rateValue = (rawRate is int)
              ? rawRate.toDouble()
              : double.parse(rawRate.toStringAsFixed(6));

          final fromCurrency =
              await currencyDao.getCurrencyById(currencyIds[baseCurrency]!);
          final toCurrency = await currencyDao.getCurrencyById(id);

          final rate = Rate(
            id: 0,
            currencyFrom: fromCurrency,
            currencyTo: toCurrency,
            rate: rateValue,
          );

          await rateDao.upsertRate(rate);
        }
      } else {
        print('❌ Error al obtener tasas desde API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Excepción: $e');
    }
  }
}
