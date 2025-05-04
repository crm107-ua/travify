import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:travify/services/country_service.dart';
import 'package:travify/services/settings_service.dart';

class LanguageSetupScreen extends StatefulWidget {
  const LanguageSetupScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LanguageSetupScreenState createState() => _LanguageSetupScreenState();
}

class _LanguageSetupScreenState extends State<LanguageSetupScreen> {
  List<Map<String, String>> _languages = [];
  String? _selectedLanguageCode;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _loadLanguages();
      _initialized = true;
    }
  }

  Future<void> _loadLanguages() async {
    final langs = CountryService.getLanguages();
    final savedLang = context.locale.languageCode;

    setState(() {
      _languages = langs;
      _selectedLanguageCode = savedLang;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorFondo = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorFondo,
        elevation: 0,
        title: Text(
          "select_language".tr(),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
      body: _languages.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedLanguageCode,
                    decoration: InputDecoration(labelText: "language".tr()),
                    dropdownColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[900]
                            : Colors.white,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                    items: _languages.map((lang) {
                      final code = lang['code']!;
                      final label = lang['label']!;
                      final flag = lang['flag']!;
                      return DropdownMenuItem(
                        value: code,
                        child: Text('$flag $label'),
                      );
                    }).toList(),
                    onChanged: (langCode) =>
                        setState(() => _selectedLanguageCode = langCode),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_selectedLanguageCode == null) return;

                      await context.setLocale(Locale(_selectedLanguageCode!));

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
                          "language_saved".tr(),
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
                    child: Text("save_language".tr()),
                  ),
                ],
              ),
            ),
    );
  }
}
