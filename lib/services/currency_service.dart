import 'package:travify/database/dao/currency_dao.dart';
import 'package:travify/models/currency.dart';

class CurrencyService {
  final CurrencyDao _currencyDao = CurrencyDao();

  Future<List<Currency>> getAllCurrencies() async {
    return await _currencyDao.getAllCurrencies();
  }

  Future<List<Currency>> getCountriesCurrencies(List<int> countriesIds) async {
    return await _currencyDao.getCountriesCurrencies(countriesIds);
  }
}
