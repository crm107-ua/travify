import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import 'pin_setup_screen.dart';
import 'package:another_flushbar/flushbar.dart';

class SettingsContent extends StatefulWidget {
  @override
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
          "Ajustes",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 26),

        // Mostramos SIEMPRE el rectángulo con borde
        Transform.translate(
          offset: const Offset(0, 0), // Si quieres moverlo a la izquierda
          child: Container(
            margin: const EdgeInsets.only(right: 25),
            padding: const EdgeInsets.only(
              left: 25,
              right: 20,
              top: 5,
              bottom: 5,
            ),
            decoration: BoxDecoration(
              // Solo borde, sin color de fondo:
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
              // Ajusta este padding interno si deseas
              contentPadding: EdgeInsets.zero,

              // Cambiamos el texto según si hay PIN o no
              title: Text(
                _hasPin ? "Eliminar PIN" : "Configurar PIN",
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              // Ícono a la derecha
              trailing: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(_hasPin ? Icons.delete : Icons.lock),
              ),

              // Cambiamos también la acción del onTap
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
                      "PIN eliminado",
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
      ],
    );
  }
}
