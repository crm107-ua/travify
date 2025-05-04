import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travify/models/currency.dart';
import 'package:travify/services/country_service.dart';
import 'package:travify/services/currency_service.dart';
import 'package:travify/services/settings_service.dart';

class CurrencySetupScreen extends StatefulWidget {
  const CurrencySetupScreen({super.key});

  @override
  State<CurrencySetupScreen> createState() => _CurrencySetupScreenState();
}

class _CurrencySetupScreenState extends State<CurrencySetupScreen> {
  final CurrencyService _currencyService = CurrencyService();
  List<Currency> _currencies = [];
  String? _selectedCurrencyCode;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _loadCurrencies();
      _initialized = true;
    }
  }

  Future<void> _loadCurrencies() async {
    List<Currency> currencies = await _currencyService.getAllCurrencies();
    final saved = await SettingsService.getDefaultCurrency();

    setState(() {
      _currencies = currencies;
      _selectedCurrencyCode = saved;
    });
  }

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: Text(
          "configure_currency".tr(),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
      body: _currencies.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCurrencyCode,
                    decoration: InputDecoration(labelText: "currency".tr()),
                    dropdownColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[900]
                            : Colors.white,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency.code,
                        child: Text('${currency.symbol} ${currency.name}'),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCurrencyCode = val),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_selectedCurrencyCode == null) return;

                      await SettingsService.setDefaultCurrency(
                          _selectedCurrencyCode!);

                      await Flushbar(
                        duration: const Duration(seconds: 1),
                        borderRadius: BorderRadius.circular(8),
                        margin: const EdgeInsets.all(16),
                        flushbarPosition: FlushbarPosition.BOTTOM,
                        dismissDirection: FlushbarDismissDirection.VERTICAL,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[850]!
                                : Colors.grey[200]!,
                        messageText: Text(
                          "saved_currency".tr(),
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      ).show(context);

                      if (mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: Text("currency_save".tr()),
                  ),
                ],
              ),
            ),
    );
  }
}
