import 'package:flutter/material.dart';
import 'package:travify/constants/colors.dart';
import '../services/settings_service.dart';
import 'package:another_flushbar/flushbar.dart';

class PinSetupScreen extends StatefulWidget {
  @override
  _PinSetupScreenState createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Definimos el color de fondo según el tema
    final Color colorFondo = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        // Asignamos el mismo color
        backgroundColor: colorFondo,
        elevation: 0, // Opcional, para que el AppBar no tenga sombra
        title: Text(
          "Configurar PIN",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        // Si deseas que los íconos (flecha atrás, menú) también
        // cambien de color, puedes controlar `iconTheme`:
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
              decoration: InputDecoration(labelText: "Introduce un PIN"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // Fondo semitransparente según el tema (oscuro / claro)
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final pin = _pinController.text.trim();
                if (pin.isNotEmpty) {
                  await SettingsService.savePin(pin);
                  final flush = Flushbar(
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
                      "PIN guardado",
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  );

                  await flush.show(context);
                  Navigator.pop(context);
                } else {
                  final flush = Flushbar(
                    duration: Duration(seconds: 2),
                    borderRadius: BorderRadius.circular(8),
                    margin: EdgeInsets.all(16),
                    flushbarPosition: FlushbarPosition.BOTTOM,
                    dismissDirection: FlushbarDismissDirection.VERTICAL,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[850]!
                            : Colors.grey[200]!,
                    messageText: Text(
                      "El PIN no puede estar vacío",
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  );
                  flush.show(context);
                }
              },
              child: Text(
                "Guardar PIN",
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
