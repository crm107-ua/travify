import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import 'package:another_flushbar/flushbar.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PinSetupScreenState createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Color colorFondo = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorFondo,
        elevation: 0,
        title: Text(
          "Configurar PIN",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Introduce un PIN"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Confirma el PIN"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final pin = _pinController.text.trim();
                final confirmPin = _confirmPinController.text.trim();

                if (pin.isEmpty || confirmPin.isEmpty) {
                  Flushbar(
                    duration: const Duration(seconds: 2),
                    borderRadius: BorderRadius.circular(8),
                    margin: const EdgeInsets.all(16),
                    flushbarPosition: FlushbarPosition.BOTTOM,
                    dismissDirection: FlushbarDismissDirection.VERTICAL,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[850]!
                            : Colors.grey[200]!,
                    messageText: Text(
                      "Ambos campos son obligatorios",
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ).show(context);
                  return;
                }

                if (pin != confirmPin) {
                  Flushbar(
                    duration: const Duration(seconds: 2),
                    borderRadius: BorderRadius.circular(8),
                    margin: const EdgeInsets.all(16),
                    flushbarPosition: FlushbarPosition.BOTTOM,
                    dismissDirection: FlushbarDismissDirection.VERTICAL,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[850]!
                            : Colors.grey[200]!,
                    messageText: Text(
                      "Los PINs no coinciden",
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ).show(context);
                  return;
                }

                await SettingsService.savePin(pin);

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
                    "PIN guardado",
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
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
              child: const Text("Guardar PIN"),
            ),
          ],
        ),
      ),
    );
  }
}
