import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:travify/screens/currency_setup_screen.dart';
import 'package:travify/screens/language_setup_screen.dart';
import 'package:travify/services/official_rates_service.dart';
import '../services/settings_service.dart';
import 'pin_setup_screen.dart';
import 'package:another_flushbar/flushbar.dart';

class SettingsContent extends StatefulWidget {
  const SettingsContent({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsContentState createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  bool _hasPin = false;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final pin = await SettingsService.getPin();
    setState(() {
      _hasPin = (pin != null && pin.isNotEmpty);
    });
  }

  void _showSnackBar(String message) {
    Flushbar(
      duration: Duration(seconds: 2),
      borderRadius: BorderRadius.circular(8),
      margin: EdgeInsets.all(16),
      flushbarPosition: FlushbarPosition.BOTTOM,
      dismissDirection: FlushbarDismissDirection.VERTICAL,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[850]!
          : Colors.grey[200]!,
      messageText: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
    ).show(context);
  }

  Future<void> showLoadingDialog(BuildContext context, String message) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 85, left: 26),
      children: [
        Text(
          "settings".tr(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 26),
        Transform.translate(
          offset: const Offset(0, 0),
          child: Container(
            margin: const EdgeInsets.only(right: 25),
            padding: const EdgeInsets.only(
              left: 25,
              right: 20,
              top: 5,
              bottom: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _hasPin ? "delete_pin".tr() : "configure_pin".tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(_hasPin ? Icons.delete : Icons.lock),
              ),
              onTap: () async {
                if (_hasPin) {
                  // Eliminar PIN
                  await SettingsService.removePin();
                  await _loadPin();
                  Flushbar(
                    duration: Duration(seconds: 1),
                    borderRadius: BorderRadius.circular(8),
                    margin: EdgeInsets.all(16),
                    flushbarPosition: FlushbarPosition.BOTTOM,
                    dismissDirection: FlushbarDismissDirection.VERTICAL,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[850]!
                            : Colors.grey[200]!,
                    messageText: Text(
                      "deleted_pin".tr(),
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ).show(context);
                } else {
                  // Configurar PIN
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PinSetupScreen()),
                  ).then((_) => _loadPin());
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 15),
        Transform.translate(
          offset: const Offset(0, 0),
          child: Container(
            margin: const EdgeInsets.only(right: 25),
            padding: const EdgeInsets.only(
              left: 25,
              right: 20,
              top: 5,
              bottom: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "configure_language".tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.translate),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LanguageSetupScreen()),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 15),
        Transform.translate(
          offset: const Offset(0, 0),
          child: Container(
            margin: const EdgeInsets.only(right: 25),
            padding: const EdgeInsets.only(
              left: 25,
              right: 20,
              top: 5,
              bottom: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "configure_currency".tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FutureBuilder<String?>(
                  future: SettingsService.getDefaultCurrency(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.isNotEmpty) {
                      return Text(snapshot.data!,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15));
                    } else {
                      return const Icon(Icons.attach_money);
                    }
                  },
                ),
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CurrencySetupScreen()),
                );
                setState(() {});
              },
            ),
          ),
        ),
        const SizedBox(height: 15),
        Transform.translate(
          offset: const Offset(0, 0),
          child: Container(
            margin: const EdgeInsets.only(right: 25),
            padding: const EdgeInsets.only(
              left: 25,
              right: 20,
              top: 5,
              bottom: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                width: 1,
              ),
            ),
            child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  "configure_theme".tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.brightness_4),
                ),
                onTap: () async {
                  // Configurar Idioma
                }),
          ),
        ),
        const SizedBox(height: 15),
        Transform.translate(
          offset: const Offset(0, 0),
          child: Container(
            margin: const EdgeInsets.only(right: 25),
            padding: const EdgeInsets.only(
              left: 25,
              right: 20,
              top: 5,
              bottom: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "load_rates".tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(Icons.update),
              ),
              onTap: () async {
                final canUpdate = await SettingsService.canUpdateRatesToday();
                if (!canUpdate) {
                  _showSnackBar("official_rates_already_updated".tr());
                  return;
                }

                // ignore: use_build_context_synchronously
                showLoadingDialog(context, "loading_official_rates".tr());

                final service = OfficialRatesService();
                await service.updateOfficialRates();
                await SettingsService.setLastRatesUpdate(DateTime.now());

                if (context.mounted) Navigator.pop(context);

                if (context.mounted) {
                  _showSnackBar("official_rates_updated".tr());
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
