import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:travify/screens/currency_setup_screen.dart';
import 'package:travify/screens/language_setup_screen.dart';
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
                child: Icon(Icons.attach_money),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CurrencySetupScreen()),
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
      ],
    );
  }
}
